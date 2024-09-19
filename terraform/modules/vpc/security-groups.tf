# Create a security group for the Load Balancer and ECS service
resource "aws_security_group" "ecs_sg" {
    name_prefix = "${var.environment}-ecs-security-group"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port   = var.container_port
        to_port     = var.container_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = var.host_port
        to_port     = var.host_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-ecs-security-group"
    }
}

resource "aws_security_group" "database_sg" {
    name_prefix = "${var.environment}-database-sg"
    vpc_id      = aws_vpc.vpc.id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.ecs_sg.id, aws_security_group.bastion_secuity_group.id]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    depends_on = [ aws_security_group.ecs_sg, aws_security_group.bastion_secuity_group ]

    tags = {
        Name = "${var.environment}-database-sg"
    }
}

resource "aws_security_group" "bastion_secuity_group" {
    name = "${var.environment}-bastion-security-group"
    vpc_id = aws_vpc.vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-bastion-security-group"
    }
}