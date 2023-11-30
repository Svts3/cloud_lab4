terraform {
  cloud {
    organization = "svsts3"
    workspaces {
      name = "lab4-workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }

}

provider "aws" {
  region = "eu-central-1"
}





