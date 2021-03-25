# Transition

Rails app for managing the transition of websites to GOV.UK. Specifically, it's for the production of and handling
of mappings for use with [Bouncer](https://github.com/alphagov/bouncer).

## Dependencies

* Redis
* PostgreSQL 9.3+ (the app uses materialized views, which were introduced in 9.3).
  This is included in the Trusty dev VM, which is now the default.

## Running the app

The web application itself is run like any other Rails app, for example:

```sh
script/rails s
```

In development, you can run sidekiq to process background jobs:

```sh
bundle exec sidekiq -C config/sidekiq.yml
```

## Style guide

Available at /style, the guide documents how transition is using bootstrap, where the app has diverged from default
styles and any custom styles needed to fill in the gaps.

## Adding data to the transition app

You can add new URLs and update existing configurations for sites and organisations within the Transition app using the [Transition config](https://github.com/alphagov/transition-config) repo.
