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
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Transition
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

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

    # Set asset path to be application specific so that we can put all GOV.UK
    # assets into an S3 bucket and distinguish app by path.
    config.assets.prefix = "/assets/transition"

    # TODO: this is no longer an encouraged pattern for dynamic error pages
    # as it has many edgecases (See: https://github.com/rails/rails/pull/17815)
    # We should consider changing how we do this.
    # Route exceptions to our custom error pages.
    config.exceptions_app = routes

    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Using a sass css compressor causes a scss file to be processed twice (once
    # to build, once to compress) which breaks the usage of "unquote" to use
    # CSS that has same function names as SCSS such as max
    config.assets.css_compressor = nil

    # Sanitize and cleanup invalid UTF-8 characters in request URIs, headers and cookies
    config.middleware.insert 0, Rack::UTF8Sanitizer, sanitize_null_bytes: true
  end
end
