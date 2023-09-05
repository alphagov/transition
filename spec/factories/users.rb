FactoryBot.define do
  factory :user do
    name { "Stub User" }
    sequence(:email) { |n| "person-#{n}@example.com" }
    permissions { %w[signin] }

    factory :gds_editor do
      permissions { ["signin", "GDS Editor"] }
    end

    factory :admin do
      permissions { ["signin", "GDS Editor", "admin"] }
    end

    factory :site_manager do
      permissions { ["signin", "Site Manager"] }
    end
  end
end
