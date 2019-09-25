FactoryBot.define do
  factory :daily_hit_total do
    http_status { "301" }
    count { 10 }
    total_on { 1.week.ago }

    association :host
  end
end
