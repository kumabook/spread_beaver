# frozen_string_literal: true

Aws.config.update({
  region: "ap-northeast-1",
  credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"] || "xxxx",
                                    ENV["AWS_SECRET_ACCESS_KEY"] || "xxxx"),
})
S3_BUCKET = Aws::S3::Resource.new.bucket(ENV["S3_BUCKET"] || "S3_BUCKET")
S3_SIGNER = Aws::S3::Presigner.new
