require "transition/import/console_job_wrapper"

RSpec.configure do |config|
  config.before(:suite) do
    Transition::Import::ConsoleJobWrapper.active = false
  end
end
