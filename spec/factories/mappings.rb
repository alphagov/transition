FactoryGirl.define do
  factory :mapping do
    http_status '410'
    sequence(:path) { |n| "/foo-#{n}" }
    association :site, strategy: :build

    factory :archived
    factory :redirect do
      http_status '301'
      new_url 'https://www.gov.uk/somewhere'
    end

    trait :with_versions do
      # Will create a new version only within specs with metadata versioning: true
      after(:create) { |mapping| mapping.update_attributes(new_url: 'http://somewhere.new') }
      after(:create) { |mapping| create(:host, site: mapping.site) }
    end
  end
end
