terraform {
  backend "s3" {
    bucket         = "backend-state102"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lock-table"
    encrypt        = true
  }
}
