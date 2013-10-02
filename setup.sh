#!/bin/bash
#
# Setup the app from scratch and populate the database.

bundle install
bundle exec rake db:create db:structure:load
bundle exec rake db:seed

if [ ! -d data/redirector ]; then
  mkdir -p data && git clone git@github.com:alphagov/redirector data/redirector
else
  cd data/redirector && git pull
  cd ../..
fi

if [ ! -d data/transition-stats ]; then
  mkdir -p data && git clone git@github.com:alphagov/transition-stats data/transition-stats
else
  cd data/transition-stats && git pull
  cd ../..
fi

bundle exec rake db:import:all
