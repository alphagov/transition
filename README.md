# Transition

Rails app for managing the transition of websites to GOV.UK. Specifically, it's for adding and deleting sites, hostnames, and mappings for use with [Bouncer](https://github.com/alphagov/bouncer).

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

## Adding a new site

Follow the instructions in the [GOV.UK  Developer docs](https://docs.publishing.service.gov.uk/manual/transition-a-site.html)

## Example application URLs

* https://transition.staging.publishing.service.gov.uk/
* https://transition.staging.publishing.service.gov.uk/organisations/air-accidents-investigation-branch
* https://transition.staging.publishing.service.gov.uk/sites/aaib
* https://transition.staging.publishing.service.gov.uk/sites/aaib/mappings/939694/edit
* https://transition.staging.publishing.service.gov.uk/sites/aaib/mappings/bulk_add_batches/new
* https://transition.staging.publishing.service.gov.uk/sites/aaib/mappings/import_batches/new
* https://transition.staging.publishing.service.gov.uk/sites/aaib/hits/summary

## Glossary of terms

A glossary of the terms used can be found in this [blog post](https://insidegovuk.blog.gov.uk/2014/03/17/transition-technical-glossary/).

## Licence

[MIT License](LICENCE)
