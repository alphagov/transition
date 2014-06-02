FactoryGirl.define do
  factory :user do
    name "Stub User"
    sequence(:email) {|n| "person-#{n}@example.com" }
    permissions { ["signin"] }

    factory :gds_editor do
      permissions { ["signin", "GDS Editor"] }
    end
  end
end
