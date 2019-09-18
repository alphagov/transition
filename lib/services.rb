require 'aws-sdk-s3'

module Services
  def self.s3
    @s3 ||= Aws::S3::Client.new(aws_options)
  end

  def self.aws_options
    options = {}
    options.merge!(profile: aws_profile) if aws_profile
    options.merge!(region: aws_region) if aws_region
    options.merge!(access_key_id: access_key_id) if access_key_id
    options.merge!(secret_access_key: secret_access_key) if secret_access_key
    options
  end

  def self.aws_profile
    ENV.fetch('AWS_PROFILE', nil)
  end

  def self.aws_region
    ENV.fetch('AWS_REGION', nil)
  end

  def self.access_key_id
    ENV.fetch('AWS_ACCESS_KEY_ID', nil)
  end

  def self.secret_access_key
    ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
  end
end
