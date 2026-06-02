variable "aws_region" {
  description = "AWS region (any value works for local)"
  type        = string
  default     = "us-east-1"
}

variable "dynamodb_endpoint" {
  description = "DynamoDB Local endpoint"
  type        = string
  default     = "http://localhost:8000"
}
