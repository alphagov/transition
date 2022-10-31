if Rails.env.development?

  # See https://www.gov.uk/api/organisations/cabinet-office
  cabinet_office_content_id = "96ae61d6-c2a1-48cb-8e67-da9d105ae381"

  unless User.find_by(email: "test@example.com")
    u             = User.new
    u.email       = "test@example.com"
    u.name        = "Test User"
    u.permissions = %w[signin admin]
    u.organisation_content_id = cabinet_office_content_id
    u.save!
  end

  unless Organisation.find_by(whitehall_slug: "cabinet-office")
    Organisation.create!(
      title: "Cabinet Office",
      ga_profile_id: "46600000",
      whitehall_type: "Ministerial department",
      whitehall_slug: "cabinet-office",
      content_id: cabinet_office_content_id,
    )
  end

  unless Site.find_by(abbr: "cabinetoffice")
    Site.create!(
      abbr: "cabinetoffice",
      homepage: "https://www.gov.uk/government/organisations/cabinet-office",
      launch_date: "2012-08-15 00:00:00",
      tna_timestamp: "2012-08-16 22:40:15",
      organisation: Organisation.find_by(whitehall_slug: "cabinet-office"),
      query_params: "",
    )
  end

  unless Host.find_by(hostname: "www.cabinetoffice.gov.uk")
    Host.create!(
      hostname: "www.cabinetoffice.gov.uk",
      site: Site.find_by(abbr: "cabinetoffice"),
    )
  end

  unless Mapping.find_by(path: "/interesting-news-story")
    Transition::History.as_a_user(User.first) do
      Mapping.create!(
        site: Site.find_by(abbr: "cabinetoffice"),
        path: "/interesting-news-story",
        new_url: "https://www.gov.uk/new-url-for-interesting-news-story",
        type: "redirect",
      )
    end
  end

  unless Mapping.find_by(path: "/interesting-archived-news-story")
    Transition::History.as_a_user(User.first) do
      Mapping.create!(
        site: Site.find_by(abbr: "cabinetoffice"),
        path: "/interesting-archived-news-story",
        type: "archive",
      )
    end
  end
end
