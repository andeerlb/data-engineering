# AWS Configuration
aws_region = "us-east-1"

# RDS Configuration
db_identifier = "my-rds-instance"
database_name = "mydb"
master_username = "admin"
# master_password should be set via environment variable or secure input
# export TF_VAR_master_password="your-secure-password"

# Database Engine
engine         = "postgres"
engine_version = "16.1"

# Instance Configuration
instance_class    = "db.t3.micro"
allocated_storage = 20
storage_type      = "gp3"

# High Availability
multi_az = false

# Backup Configuration
backup_retention_period = 7

# Environment
environment = "dev"

# Network Security
allowed_cidr_blocks = ["0.0.0.0/0"] # CHANGE THIS to your specific IP/CIDR for security
