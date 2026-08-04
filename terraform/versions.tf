terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.49"
    }
  }

  backend "s3" {
    bucket               = "corpershub-terraform-statefile" # "corpershub-statefile"
    key                  = "corpershub.tfstate"
    region               = "eu-west-1"
    encrypt              = true
    use_lockfile         = true
    workspace_key_prefix = "envs"
    # assume_role = {
    #   role_arn = "arn:aws:iam::088668668196:role/Admin"
    # }
  }
}

