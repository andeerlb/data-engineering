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