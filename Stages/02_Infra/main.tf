/*
 * Test Bucket
 */

resource "aws_s3_bucket" "test_bucket_from_pipeline" {
    bucket              = "testnamenooneelseintheworldwouldguess"

    force_destroy       = true
}