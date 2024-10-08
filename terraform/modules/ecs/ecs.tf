# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.environment}-ecs-cluster"
}


# Application Load Balancer
resource "aws_lb" "alb" {
    name               = "${var.environment}-alb"
    load_balancer_type = "application"
    security_groups    = [var.alb_security_group_id]
    subnets            = [var.public_subnet_1_id,var.public_subnet_2_id]
    ip_address_type    = "ipv4" 

    tags = {
        Name = "${var.environment}-alb"
    }
}

# Target Group
resource "aws_lb_target_group" "target_group" {
    name        = "${var.environment}-target-group"
    port        = var.container_port
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"

    depends_on = [ aws_lb.alb ]
}

resource "aws_lb_listener" "ecs-alb-listener-http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "redirect"
        
        redirect {
            port        = 443
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_lb_listener" "ecs-alb-listener-https" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 443
    protocol          = "HTTPS"
    certificate_arn   = var.acm_certificate_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.target_group.arn
    }
}

resource "aws_cloudwatch_log_group" "ecs" {
    name              = "/ecs/${var.environment}"
    retention_in_days = 1
}


resource "aws_iam_role" "ecsTaskExecutionRole" {
    name               = "${var.environment}-ecsTaskExecutionRole"
    assume_role_policy = jsonencode({
        Version        = "2012-10-17"
        
        Statement = [
        {
            Effect    = "Allow"
            Principal = {
                Service   = "ecs-tasks.amazonaws.com"
            }
            Action    = "sts:AssumeRole"
        }
        ]
    })

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ]
}

resource "aws_ecs_task_definition" "task_definition" {
    family                   = "${var.environment}-task-definition"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "512"
    memory                   = "1024"

    execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
    task_role_arn      = aws_iam_role.ecsTaskExecutionRole.arn
    
    container_definitions    = <<EOF
[
    {
    "name": "${var.environment}",
    "image": "${data.aws_ecr_repository.service.repository_url}:<image_tag>",
    "essential": true,
    "portMappings": [
        {
            "containerPort": ${var.container_port},
            "hostPort": ${var.host_port}
        }
    ],
    ${var.container_env_vars_config}
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-region": "${var.region}",
            "awslogs-group": "/ecs/${var.environment}",
            "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
EOF
}

# Create an ECS service
resource "aws_ecs_service" "ecs_service" {
    name            = "${var.environment}-ecs-service"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.task_definition.arn
    desired_count   = var.task_count
    launch_type     = "FARGATE"


    network_configuration {
        subnets          = [var.private_subnet_1_id,var.private_subnet_2_id]
        security_groups  = [var.ecs_security_group_id]
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.target_group.arn
        container_name   = "${var.environment}"
        container_port   = var.container_port
    }

    depends_on = [
        aws_ecs_task_definition.task_definition,
        aws_lb_listener.ecs-alb-listener-http,
        aws_lb_listener.ecs-alb-listener-https
    ]
}
