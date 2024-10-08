APP_STYLESHEETS = {
  "application.scss" => "application.css",
  "legacy_layout.scss" => "legacy_layout.css",
}.freeze

all_stylesheets = APP_STYLESHEETS.merge(GovukPublishingComponents::Config.all_stylesheets)
Rails.application.config.dartsass.builds = all_stylesheets

Rails.application.config.dartsass.build_options << " --quiet-deps"
