FactoryGirl.define do
  factory :organisation do
    title 'Orgtastic'

    ga_profile_id '46600000'
    whitehall_type 'Executive non-departmental public body'
    whitehall_slug { |n| "org-#{n}" }
  end
end
