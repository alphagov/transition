require 'capybara/poltergeist'
require 'phantomjs'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    phantomjs: Phantomjs.path,
    debug: false
  })
end

Capybara.javascript_driver = :poltergeist
