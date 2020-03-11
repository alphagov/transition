Before("@allow-rescue") do
  # Turn off the default debug_exceptions middleware.  This middleware
  # sits before the show_exceptions middleware that delegates to our
  # custom exceptions_app when an exception is raised.  If the request is
  # local debug_exceptions will handle the exception and show the rails
  # debug template instead of raising the exception which means
  # show_exceptions middleware can't deal with it and we don't get our
  # custom errors
  Rails.application.config.consider_all_requests_local = false
  Rails.application.config.action_dispatch.show_exceptions = true
  # We change the config setting *and* the env_config as although
  # env_config is constructed from the config setting, it is memoized
  # so won't pick up the config setting changes
  Rails.application.env_config["action_dispatch.show_exceptions"] = true
  Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false
end

Before("not @allow-rescue") do
  # Turn on the default debug exceptions app for local requests
  Rails.application.config.consider_all_requests_local = true
  Rails.application.config.action_dispatch.show_exceptions = false
  Rails.application.env_config["action_dispatch.show_exceptions"] = false
  Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = true
end
