FactoryGirl.define do
  factory :organisation do
    title 'Orgtastic'

    ga_profile_id '46600000'
    whitehall_type 'Executive non-departmental public body'
    sequence(:whitehall_slug) { |n| "org-#{n}" }

    trait :with_site do
      after(:create) { |o| o.sites = FactoryGirl.create_list(:sequenced_site, 1) }
    end
  end
end
