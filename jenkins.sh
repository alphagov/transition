#!/bin/bash -xe
export RAILS_ENV=test
export DISPLAY=":99"

bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment
bundle exec rake db:reset
bundle exec rake assets:clean assets:precompile
bundle exec rake
bundle exec rake check_for_bad_time_handling
