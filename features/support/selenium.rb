require 'selenium-webdriver'

options = Selenium::WebDriver::Chrome::Options.new
options.headless!
options.add_argument('no-sandbox')
options.add_argument('disable-dev-shm-usage')

Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome
Capybara.server = :puma, { Silent: true }
