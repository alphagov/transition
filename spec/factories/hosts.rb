FactoryGirl.define do
  factory :host do
    sequence(:hostname) {|n| "www-#{n}.example.gov.uk" }
  end
end
