# The S3 bucket that will store state.
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name    

  force_destroy = true          
}

# Best practice: keep a version history of the state file (recover from mistakes).
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"              
  }
}

# Best practice: encrypt the state at rest (it can contain secrets).
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"     
    }
  }
}

# Best practice: block ALL public access to the state bucket.
resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true 
  block_public_policy     = true 
  ignore_public_acls      = true 
  restrict_public_buckets = true 
}

# DynamoDB table used for state LOCKING. Terraform requires a specific key.
resource "aws_dynamodb_table" "locks" {
  name         = var.lock_table_name        
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"        
  attribute {
    name = "LockID"
    type = "S"                   
  }
}