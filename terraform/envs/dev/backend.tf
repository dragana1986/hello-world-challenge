# Store THIS env's state in the bucket your bootstrap created.
terraform {
  backend "s3" {
    bucket       = "hello-world-tfstate-dg"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}