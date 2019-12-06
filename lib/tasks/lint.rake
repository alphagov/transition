desc "Run rubocop with similar params to CI"
task lint: :environment do
  next if ENV["JENKINS"]

  sh "bundle exec rubocop --format clang app spec lib"
end
