require "transition/history"

class Mapping < ApplicationRecord
  include NilifyBlanks

  # ActiveRecord uses a column named 'type' for Single Table Inheritance, and
  # by default activates STI if a 'type' column is present. Setting the column
  # name for STI to something else allows us to use a 'type' column for
  # something else instead, without activating STI.
  self.inheritance_column = nil

  SUPPORTED_TYPES = %w[redirect archive unresolved].freeze

  acts_as_taggable
  has_paper_trail

  belongs_to :site
  has_many :hits

  validates :site, presence: true
  validates :path,
            length: { maximum: 2048 },
            exclusion: { in: ["/"], message: I18n.t("mappings.not_possible_to_edit_homepage_mapping") },
            is_path: true
  validates :type, presence: true, inclusion: { in: SUPPORTED_TYPES }
  validates :path, uniqueness: { scope: [:site_id], message: "Mapping already exists for this site and path!" }

  before_validation :trim_scheme_host_and_port_from_path, :fill_in_scheme, :canonicalize_path

  before_save :ensure_papertrail_user_config

  after_create :update_hit_relations

  validates :new_url, :suggested_url, :archive_url, length: { maximum: 2048 }, non_blank_url: true
  validates :new_url, presence: { if: :redirect?, message: "is required" }
  validates :new_url, host_in_whitelist: { if: :redirect? }
  validates :new_url, not_a_national_archives_url: { if: :redirect?, message: "must not be to the National Archives. Use an archive mapping for that." }
  validates :archive_url, national_archives_url: true

  scope :with_hit_count,
        lambda {
          select("mappings.*, SUM(hits.count) as hit_count")
            .joins("LEFT JOIN hits ON hits.mapping_id = mappings.id")
            .group("mappings.id")
        }
  scope :with_type, ->(type) { where(type: type) }
  scope :redirects, -> { with_type("redirect") }
  scope :archives,  -> { with_type("archive") }
  scope :unresolved, -> { with_type("unresolved") }
  scope :filtered_by_path,
        lambda { |term|
          where(Mapping.arel_table[:path].matches("%#{term}%")).references(:mapping) if term.present?
        }
  scope :filtered_by_new_url,
        lambda { |term|
          where(Mapping.arel_table[:new_url].matches("%#{term}%")).references(:mapping) if term.present?
        }

  def redirect?
    type == "redirect"
  end

  def archive?
    type == "archive"
  end

  def unresolved?
    type == "unresolved"
  end

  ##
  # Return the occasional bit-part attribute +hit_count+ as a number.
  # Preserve the possible +nil+ value.
  def hit_count
    self[:hit_count] && self[:hit_count].to_i
  end

  ##
  # Reconstruct old URL based on path and default site hostname
  def old_url
    "http://#{site.default_host.hostname}#{path}"
  end

  ##
  # Generate national archive index URL
  def national_archive_index_url
    "http://webarchive.nationalarchives.gov.uk/*/#{old_url}"
  end

  ##
  # Generate national archive URL
  def national_archive_url
    "http://webarchive.nationalarchives.gov.uk/#{tna_timestamp}/#{old_url}"
  end

  def edited_by_human?
    # Intent: has this mapping (ever) been edited by a human? We treat
    # mappings that were imported from redirector (now called transition-config)
    # as human-edited because they are curated.
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
      User.find_by(id: versions.last.user_id)
    end
  end

  def hit_percentage
    site.hit_total_count.zero? ? 0 : (hit_count.to_f / site.hit_total_count) * 100
  end

  # uri can be a URL or something that is intended to be a URL,
  # eg www.gov.uk/foo is technically not a URL, but we can prepend https:// and
  # it becomes a URL.
  def self.ensure_url(uri)
    if uri.blank? || uri =~ %r{^https?:}
      uri
    elsif %r{^www.gov.uk}.match?(uri)
      "https://" + uri
    else
      "http://" + uri
    end
  end

protected

  def fill_in_scheme
    self.new_url       = Mapping.ensure_url(new_url)
    self.suggested_url = Mapping.ensure_url(suggested_url)
    self.archive_url   = Mapping.ensure_url(archive_url)
  end

  def trim_scheme_host_and_port_from_path
    if %r{^https?:}.match?(path)
      url = Addressable::URI.parse(path)
      self.path = url.request_uri
    end
  rescue Addressable::URI::InvalidURIError
    # The path isn't parseable, so leave it intact for validations to report
    Rails.logger.warn("Unparseable URI #{path} in mapping")
  end

  def canonicalize_path
    return if site.nil?

    self.path = site.canonical_path(path) if path_is_valid_for_canonicalization?
  end

  def path_is_valid_for_canonicalization?
    # quickly check if the path would fail validations, and don't
    # canonicalize it:
    #   '/' is a homepage path and not valid for a mapping
    #   a path that doesn't start with a '/' isn't a valid path
    # full validation still needs to be run on the path
    !((path == "/" || path =~ /^[^\/]/))
  end

  def tna_timestamp
    site.tna_timestamp.to_formatted_s(:number)
  end

  def ensure_papertrail_user_config
    Transition::History.ensure_user!
  end

  def update_hit_relations
    host_paths = site.host_paths.where(canonical_path: path)
    new_hits_paths = host_paths.pluck(:path)

    site.hits.where(path: new_hits_paths).update_all(mapping_id: id)
    host_paths.update_all(mapping_id: id)

    update_column(:hit_count, hits.sum("count"))
  end
end
