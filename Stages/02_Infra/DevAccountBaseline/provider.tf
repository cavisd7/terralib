/* Access dev account for administration by assuming the organization created role in child account */
provider "aws" {
    region                  = "us-east-2"
    profile                 = "tmp-tf-user"
    shared_credentials_file = "~/.aws/credentials"
}