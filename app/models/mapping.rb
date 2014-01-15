require 'active_record/concerns/nilify_blanks'
require 'digest/sha1'

class Mapping < ActiveRecord::Base
  include ActiveRecord::Concerns::NilifyBlanks

  SUPPORTED_STATUSES = [301, 410]

  TYPES = {
    '301' => 'redirect',
    '410' => 'archive'
  }

  attr_accessible :path, :site, :http_status, :new_url, :suggested_url, :archive_url

  has_paper_trail

  belongs_to :site
  validates :site, presence: true
  validates :path,
            length: { maximum: 1024 },
            exclusion: { in: ['/'], message: I18n.t('not_possible_to_edit_homepage_mapping')},
            is_path: true
  validates :http_status, presence: true, length: { maximum: 3 }
  validates :site_id, uniqueness: { scope: [:path], message: 'Mapping already exists for this site and path!' }

  # set a hash of the path because we can't have a unique index on
  # the path (it's too long)
  before_validation :trim_scheme_host_and_port_from_path, :fill_in_scheme, :canonicalize_path, :set_path_hash
  validates :path_hash, presence: true

  validates :new_url, :suggested_url, :archive_url, length: { maximum: (64.kilobytes - 1) }, non_blank_url: true
  validates :new_url, presence: { if: :redirect?, message: 'required when mapping is a redirect' }
  validates :archive_url, national_archives_url: true

  scope :with_status, -> status { where(http_status: Rack::Utils.status_code(status)) }
  scope :redirects, with_status(:moved_permanently)
  scope :filtered_by_path,    -> term { where(term.blank? ? true : Mapping.arel_table[:path].matches("%#{term}%")) }
  scope :filtered_by_new_url, -> term { where(term.blank? ? true : Mapping.arel_table[:new_url].matches("%#{term}%")) }

  def redirect?
    http_status == '301'
  end

  def type
    TYPES[http_status] || 'unknown'
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
    else originator.present?
      user = User.find_by_id(originator)
      user.present? && user.is_human?
    end
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
    uri = URI.parse(path)
    self.path = uri.request_uri if uri.respond_to?(:request_uri)
  rescue URI::InvalidURIError
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

end
