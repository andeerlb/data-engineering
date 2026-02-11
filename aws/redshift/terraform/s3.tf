# s3 bucket to load data into redshift
# this bucket will be used to load data into redshift using the COPY command, you can also use it to unload data from redshift using the UNLOAD command
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "redshift_data_bucket" {
  bucket = "redshift-data-bucket-${random_id.bucket_suffix.hex}"
  tags = {
    Name = "redshift-data-bucket"
  }
}