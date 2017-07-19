#! /usr/bin/env ruby

require 'aws-sdk'

unless ARGV.length == 3
  puts 'Usage: sensu_upload.rb bucket artefact bucket_key'
  exit 1
end

bucket = ARGV[0]
artefact = ARGV[1]
bucket_key = ARGV[2]

s3 = Aws::S3::Resource.new(region: 'us-east-1')
obj = s3.bucket(bucket).object(bucket_key)
obj.upload_file(artefact)
