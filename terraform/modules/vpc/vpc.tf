resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr
    instance_tenancy     = "default"
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "${var.environment}-vpc"
    }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_sb1_cidr
    availability_zone       = "${var.region}a"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.environment}-public-subnet-1"
    }
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = var.private_sb1_cidr
    availability_zone = "${var.region}a"
    
    tags = {
        Name = "${var.environment}-private-subnet-1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_sb2_cidr
    availability_zone       = "${var.region}b"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.environment}-public-subnet-2"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id            = aws_vpc.vpc.id
    cidr_block        = var.private_sb2_cidr
    availability_zone = "${var.region}b"
    
    tags = {
        Name = "${var.environment}-private-subnet-2"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
    
    tags = {
        Name = "${var.environment}-internet-gateway"
    }
} 

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }
    
    tags = {
        Name = "${var.environment}-public-route-table"
    }
}

resource "aws_route_table_association" "rta_to_public1" {
    subnet_id      = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rta_to_public2" {
    subnet_id      = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "eip" {
    domain = "vpc"
    
    tags = {
        Name = "${var.environment}-eip"
    }
}  

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.public_subnet_1.id
    
    tags = {
        Name = "${var.environment}-nat-gateway"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gateway.id
    }

    tags = {
        Name = "${var.environment}-private-route-table"
    }
}

resource "aws_route_table_association" "rta_to_private1" {
    subnet_id      = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "rta_to_private2" {
    subnet_id      = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_route_table.id
}