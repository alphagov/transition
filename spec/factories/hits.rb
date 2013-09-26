FactoryGirl.define do
  factory :hit do
    path 'http://somewhere'
    count 20
    http_status 301

    association :host
  end

end
