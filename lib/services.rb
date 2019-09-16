require 'aws-sdk-s3'

module Services
  def self.s3
    @s3 ||= Aws::S3::Client.new(profile: ENV['AWS_PROFILE'], region: ENV['AWS_REGION'])
  end
end
