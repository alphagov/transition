FactoryBot.define do
  factory :whitelisted_host do
    sequence(:hostname) { |n| "host-#{n}" }
  end
end
