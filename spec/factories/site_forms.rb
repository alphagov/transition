FactoryBot.define do
  factory :site_form do
    abbr { "aaib" }
    organisation_slug { "air-accidents-investigation-branch" }
    homepage { "https://www.gov.uk/government/organisations/air-accidents-investigation-branch" }
    tna_timestamp { "20141104112824" }
    hostname { "www.aaib.gov.uk" }
    homepage_title { "Air accidents investigation branch" }

    trait :with_optional_fields do
      homepage_furl { "www.gov.uk/aaib" }
      global_type { "redirect" }
      global_new_url { "https://www.gov.uk/government/organisations/air-accidents-investigation-branch/about" }
      query_params { "file" }
      global_redirect_append_path { true }
      special_redirect_strategy { "via_aka" }
    end

    trait :with_aliases do
      aliases { "aaib.gov.uk,aaib.com" }
    end

    trait :with_extra_organisations do
      extra_organisations { ["The adjudicator's office", "Government digital service"] }
    end
  end
end
