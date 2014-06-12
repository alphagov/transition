require 'transition/history'

FactoryGirl.define do
  factory :bulk_add_batch do
    type 'archive'
    paths ['/a', '/b']
    state 'unqueued'

    association :site, strategy: :build
    association :user, strategy: :build
  end
end
