#!/bin/bash -xe
export RAILS_ENV=test
export DISPLAY=":99"

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment
bundle exec rake db:reset
bundle exec rake assets:clean assets:precompile
bundle exec rake
bundle exec rake check_for_bad_time_handling
