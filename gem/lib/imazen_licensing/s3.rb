require 'fog/aws'

module ImazenLicensing
  module S3
    class S3LicenseUploader

      attr_accessor :connection

      def initialize(aws_id: nil, aws_secret: nil)
        @connection = Fog::Storage::AWS.new({
          aws_access_key_id: aws_id,
          region: 'us-west-2',
          aws_secret_access_key: aws_secret}.select{|k,v| v})
      end 


      def bucket_name
        "licenses.imazen.net"
      end

      def bucket_url
        "https://s3-us-west-2.amazonaws.com/licenses.imazen.net/"
      end

      # def do_generate(bucket_name, object_key)
      #   expire_time = Time.now.advance(minutes: 48 * 60).to_i
      #   storage.directories.new(key: bucket_name).files.new(key: object_key).url(expire_time)
      # end

      def upload_license(license_id:, license_secret:, full_body: )
        key = "v1/licenses/latest/#{license_secret}.txt"
        url = bucket_url + key

        directory = connection.directories.new(key: bucket_name)
        directory.files.create(
          :key => key,
          :body => StringIO.new(full_body, "r:UTF-8"),
          :public => true,
          :content_type => "text/plain; charset=utf-8"
          )
        url 
      end
    end 
  end
end
