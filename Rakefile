#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks

Rake::Task[:default].clear
task default: [:spec, :cucumber, "jasmine:ci", :check_for_bad_time_handling]
