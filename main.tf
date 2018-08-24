provider "aws" {
  region     = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# Create bucket to upload source
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.app_name}"
  acl    = "public-read"
}

# Upload source code to S3 bucket
resource "aws_s3_bucket_object" "app_source" {
  bucket = "${aws_s3_bucket.app_bucket.bucket}"
  acl    = "public-read"
  key    = "deps.zip"
  source = "deps.zip"
  etag   = "${md5(file("deps.zip"))}"
}
