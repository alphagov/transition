require 'transition/history'

FactoryGirl.define do
  factory :mappings_batch do
    http_status '410'

    paths ['/a', '/b']

    association :site, strategy: :build
    association :user, strategy: :build
  end
end
