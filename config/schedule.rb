# default cron env is "/usr/bin:/bin" which is not sufficient as govuk_env is in /usr/local/bin
env :PATH, "/usr/local/bin:/usr/bin:/bin"
set :output, error: "log/cron.error.log", standard: "log/cron.log"
job_type :rake, "cd :path && /usr/local/bin/govuk_setenv transition bundle exec rake :task :output"

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
