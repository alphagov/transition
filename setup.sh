#!/bin/bash
#
# Setup the app from scratch and populate the database.

bundle install
bundle exec rake db:create db:structure:load

if [ ! -d data/redirector ]; then
  mkdir -p data && git clone git@github.com:alphagov/redirector data/redirector
else
  cd data/redirector && git pull
  cd ../..
fi

bundle exec rake db:seed
