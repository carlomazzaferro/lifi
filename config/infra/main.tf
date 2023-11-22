terraform {
  backend "s3" {
    bucket = "lifi-terraform-infra-state"
    key    = "state"
    region = "us-east-1"
  }
}


provider "aws" {
  region = var.region
}

module "iam" {
  source = "../modules/iam"
}

module "ecr" {
  source           = "../modules/ecr"
  repository_names = ["lifi"]
}
