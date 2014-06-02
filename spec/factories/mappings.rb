require 'transition/history'

FactoryGirl.define do
  factory :mapping do
    ignore do
      as_user { build(:user, id: 1, name: 'test user') }
    end

    type 'archive'
    sequence(:path) { |n| "/foo-#{n}" }
    association :site, strategy: :build

    factory :archived
    factory :redirect do
      type 'redirect'
      new_url 'https://www.gov.uk/somewhere'
    end

    before(:create) do |_, evaluator|
      if PaperTrail.enabled? && PaperTrail.whodunnit.nil? && evaluator.as_user
        Transition::History.set_user!(evaluator.as_user)
      end
    end

    trait :with_versions do
      # Will create a new version only within specs with metadata versioning: true
      after(:create) { |mapping| mapping.update_attributes(new_url: 'http://somewhere.new') }
      after(:create) { |mapping| create(:host, site: mapping.site) }
    end

    trait :archive_created_with_http_status do
      after(:create) do |old_style_mapping|
        last_version = old_style_mapping.versions.last

        YAML.load(last_version.object_changes).tap do |changes|
          changes[:http_status] = [nil, '410']
          changes.delete(:type)
          last_version.update_attribute(:object_changes, changes)
        end
      end
    end

  end
end
