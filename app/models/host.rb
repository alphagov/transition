class Host < ActiveRecord::Base
  belongs_to :site
  has_many :hits
  has_many :host_paths
  has_many :daily_hit_totals
  has_one :aka_host, class_name: 'Host', foreign_key: 'canonical_host_id'
  belongs_to :canonical_host, class_name: 'Host'

  validate :hostname, presence: true
  validate :site, presence: true
  validate :canonical_host_id, presence: { :if => :aka? }

  scope :excluding_aka, where('hostname not like "aka%"')

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
    /^redirector-cdn[^.]*\.production\.govuk\.service\.gov\.uk$/.match(cname).present?
  end
end
