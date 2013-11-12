class Host < ActiveRecord::Base
  belongs_to :site
  has_many :hits
  has_many :daily_hit_totals

  def aka_hostname
    # This does the reverse of Bouncer's aka handling:
    #     hostname.sub(/^aka-/, '').sub(/^aka\./, 'www.')
    aka = hostname.sub(/^www\./, 'aka.')
    aka.start_with?('aka.') ? aka : 'aka-' + aka
  end
end
