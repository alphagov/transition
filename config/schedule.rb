# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'
set :output, {:error => 'log/cron.error.log', :standard => 'log/cron.log'}
job_type :rake, 'cd :path && /usr/local/bin/govuk_setenv transition bundle exec rake :task :output'

# Run when the file has just been generated.
# It appears to take ~50 minutes to generate based on the Last Modified HTTP header
#
# At the time of writing, the file is generated twice a day:
# https://github.com/alphagov/whitehall/blob/master/config/schedule.rb#L18
every :day, at: ['3:30am', '1:15pm'] do
  rake 'import:whitehall:mappings'
end
