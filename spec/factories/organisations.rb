FactoryGirl.define do
  factory :organisation do
    sequence(:abbr) {|n| "org#{n}" }
    title 'Orgtastic'
    launch_date { 1.month.ago }
  end
end