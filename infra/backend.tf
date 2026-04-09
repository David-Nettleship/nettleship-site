terraform {
  backend "s3" {
    bucket = "terraform-state-304707804854"
    key    = "nettleship-site/infra.tfstate"
    region = "eu-west-2"
  }
}
