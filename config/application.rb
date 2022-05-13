require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Transition
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.raise_on_unfiltered_parameters = true

    # Don't require `belongs_to` associations by default.
    config.active_record.belongs_to_required_by_default = false

    # Disable per-form CSRF tokens.
    config.action_controller.per_form_csrf_tokens = false

    # Disable origin-checking CSRF mitigation.
    config.action_controller.forgery_protection_origin_check = false

    # TODO: this is no longer an encouraged pattern for dynamic error pages
    # as it has many edgecases (See: https://github.com/rails/rails/pull/17815)
    # We should consider changing how we do this.
    # Route exceptions to our custom error pages.
    config.exceptions_app = routes

    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
