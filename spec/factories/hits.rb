FactoryGirl.define do
  factory :hit do
    path '/article/123'
    count 20
    http_status '301'
    hit_on 1.week.ago

    association :host

    trait :error do
      http_status '404'
    end

    trait :redirect do
      http_status '301'
    end
  end
end
