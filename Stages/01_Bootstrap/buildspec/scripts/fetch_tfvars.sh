#!/bin/bash

#Download .tfvars files from S3
aws s3api get-object --bucket $TFVARS_BUCKET_NAME --key $INFRA_STAGE_PREFIX/terraform.tfvars $CODEBUILD_SRC_DIR/Stages/02_Infra/terraform.tfvars