data "aws_availability_zones" "azs" {
    state = "available"
}

resource "aws_internet_gateway" "igw" {
    vpc_id      = var.vpc_id
}

resource "aws_subnet" "public_subnet" {
    count               = var.subnet_count

    vpc_id              = var.vpc_id
    # Assuming a /16 VPC CIDR block, will result in a /24 CIDR block for the subnet
    # Public subnets will have even numbers
    cidr_block          = cidrsubnet(var.vpc_cidr_block, 8, count.index)
    availability_zone   = data.aws_availability_zones.azs.names[count.index]

    tags = {
        Name = "Public"
    }
}

resource "aws_eip" "nat_eip" {
    count       = var.subnet_count
    vpc         = true
}

resource "aws_nat_gateway" "ngw" {
    count           = var.subnet_count

    allocation_id   = aws_eip.nat_eip[count.index].id
    subnet_id       = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "public_rt" {
    vpc_id          = var.vpc_id
}

resource "aws_route" "public_route" {
    route_table_id         = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route_join" {
    count           = var.subnet_count 

    route_table_id  = aws_route_table.public_rt.id
    subnet_id       = aws_subnet.public_subnet[count.index].id
}

resource "aws_subnet" "private_subnet" {
    count               = var.subnet_count 

    vpc_id              = var.vpc_id
    # Assuming a /16 VPC CIDR block, will result in a /24 CIDR block for the subnet
    # Private subnets will have odd numbers
    cidr_block          = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.subnet_count)
    availability_zone   = data.aws_availability_zones.azs.names[count.index]

    tags = {
        Name = "Private"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
}

resource "aws_route_table" "private_rt" {
    count                   = var.subnet_count

    vpc_id      = var.vpc_id
}

resource "aws_route" "private_route" {
    count                   = var.subnet_count

    route_table_id          = aws_route_table.private_rt[count.index].id
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.ngw[count.index].id
}

resource "aws_route_table_association" "private_route_join" {
    count                   = var.subnet_count

    route_table_id          = aws_route_table.private_rt[count.index].id
    subnet_id               = aws_subnet.private_subnet[count.index].id
}