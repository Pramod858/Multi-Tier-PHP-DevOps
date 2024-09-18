# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.environment}-ecs-cluster"
}


# Application Load Balancer
resource "aws_lb" "alb" {
    name               = "${var.environment}-alb"
    load_balancer_type = "application"
    security_groups    = [var.ecs_security_group_id]
    subnets            = [var.public_subnet_1_id,var.public_subnet_2_id]
    ip_address_type    = "ipv4" 

    tags = {
        Name = "${var.environment}-alb"
    }
}

# Target Group
resource "aws_lb_target_group" "target_group" {
    name        = "${var.environment}-target-group"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"
}

resource "aws_lb_listener" "front_end" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.target_group.arn
    }
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
    "name": "${var.container_name}",
    "image": "${var.image_name}",
    "essential": true,
    "portMappings": [
        {
            "containerPort": ${var.container_port},
            "hostPort": ${var.host_port}
        }
    ],
    ${var.container_env_vars_config}
    }
]
EOF
}

# Create an ECS service
resource "aws_ecs_service" "ecs_service" {
    name            = "${var.environment}-service"
    cluster         = aws_ecs_cluster.ecs_cluster.id
    task_definition = aws_ecs_task_definition.task_definition.arn
    desired_count   = 1
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = [var.private_subnet_1_id,var.private_subnet_2_id]
        security_groups  = [var.ecs_security_group_id]
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.target_group.arn
        container_name   = "${var.container_name}"
        container_port   = var.container_port
    }

    depends_on = [
        aws_ecs_task_definition.task_definition,
        aws_lb_listener.front_end
    ]
}