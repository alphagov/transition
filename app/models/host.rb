class Host < ActiveRecord::Base
  belongs_to :site
  has_many :hits
  has_many :host_paths
  has_many :daily_hit_totals
  has_one :aka_host, class_name: 'Host', foreign_key: 'canonical_host_id'
  belongs_to :canonical_host, class_name: 'Host'

  validates :hostname, presence: true
  validates :hostname, hostname: true
  validates :site, presence: true
  validate :canonical_host_id_xor_aka_present

  after_update :update_hits_relations, :if => :site_id_changed?

  scope :excluding_aka, -> { where(canonical_host_id: nil) }

  FASTLY_ANYCAST_IPS = ['23.235.33.144', '23.235.37.144'] # To be used for new root domains
  DYN_DNS_IPS        = ['216.146.46.10', '216.146.46.11'] # Used for a few domains we control
  AMAZON_LEGACY_IP   = ['46.137.92.159']                  # We're migrating domains off this
  REDIRECTOR_IPS     = FASTLY_ANYCAST_IPS + DYN_DNS_IPS + AMAZON_LEGACY_IP

  REDIRECTOR_CNAME = /^redirector-cdn[^.]*\.production\.govuk\.service\.gov\.uk$/

  def aka?
    hostname.start_with?('aka')
  end

  def aka_hostname
    Host.aka_hostname(hostname)
  end

  def self.aka_hostname(hostname)
    # This does the reverse of Bouncer's aka handling:
    #     hostname.sub(/^aka-/, '').sub(/^aka\./, 'www.')
    if hostname.start_with?('www.')
      hostname.sub(/^www\./, 'aka.')
    else
      'aka-' + hostname
    end
  end

  def self.canonical_hostname(hostname)
    hostname.sub(/^aka-/, '').sub(/^aka\./, 'www.')
  end

  def redirected_by_gds?
    REDIRECTOR_IPS.include?(ip_address) ||
      REDIRECTOR_CNAME.match(cname).present?
  end

  def canonical_host_id_xor_aka_present
    # exclusive or: one and only one of canonical_host_id and aka? is required
    if !aka? && canonical_host_id.present?
      errors[:canonical_host_id] << 'must be blank for a non-aka host'
    end
    if aka? && canonical_host_id.blank?
      errors[:canonical_host_id] << 'can\'t be blank for an aka host'
    end
  end

  def update_hits_relations
    host_paths.update_all(mapping_id: nil, canonical_path: nil)
    hits.update_all(mapping_id: nil)
    Transition::Import::HitsMappingsRelations.refresh!(self.site)
  end
end
