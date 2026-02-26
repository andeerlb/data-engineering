# iam role and policy for Redshift to access S3
# iam role is attached to the cluster, allowing it to read/write data to S3 for COPY/UNLOAD operations
resource "aws_iam_role" "redshift_role" {
  name = "redshift-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# iam policy that allows Redshift to access the S3 bucket
# iam policy is attached to the role, allowing it to read/write data to S3 for COPY/UNLOAD operations
resource "aws_iam_policy" "redshift_s3_policy" {
  name = "redshift-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.redshift_data_bucket.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.redshift_data_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_attach" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = aws_iam_policy.redshift_s3_policy.arn
}

# Subnet Group
resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name = "redshift-subnet-group"
  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

# cluster
resource "aws_redshift_cluster" "redshift" {
    cluster_identifier = var.cluster_identifier
    database_name      = var.database_name
    master_username    = var.master_username
    master_password    = var.master_password

    node_type       = var.node_type
    cluster_type    = var.cluster_type
    number_of_nodes = var.cluster_type == "multi-node" ? var.number_of_nodes : null

    vpc_security_group_ids    = [aws_security_group.redshift_sg.id]
    cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
    iam_roles = [aws_iam_role.redshift_role.arn]

    publicly_accessible                  = true
    skip_final_snapshot                  = true
    availability_zone_relocation_enabled = false

    encrypted = true

    tags = {
        Environment = var.environment
    }
}