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
    managed_policy_arns = [ 
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    ]
}

/*data "template_file" "user_data" {
    template = file("${path.module}/user-data/start.sh")

    vars = {
        aws_region                = "us-east-1"
    }
}*/

resource "aws_security_group" "worker_node_sg" {
    name        = "eks_worker_node"
    description = "Rules for EKS worker node"
    vpc_id      = var.vpc_id

    ingress {
        description      = "All access"
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

resource "aws_launch_template" "eks_node_template" {
    name = "eks-node-template"

    block_device_mappings {
        device_name = "/dev/sda1"

        ebs {
            volume_size = 8
        }
    }

    disable_api_termination = false

    /*iam_instance_profile {
        name = 
    }*/

    image_id = "ami-066e09c31d10b671c"

    instance_type = "t2.micro"

    metadata_options {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
    }

    monitoring {
        enabled = false
    }

    /*network_interfaces {
        associate_public_ip_address = false
    }*/

    vpc_security_group_ids = [aws_security_group.worker_node_sg.id]

    tag_specifications {
        resource_type = "instance"

        tags = {
            Name = "EKS-Node"
        }
    }

    user_data = /*data.template_file.user_data.rendered*/filebase64("${path.module}/user-data/start.sh")
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

    launch_template {
        id          = aws_launch_template.eks_node_template.id
        version     = "$Latest"
    }
}