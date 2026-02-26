# uplodate data to s3
# this bucket will be used to load data into redshift using the COPY command, you can also use it to unload data from redshift using the UNLOAD command
resource "aws_s3_object" "jaffle_shop_customers" {
  bucket = aws_s3_bucket.redshift_data_bucket.bucket
  key    = "jaffle_shop_customers.csv"
  source = "${path.module}/data/jaffle_shop_customers.csv"
}

resource "aws_s3_object" "jaffle_shop_orders" {
  bucket = aws_s3_bucket.redshift_data_bucket.bucket
  key    = "jaffle_shop_orders.csv"
  source = "${path.module}/data/jaffle_shop_orders.csv"
}

resource "aws_s3_object" "stripe_payments" {
  bucket = aws_s3_bucket.redshift_data_bucket.bucket
  key    = "stripe_payments.csv"
  source = "${path.module}/data/stripe_payments.csv"
}