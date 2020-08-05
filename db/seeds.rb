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
end
