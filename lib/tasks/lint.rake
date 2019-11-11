desc "Run rubocop with similar params to CI"
task :lint do
  next if ENV["JENKINS"]

  sh "bundle exec rubocop --diff --format clang app spec lib"
end
