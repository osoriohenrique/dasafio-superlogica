terraform {
  backend "s3" {
    bucket  = "desafio-superlogica"
    key     = "dasafio-superlogica/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}