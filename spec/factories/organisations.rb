FactoryGirl.define do
  factory :organisation do
    sequence(:abbr) {|n| "org#{n}" }
    title 'Orgtastic'
    launch_date { 1.month.ago }

    ga_profile_id '46600000'
  end
end
