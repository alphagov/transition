FactoryGirl.define do
  factory :site do
    abbr 'cic_regulator'
    homepage 'https://www.gov.uk/government/organisations/cic-regulator'
    query_params ''
    tna_timestamp '2012-08-16 22:40:15'
    managed_by_transition true

    association :organisation

    factory :site_with_default_host do
      after(:build) do |site|
        site.hosts << FactoryGirl.build(:host, hostname: "#{site.abbr}.gov.uk")
      end
    end
  end
end
