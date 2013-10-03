#!/bin/bash
#
# Setup the app from scratch and populate the database.

bundle install
bundle exec rake db:create db:structure:load
bundle exec rake db:seed

bundle exec rake notmodules:sync
bundle exec rake import:all
