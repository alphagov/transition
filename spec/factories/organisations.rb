FactoryGirl.define do
  factory :organisation do
    sequence(:abbr) {|n| "org#{n}" }
    title 'Orgtastic'
  end
end