# Create S3 Bucket 
resource "aws_s3_bucket" "yakout-bucket" { 
    bucket = "yakout-bucket" 
    force_destroy = true
    tags = {
        Name = "yakout-bucket" 
        }
        }