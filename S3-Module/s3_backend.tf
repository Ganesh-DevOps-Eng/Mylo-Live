terraform {
  backend "s3" {
    bucket = var.bucket_name
    #key    = "/"  i have changed as below
    key    = var.key
    region = var.region
  }
}
