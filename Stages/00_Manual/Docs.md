Run the CloudFormation template to create the initial user in the root account which will be used to run the proceeding terraform modules. 

The created user's password, access key id, and secret access key will be stored in AWS Secrets Manager

The access keys can be removed from Secrets Manager after written down.

A password reset will be required on next login with the created IAM user.