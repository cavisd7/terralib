/* Access master account for administration */
provider "aws" {
    region                  = "us-east-2"
    profile                 = var.aws_profile_name
    shared_credentials_file = "~/.aws/credentials"
}