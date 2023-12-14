FactoryBot.define do
  factory :site_form do
    organisation_slug { "air-accidents-investigation-branch" }
    homepage { "https://www.gov.uk/government/organisations/air-accidents-investigation-branch" }
    tna_timestamp { "20141104112824" }
    hostname { "www.aaib.gov.uk" }

    trait :with_optional_fields do
      homepage_title { "Air accidents investigation branch" }
      homepage_furl { "www.gov.uk/aaib" }
      global_type { "redirect" }
      global_new_url { "https://www.gov.uk/government/organisations/air-accidents-investigation-branch/about" }
      query_params { "file" }
      global_redirect_append_path { true }
      special_redirect_strategy { "via_aka" }
    end

    trait :with_blank_optional_fields do
      homepage_title { "" }
      homepage_furl { "" }
      global_type { "" }
      global_new_url { "" }
      query_params { "" }
      global_redirect_append_path { false }
      special_redirect_strategy { "" }
    end

    trait :with_aliases do
      aliases { "aaib.gov.uk,aaib.com" }
    end
  end
end
