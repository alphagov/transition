require 'transition/history'

RSpec.configure do |config|
  config.before :each do
    Transition::History.clear_user!
  end

  config.before :all do
    PaperTrail.enabled = false
  end

  config.before :all, versioning: true do
    PaperTrail.enabled = true
  end

  config.after :all, versioning: true do
    PaperTrail.enabled = false
  end
end
