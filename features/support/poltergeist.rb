require 'capybara/poltergeist'
require 'phantomjs'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    phantomjs: Phantomjs.path,
    window_size: [1366, 768],
    debug: false,
    js_errors: false,
  })
end

Capybara.javascript_driver = :poltergeist
