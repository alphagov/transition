FactoryGirl.define do
  factory :mapping do
    http_status 410
    path '/about/branding'
    association :site, strategy: :build

    factory :mapping_410

    factory :mapping_with_default_host do
      after(:create) { |mapping| mapping.site.hosts << create(:host) }
    end

    factory :mapping_with_versions do
      # Will create a new version only within specs with metadata versioning: true
      after(:create) { |mapping| mapping.update_attributes(new_url: 'http://somewhere.new') }
    end

  end
end
