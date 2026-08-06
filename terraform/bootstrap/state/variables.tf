# Inputs to this config. Variables keep values out of the code (best practice).
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"           # hint: the region you configured, e.g. us-east-1
}

variable "state_bucket_name" {
  description = "Globally-unique S3 bucket name that will hold Terraform state"
  type        = string
  # no default on purpose — you pass it in. hint: bucket names are GLOBALLY unique,
  # lowercase, e.g. techchallenge2-tfstate-<your-account-id>
}

variable "lock_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "terraform-lock"           # hint: something like terraform-locks
}