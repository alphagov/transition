if Rails.env.development?
  require 'factory_bot'
  FactoryBot.find_definitions
  unless User.find_by_email("test@example.com")
    u             = User.new
    u.email       = "test@example.com"
    u.name        = "Test User"
    u.permissions = ["signin", "admin"]
    u.organisation_content_id = '96ae61d6-c2a1-48cb-8e67-da9d105ae381'
    u.save
  end

  organisation = FactoryBot.create(:organisation)
  FactoryBot.create(:site, :with_mappings_and_hits, organisation: organisation)
  Transition::Import::DailyHitTotals.from_hits!
  Transition::Import::HitsMappingsRelations.refresh!
end
