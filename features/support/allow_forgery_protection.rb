# Don't disable request forgery protection for features. We want to be sure that
# authenticity_token is included in all forms which require it.
ActionController::Base.allow_forgery_protection = true
