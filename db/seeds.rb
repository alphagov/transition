if Rails.env.development?
  # Create test user
  #
  unless User.find_by_email("test@example.com")
    u             = User.new
    u.email       = "test@example.com"
    u.name        = "Test User"
    u.permissions = ["signin"]
    u.save
  end
end

puts "To import the data from redirector, plus Hit data, run this: "
puts "  bundle exec rake import:all"
