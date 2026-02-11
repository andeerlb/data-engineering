output "redshift_endpoint" {
  value = aws_redshift_cluster.redshift.endpoint
}

output "redshift_port" {
  value = aws_redshift_cluster.redshift.port
}

output "redshift_jdbc_url" {
  value = "jdbc:redshift://${aws_redshift_cluster.redshift.endpoint}:${aws_redshift_cluster.redshift.port}/${var.database_name}"
}
