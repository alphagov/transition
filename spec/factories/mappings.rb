require "transition/history"

FactoryBot.define do
  factory :mapping do
    transient do
      as_user { build(:user, id: 1, name: "test user") }
    end

    type { "archive" }
    sequence(:path) { |n| "/foo-#{n}" }
    association :site, strategy: :build

    factory :archived
    factory :redirect do
      type { "redirect" }
      new_url { "https://www.gov.uk/somewhere" }
    end
    factory :unresolved do
      type { "unresolved" }
    end

    before(:create) do |_, evaluator|
      if PaperTrail.enabled? && PaperTrail.request.whodunnit.nil? && evaluator.as_user
        Transition::History.set_user!(evaluator.as_user)
      end
    end

    trait :with_versions do
      # Will create a new version only within specs with metadata versioning: true
      after(:create) { |mapping| mapping.update(new_url: "http://somewhere.new") }
      after(:create) { |mapping| create(:host, site: mapping.site) }
    end
  end
end
