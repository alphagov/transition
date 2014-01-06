FactoryGirl.define do
  factory :host do
    sequence(:hostname) {|n| "www-#{n}.example.gov.uk" }
    association :site

    trait :with_govuk_cname do
      cname 'redirector-cdn.production.govuk.service.gov.uk'
    end

    trait :with_third_party_cname do
      cname 'bis-tms-101-L01.eduserv.org.uk'
    end
  end
end
