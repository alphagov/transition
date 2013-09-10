# Create test user
#
unless User.find_by_email("test@example.com")
  u = User.new
  u.email = "test@example.com"
  u.name = "Test User"
  u.permissions = ["signin"]
  u.save
end
