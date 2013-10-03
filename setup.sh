#!/bin/bash
#
# Setup the app from scratch and populate the database.

bundle install
bundle exec rake db:create db:structure:load db:seed notmodules:sync import:all
