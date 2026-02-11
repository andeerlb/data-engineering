# Terraform AWS Redshift Deployment

This project provisions an **Amazon Redshift cluster** using Terraform, including:

* A dedicated VPC (`10.0.0.0/16`)
* Two private subnets in different Availability Zones
* A Security Group allowing inbound traffic on port `5439`
* A Redshift Subnet Group
* A Redshift Cluster (single-node by default)
* No public access by default

---

# Requirements

Before running this project, ensure you have:

* Terraform >= 1.5.0
* AWS CLI configured (`aws configure`)
* Valid AWS credentials with permissions for:

  * EC2
  * VPC
  * Redshift
  * IAM (if extending later)

Check Terraform version:

```bash
terraform version
```

---

# Configuration

## Update `terraform.tfvars`

Edit the credentials file:

```hcl
master_username = "admin"
master_password = "YourStrongPassword123!"
```


---

# Deployment

## Initialize Terraform

```bash
terraform init
```

This downloads required providers.

---

## Validate Configuration

```bash
terraform validate
```

---

## Preview Changes

```bash
terraform plan
```

This shows what will be created.

---

## Apply Infrastructure

```bash
terraform apply
```

After deployment, Terraform will output:

* Redshift endpoint
* Port
* JDBC connection URL

---

# Destroy Infrastructure

To remove all resources:

```bash
terraform destroy
```

Confirm with `yes`.

Important:

* `skip_final_snapshot = true` is enabled.
* The cluster will be deleted permanently.
* No backup will be created.

If you want safer deletion, modify:

```hcl
skip_final_snapshot = false
```

And specify:

```hcl
final_snapshot_identifier = "final-snapshot-name"
```

--- 

# Customization

You can modify:

| Variable              | Description               |
| --------------------- | ------------------------- |
| `cluster_type`        | single-node or multi-node |
| `number_of_nodes`     | Required for multi-node   |
| `node_type`           | Instance type             |
| `environment`         | Tagging                   |
| `allowed_cidr_blocks` | Access control            |