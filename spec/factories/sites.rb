FactoryGirl.define do
  factory :site_without_host, class: Site do
    sequence(:abbr) { |n| "site-#{n}" }
    homepage 'https://www.gov.uk/government/organisations/example-org'
    query_params ''
    launch_date { 1.month.ago }
    tna_timestamp '2012-08-16 22:40:15'
    managed_by_transition true

    association :organisation

    factory :site do # default site comes with a host {abbr}.gov.uk
      after(:build) do |site|
        site.hosts << FactoryGirl.build(:host, hostname: "#{site.abbr}.gov.uk", site: site)
      end
    end
  end
end
