terraform {
    backend "s3" {
        bucket = "main-org-infra-tf-state"
        encrypt = true 
        key = "stages/bootstrap/terraform.tfstate"
        region = "us-east-2"
        profile = "personal-root-Admin01"
    }
}