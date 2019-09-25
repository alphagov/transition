# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, "/usr/local/bin:/usr/bin:/bin"
set :output, error: "log/cron.error.log", standard: "log/cron.log"
job_type :rake, "cd :path && /usr/local/bin/govuk_setenv transition bundle exec rake :task :output"

# Run when the file has just been generated.
# If it runs while the file is being generated, it will download an incomplete file!
#
# At the time of writing, the file is generated twice a day:
# https://github.com/alphagov/whitehall/blob/master/config/schedule.rb#L18
every :day, at: ["4:15am", "2pm"] do
  rake "import:whitehall:mappings"
end

# every hour 7am-7pm, Mon-Fri
every "0 07-19 * * 1-5" do
  rake "import:dns_details"
end

every :day, at: "3am" do
  rake "clear_expired_sessions"
  rake "clear_old_mappings_batches"
end

every :day, at: ["12:30am", "12:30pm"] do
  rake "import:hits:refresh_materialized"
end
