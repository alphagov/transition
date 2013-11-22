# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'
set :output, {:error => 'log/cron.error.log', :standard => 'log/cron.log'}
job_type :run_script, 'cd :path && RAILS_ENV=:environment /usr/local/bin/govuk_setenv transition script/:task :output'

# Run when the file has just been generated.
# It appears to take ~50 minutes to generate based on the Last Modified HTTP header
#
# At the time of writing, the file is generated twice a day:
# https://github.com/alphagov/whitehall/blob/master/config/schedule.rb#L18
every :day, at: ['3:30am', '1:15pm'] do
  run_script 'import_whitehall_document_urls'
end
