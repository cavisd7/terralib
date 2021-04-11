terraform {
    backend "s3" {
        bucket = "main-org-infra-tf-state"
        encrypt = true 
        key = "stages/infra/terraform.tfstate"
        region = "us-east-2"

        //profile = ""
    }
}