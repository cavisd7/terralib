data "aws_iam_policy_document" "eks_cluster_role_policy" {
    statement {
        effect  = "Allow"
        actions = [ "sts:AssumeRole" ]

        principals {
            type        = "Service"
            identifiers = [ "eks.amazonaws.com" ]
        }
    }

    # Tighten permissions
    /*statement {
        effect = "Allow"
        actions = [ 
            "eks:*",
            "elasticloadbalancing:*",
            "kms:DescribeKey",
            "ec2:*",
            "autoscaling:*" 
        ]
        resources = [ "*" ]
    }*/
}

resource "aws_iam_role" "eks_cluster_role" {
    assume_role_policy = data.aws_iam_policy_document.eks_cluster_role_policy.json
    managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
    name               = "EKSRole"
}

resource "aws_eks_cluster" "eks_cluster" {
    name     = var.eks_cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    vpc_config {
        subnet_ids = var.subnet_ids
    }
}