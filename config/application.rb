require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Transition
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

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
  end
end
