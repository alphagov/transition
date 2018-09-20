require 'aws-sdk-s3'

module Services
  def self.s3
    @s3 ||= Aws::S3::Client.new
  end
end
