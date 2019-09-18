# Transition

Rails app for managing the transition of websites to GOV.UK. Specifically, it's for the production of and handling
of mappings for use with [Bouncer](https://github.com/alphagov/bouncer).

## Dependencies

* Redis
* PostgreSQL 9.3+ (the app uses materialized views, which were introduced in 9.3).
  This is included in the Trusty dev VM, which is now the default.

## Set up the database

```sh
bundle exec rake db:setup
```

## Seed the database

FactoryBot will seed some dummy data to get started with.

```sh
bundle exec rake db:seed
```

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

## Deployments

This service is hosted on dxw's container platform called Dalmation.

Deployments from this applications point of view are done by merging new code into either the develop branch for staging or the master branch for production. Once pushed [DockerHub](https://cloud.docker.com/u/thedxw/repository/docker/thedxw/transition) will build and a new Docker Image.

### Dalmation

Once complete. The deployment process to provision this new container hands over to Dalmation.

This application has a [separate private GitHub repository](https://github.com/dxw/ukri-transition-dalmatian-config) that is responsible for provisioning the required infrastructure. This includes the [Bouncer service](https://github.com/dxw/bouncer) and is done using Terraform.

The way to deploy new containers is manual and involves downtime:

1. Within AWS select the dxw-dalmation-1 role
1. Visit the ECS service
1. Select the intended cluster (be careful as this cluster is shared)
1. Click 'Tasks'
1. Search by 'transition'
1. Select all tasks running for the app in the intended environment
1. Click 'stop'
1. Those containers will restart and pull the new version of the containers
