require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Transition
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # TODO: this is no longer an encouraged pattern for dynamic error pages
    # as it has many edgecases (See: https://github.com/rails/rails/pull/17815)
    # We should consider changing how we do this.
    # Route exceptions to our custom error pages.
    config.exceptions_app = routes
  end
end
