require 'active_record/concerns/nilify_blanks'
require 'digest/sha1'
require 'transition/history'

class Mapping < ActiveRecord::Base
  include ActiveRecord::Concerns::NilifyBlanks

  # ActiveRecord uses a column named 'type' for Single Table Inheritance, and
  # by default activates STI if a 'type' column is present. Setting the column
  # name for STI to something else allows us to use a 'type' column for
  # something else instead, without activating STI.
  self.inheritance_column = nil

  SUPPORTED_TYPES = %w(redirect archive)

  attr_accessible :path, :site, :type, :new_url, :suggested_url, :archive_url, :tag_list

  acts_as_taggable
  has_paper_trail :ignore => [:tag_list => Proc.new { |mapping|
    # tag_list appears to ActiveModel::Dirty/paper_trail to be an
    # ActsAsTaggableOn::TagList but the original value from the database is a
    # string. This means that it is "different" even though it isn't.
    # Comparing the stringified version avoids that problem.
    mapping.tag_list_was == mapping.tag_list.to_s
  } ]

  belongs_to :site
  validates :site, presence: true
  validates :path,
            length: { maximum: 1024 },
            exclusion: { in: ['/'], message: I18n.t('mappings.not_possible_to_edit_homepage_mapping')},
            is_path: true
  validates :type, presence: true, inclusion: { :in => SUPPORTED_TYPES }
  validates :site_id, uniqueness: { scope: [:path_hash], message: 'Mapping already exists for this site and path!' }

  # set a hash of the path because we can't have a unique index on
  # the path (it's too long)
  before_validation :trim_scheme_host_and_port_from_path, :fill_in_scheme, :canonicalize_path, :set_path_hash
  validates :path_hash, presence: true

  before_save :ensure_papertrail_user_config

  after_create :update_hit_relations

  validates :new_url, :suggested_url, :archive_url, length: { maximum: (64.kilobytes - 1) }, non_blank_url: true
  validates :new_url, presence: { if: :redirect?, message: 'required when mapping is a redirect' }
  validates :new_url, host_in_whitelist: true
  validates :archive_url, national_archives_url: true

  scope :with_hit_count, -> {
    select('mappings.*, SUM(hits.count) as hit_count').
      joins('LEFT JOIN hits ON hits.mapping_id = mappings.id').
      group('mappings.path_hash')
  }
  scope :with_type, -> type { where(type: type) }
  scope :redirects, with_type('redirect')
  scope :archives,  with_type('archive')
  scope :filtered_by_path,    -> term { where(term.blank? ? true : Mapping.arel_table[:path].matches("%#{term}%")) }
  scope :filtered_by_new_url, -> term { where(term.blank? ? true : Mapping.arel_table[:new_url].matches("%#{term}%")) }

  def redirect?
    type == 'redirect'
  end

  def archive?
    type == 'archive'
  end

  def http_status
    if redirect?
      '301'
    elsif archive?
      '410'
    end
  end

  ##
  # Reconstruct old URL based on path and default site hostname
  def old_url
    "http://#{self.site.default_host.hostname}#{self.path}"
  end

  ##
  # Generate national archive index URL
  def national_archive_index_url
    "http://webarchive.nationalarchives.gov.uk/*/#{self.old_url}"
  end

  ##
  # Generate national archive URL
  def national_archive_url
    "http://webarchive.nationalarchives.gov.uk/#{self.tna_timestamp}/#{self.old_url}"
  end

  def edited_by_human?
    # Intent: has this mapping (ever) been edited by a human? We treat
    # redirector's mappings as human-edited because they are curated.
    #
    # Assumptions:
    #
    #   * humans only edit when paper trail is recording changes
    #   * all machine edits are done by a 'robot' user or when paper trail is
    #     turned off or isn't applicable (eg redirector import)
    #
    if from_redirector == true
      true
    else
      last_editor.present? && last_editor.is_human?
    end
  end

  def last_editor
    # This will return nil if the mapping was imported from redirector and has
    # not been edited since.
    if versions.present? && versions.last.user_id.present?
      User.find_by_id(versions.last.user_id)
    end
  end

  def hit_percentage
    raise NoMethodError, 'This only works in the context of :with_hit_count' unless respond_to?(:hit_count)

    site.hit_total_count.zero? ? 0 : (hit_count.to_f / site.hit_total_count) * 100
  end

protected
  def fill_in_scheme
    self.new_url       = Mapping.ensure_url(new_url)
    self.suggested_url = Mapping.ensure_url(suggested_url)
    self.archive_url   = Mapping.ensure_url(archive_url)
  end

  # uri can be a URL or something that is intended to be a URL,
  # eg www.gov.uk/foo is technically not a URL, but we can prepend https:// and
  # it becomes a URL.
  def self.ensure_url(uri)
    case
    when uri.blank? || uri =~ %r{^https?:}
      uri
    when uri =~ %r{^www.gov.uk}
      'https://' + uri
    else
      'http://' + uri
    end
  end

  def trim_scheme_host_and_port_from_path
    if path =~ %r{^https?:}
      url = Addressable::URI.parse(path)
      self.path = url.request_uri
    end
  rescue Addressable::URI::InvalidURIError
    # The path isn't parseable, so leave it intact for validations to report
  end

  def set_path_hash
    self.path_hash = Digest::SHA1.hexdigest(path) if path_changed?
  end

  def canonicalize_path
    self.path = site.canonical_path(path) unless (site.nil? || path == '/' || path =~ /^[^\/]/)
  end

  def tna_timestamp
    self.site.tna_timestamp.to_formatted_s(:number)
  end

  def ensure_papertrail_user_config
    Transition::History.ensure_user!
  end

  def update_hit_relations
    host_paths = site.host_paths.where(c14n_path_hash: path_hash)
    new_hits_hashes = host_paths.pluck(:path_hash)

    site.hits.where(path_hash: new_hits_hashes).update_all(mapping_id: self.id)
    host_paths.update_all(mapping_id: self.id)
  end
end
