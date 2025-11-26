terraform {
  backend "s3" {
    bucket       = "jenkinesprojecttosavestatefile"
    key          = "eks/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

