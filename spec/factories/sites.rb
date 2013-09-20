FactoryGirl.define do
  factory :site do
    abbr 'cic_regulator'
    homepage 'https://www.gov.uk/government/organisations/cic-regulator'

    association :organisation

    factory :site_with_default_host do
      after(:build) do |site|
        site.hosts << FactoryGirl.build(:host)
      end
    end
  end
end
