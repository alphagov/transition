require "transition/import/hits_mappings_relations"

class Host < ApplicationRecord
  has_paper_trail

  belongs_to :site
  has_many :hits
  has_many :host_paths
  has_many :daily_hit_totals
  has_one :aka_host, class_name: "Host", foreign_key: "canonical_host_id"
  belongs_to :canonical_host, class_name: "Host"

  validates :hostname, presence: true
  validates :hostname, uniqueness: {
    message: lambda do |_object, data|
      site = Host.find_by(hostname: data[:value]).site.default_host.hostname
      "The hostname #{data[:value]} already exists. You must delete the #{site} site to remove it"
    end,
  }
  validates :hostname, hostname: true
  validates :site, presence: true
  validate :canonical_host_id_xor_aka_present, if: -> { hostname.present? }
  validate :hostname_is_downcased, if: -> { hostname.present? }

  after_update :update_hits_relations, if: :saved_change_to_site_id?

  scope :excluding_aka, -> { where(canonical_host_id: nil) }

  scope :with_cname_or_ip_address,
        lambda {
          where("(cname IS NOT NULL) OR (ip_address IS NOT NULL)")
        }

  FASTLY_BOUNCER_SERVICE_MAP = %w[151.101.2.30 151.101.66.30 151.101.130.30 151.101.194.30].freeze # bouncer.gds.map.fastly.net.
  FASTLY_NEW_BOUNCER_IPS = %w[151.101.0.204 151.101.64.204 151.101.128.204 151.101.192.204].freeze
  FASTLY_ANYCAST_IPS = ["23.235.33.144", "23.235.37.144"].freeze # FIXME: These IPs are deprecated, Fastly would like to reallocate them
  REDIRECTOR_IPS     = FASTLY_ANYCAST_IPS + FASTLY_BOUNCER_SERVICE_MAP + FASTLY_NEW_BOUNCER_IPS

  REDIRECTOR_CNAME = /^(redirector|bouncer)-cdn[^.]*\.production\.govuk\.service\.gov\.uk$/

  def aka?
    hostname.start_with?("aka")
  end

  def aka_hostname
    Host.aka_hostname(hostname)
  end

  def self.aka_hostname(hostname)
    # This does the reverse of Bouncer's aka handling:
    #     hostname.sub(/^aka-/, '').sub(/^aka\./, 'www.')
    if hostname.start_with?("www.")
      hostname.sub(/^www\./, "aka.")
    else
      "aka-#{hostname}"
    end
  end

  def self.canonical_hostname(hostname)
    hostname.sub(/^aka-/, "").sub(/^aka\./, "www.")
  end

  def redirected_by_gds?
    REDIRECTOR_IPS.include?(ip_address) ||
      REDIRECTOR_CNAME.match(cname).present?
  end

  def canonical_host_id_xor_aka_present
    # exclusive or: one and only one of canonical_host_id and aka? is required
    if !aka? && canonical_host_id.present?
      errors.add(:canonical_host_id, message: "must be blank for a non-aka host")
    end
    if aka? && canonical_host_id.blank?
      errors.add(:canonical_host_id, message: "can't be blank for an aka host")
    end
  end

  def update_hits_relations
    host_paths.update_all(mapping_id: nil, canonical_path: nil)
    hits.update_all(mapping_id: nil)
    Transition::Import::HitsMappingsRelations.refresh!(site)
  end

  def hostname_is_downcased
    if hostname != hostname.downcase
      errors.add(:hostname, "must be lowercase")
    end
  end
end
