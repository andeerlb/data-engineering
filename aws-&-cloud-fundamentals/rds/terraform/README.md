# RDS Terraform Configuration

This Terraform configuration provisions an AWS RDS (Relational Database Service) PostgreSQL instance with associated networking resources.

### Input Variables

Key variables defined in `variables.tf`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `db_identifier` | RDS instance identifier | `my-rds-instance` |
| `database_name` | Initial database name | `mydb` |
| `master_username` | Master username | - |
| `master_password` | Master password (sensitive) | - |
| `engine` | Database engine | `postgres` |
| `engine_version` | Engine version | `16.1` |
| `instance_class` | Instance type | `db.t3.micro` |
| `allocated_storage` | Storage size in GB | `20` |
| `multi_az` | Enable Multi-AZ deployment | `false` |
| `backup_retention_period` | Backup retention in days | `7` |

## Notes

- **Publicly Accessible**: Set to `true` for development. For production, use private subnets and VPN/bastion hosts.
- **Skip Final Snapshot**: Set to `true` to allow quick teardown. For production, set to `false`.
- **Storage Encrypted**: Enabled by default for security.
- **CloudWatch Logs**: Enabled for PostgreSQL and upgrade logs.
