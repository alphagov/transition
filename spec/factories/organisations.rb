FactoryBot.define do
  factory :organisation do
    title { 'Orgtastic' }

    ga_profile_id { '46600000' }
    whitehall_type { 'Executive non-departmental public body' }
    sequence(:whitehall_slug) { |n| "org-#{n}" }
    content_id { SecureRandom.uuid }

    trait :with_site do
      after(:create) { |o| o.sites = FactoryBot.create_list(:site, 1) }
    end
  end
end
