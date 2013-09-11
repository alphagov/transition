FactoryGirl.define do
  factory :user do
    name "Stub User"
    sequence(:email) {|n| "person-#{n}@example.com" }
    permissions { ["signin"] }
  end
end
