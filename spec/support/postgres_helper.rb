RSpec.configure do |config|
  config.before(:suite) do
    # Extension does not get propagated to schema.rb
    ActiveRecord::Base.connection.execute('CREATE EXTENSION if NOT EXISTS pgcrypto')
  end
end
