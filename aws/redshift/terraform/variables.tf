variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_identifier" {
  type    = string
  default = "my-redshift-cluster"
}

variable "database_name" {
  type    = string
  default = "dev"
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type      = string
  sensitive = true
}

variable "node_type" {
  type    = string
  default = "ra3.large"
}

variable "cluster_type" {
  type    = string
  default = "single-node"
}

variable "number_of_nodes" {
  type    = number
  default = 2
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "allowed_cidr_blocks" {
  type = list(string)
  default = ["0.0.0.0/0"]
}
