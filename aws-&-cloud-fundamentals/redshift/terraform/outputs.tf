output "redshift_endpoint" {
  value = aws_redshift_cluster.redshift.endpoint
}

output "redshift_port" {
  value = aws_redshift_cluster.redshift.port
}

output "redshift_jdbc_url" {
  value = "jdbc:redshift://${aws_redshift_cluster.redshift.endpoint}:${aws_redshift_cluster.redshift.port}/${var.database_name}"
}

output "iam_role_arn" {
  value = aws_iam_role.redshift_role.arn
}

output "aws_region" {
  value = var.aws_region
}

output "s3_bucket_name" {
  value = aws_s3_bucket.redshift_data_bucket.bucket
}

output "redshift_copy_commands" {
  value = <<-EOT
copy jaffle_shop.customers(id, first_name, last_name)
from 's3://${aws_s3_bucket.redshift_data_bucket.bucket}/jaffle_shop_customers.csv'
iam_role '${aws_iam_role.redshift_role.arn}'
region '${var.aws_region}'
delimiter ','
ignoreheader 1
acceptinvchars;

copy jaffle_shop.orders(id, user_id, order_date, status)
from 's3://${aws_s3_bucket.redshift_data_bucket.bucket}/jaffle_shop_orders.csv'
iam_role '${aws_iam_role.redshift_role.arn}'
region '${var.aws_region}'
delimiter ','
ignoreheader 1
acceptinvchars;

copy stripe.payments(id, orderid, paymentmethod, status, amount, created)
from 's3://${aws_s3_bucket.redshift_data_bucket.bucket}/stripe_payments.csv'
iam_role '${aws_iam_role.redshift_role.arn}'
region '${var.aws_region}'
delimiter ','
ignoreheader 1
acceptinvchars;
EOT
}