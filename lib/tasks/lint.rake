desc "Run govuk-lint with similar params to CI"
task "lint" do
  sh "bundle exec govuk-lint-ruby --rails --diff --format clang app spec lib" unless ENV['nolint'].present?
end

desc "Run default rake task without lint"
task "nolint" do
  ENV['nolint'] = 'thanks'
  Rake::Task['default'].invoke
end
