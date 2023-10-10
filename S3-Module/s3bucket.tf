resource "aws_s3_bucket" "aws_s3_bucket" {
  bucket = "${var.bucket_name}-s3-bucket"
  # region = var.region
}

resource "aws_s3_bucket_versioning" "aws_s3_bucket_versioning" {
  bucket = aws_s3_bucket.aws_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

