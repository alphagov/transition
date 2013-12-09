FactoryGirl.define do
  factory :mapping do
    http_status '410'
    path '/about/branding'
    association :site, strategy: :build

    factory :mapping_410


    factory :archived
    factory :redirect do
      http_status '301'
      new_url 'https://www.gov.uk/somewhere'
    end

    factory :mapping_with_versions do
      # Will create a new version only within specs with metadata versioning: true
      after(:create) { |mapping| mapping.update_attributes(new_url: 'http://somewhere.new') }
      after(:create) { |mapping| mapping.site.hosts << create(:host) }
    end

  end
end
