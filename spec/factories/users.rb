FactoryGirl.define do
  factory :user do
    name "Stub User"
    sequence(:email) {|n| "person-#{n}@example.com" }
    permissions { ["signin"] }

    factory :gds_transition_manager do
      permissions { ["signin", "GDS Transition Manager"] }
    end
  end
end
