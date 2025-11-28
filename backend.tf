terraform {
  backend "s3" {
    bucket       = "jenkinesprojecttosavestatefile"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
 //  use_lockfile = true
  }
}

