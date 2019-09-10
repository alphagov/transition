require 'sidekiq/testing'

# https://github.com/mperham/sidekiq/wiki/Testing#testing-worker-queueing-fake
Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
