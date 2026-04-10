terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Lambda@Edge functions must be deployed in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
