# Be sure to restart your server when you modify this file.

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Rails.application.config.session_store :active_record_store

# Ensure we have the `silence` method available on our logger. We use a custom logger
# from govuk_app_config which doesn't have this by default.
Rails.logger.class.include ActiveSupport::LoggerSilence
