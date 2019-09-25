require "transition/history"
require "paper_trail/frameworks/rspec"

RSpec.configure do |config|
  config.before :each do
    Transition::History.clear_user!
  end
end
