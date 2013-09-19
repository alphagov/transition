FactoryGirl.define do
  factory :mapping do
    http_status 410
    path '/about/branding'
    association :site, strategy: :build

    factory :mapping_410

    factory :mapping_with_default_host do
      after(:create) { |mapping| mapping.site.hosts << create(:host) }
    end

  end
end
