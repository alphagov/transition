FactoryGirl.define do
  factory :mapping do
    http_status 410
    path '/about/branding'
    association :site, strategy: :build

    factory :mapping_410
  end
end
