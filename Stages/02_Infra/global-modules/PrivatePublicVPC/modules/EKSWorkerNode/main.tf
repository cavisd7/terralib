data "aws_iam_policy_document" "node_group_role_policy" {
    statement {
        sid = "1"
        effect  = "Allow"
        actions = [ "sts:AssumeRole" ]

        principals {
            type        = "Service"
            identifiers = [ "ec2.amazonaws.com" ]
        }
    }
}

resource "aws_iam_role" "node_group_role" {
    name = "EKSNodeGroupRole"

    assume_role_policy = data.aws_iam_policy_document.node_group_role_policy.json
}

resource "aws_eks_node_group" "node_group" {
    cluster_name    = var.cluster_name
    node_group_name = var.node_group_name
    node_role_arn   = aws_iam_role.node_group_role.arn
    subnet_ids      = var.subnet_ids

    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 1
    }
}