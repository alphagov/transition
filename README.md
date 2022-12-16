# Transition

Rails app for managing the transition of websites to GOV.UK. Specifically, it's for the production of and handling
of mappings for use with [Bouncer](https://github.com/alphagov/bouncer).

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the tests

```
bundle exec rake
```

### Running the worker

```
bundle exec sidekiq -C config/sidekiq.yml
```

### Style guide

Available at /style, the guide documents how transition is using bootstrap, where the app has diverged from default
styles and any custom styles needed to fill in the gaps.

### Adding data

You can add new URLs and update existing configurations for sites and organisations within the Transition app using the [Transition config](https://github.com/alphagov/transition-config) repo.

To import locally, clone the config repo into `data/` and then run:

```
bundle exec rake import:all:orgs_sites_hosts
```

## Licence

[MIT License](LICENCE)
