# Security Group
resource "aws_security_group" "redshift_sg" {
  name   = "redshift-sg"
  vpc_id = aws_vpc.redshift_vpc.id

  ingress {
    description = "Allow Redshift access"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}