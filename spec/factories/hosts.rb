FactoryBot.define do
  factory :host do
    sequence(:hostname) { |n| "www-#{n}.example.gov.uk" }
    association :site

    trait :with_govuk_cname do
      cname { "redirector-cdn.production.govuk.service.gov.uk" }
    end

    trait :with_third_party_cname do
      cname { "bis-tms-101-L01.eduserv.org.uk" }
    end

    trait :with_its_aka_host do
      after(:create) do |host|
        raise ArgumentError, "This host is an aka itself" if host.aka?

        create(:host, hostname: host.aka_hostname, site: host.site, canonical_host_id: host.id)
      end
    end
  end
end
