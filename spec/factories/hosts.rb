FactoryGirl.define do
  factory :host do
    sequence(:hostname) {|n| "www-#{n}.example.gov.uk" }
    association :site
  end
end
