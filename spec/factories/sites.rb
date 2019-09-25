FactoryBot.define do
  factory :site_without_host, class: Site do
    sequence(:abbr) { |n| "site-#{n}" }
    homepage { "https://www.gov.uk/government/organisations/example-org" }
    query_params { "" }
    launch_date { 1.month.ago }
    tna_timestamp { "2012-08-16 22:40:15" }

    association :organisation

    factory :site do # default site comes with a host {abbr}.gov.uk
      after(:build) do |site|
        site.hosts << FactoryBot.build(:host, hostname: "#{site.abbr}.gov.uk", site: site)
      end
    end

    trait :with_mappings_and_hits do
      after(:build) do |site|
        if site.hosts.none?
          site.hosts << FactoryBot.build(:host, hostname: "#{site.abbr}.gov.uk", site: site)
        end

        3.times do |n|
          n += 1
          mapping = create :mapping, site: site, path: "/path-#{n}"
          create :hit, :error, host: site.default_host, path: mapping.path, count: 40 * n
          create :hit, :redirect, host: site.default_host, path: mapping.path, count: 30 * n
        end
        create :hit, :redirect, host: site.default_host, path: "/no-mapping", count: 17

        Transition::Import::HitsMappingsRelations.refresh!
      end
    end
  end
end
