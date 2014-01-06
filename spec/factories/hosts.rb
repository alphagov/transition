FactoryGirl.define do
  factory :host do
    sequence(:hostname) {|n| "www-#{n}.example.gov.uk" }
    cname nil
    association :site
  end
end
