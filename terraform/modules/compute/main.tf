# ==========================================
# 1. SECURITY GROUPS (Traffic Isolation)
# ==========================================

# Public Load Balancer Firewall Perimeter
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allows public HTTP ingress traffic on port 80"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-alb-sg" }
}

# ECS Container Private Firewall Perimeter
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Isolates container tasks to only accept ingress traffic originating from the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-ecs-tasks-sg" }
}

# ==========================================
# 2. APPLICATION LOAD BALANCER ROUTING
# ==========================================

# Public External Application Load Balancer
resource "aws_lb" "main" {
  name               = "nexacart-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = { Name = "nexacart-${var.environment}-alb" }
}

# Target Group pointing to Fargate dynamic private IPs
resource "aws_lb_target_group" "backend" {
  name        = "nexacart-${var.environment}-backend-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for awsvpc network mode

  health_check {
    path                = "/docs" # FastApi Swagger docs works perfectly for base health checking
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Load Balancer Listener tracking public internet requests
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# ==========================================
# 3. ECS ORCHESTRATION ENGINE
# ==========================================

# Logical Compute Cluster Grouping
resource "aws_ecs_cluster" "main" {
  name = "nexacart-${var.environment}-cluster"
}

# Execution Identity Role allowing ECS agent to reach out to ECR and CloudWatch
resource "aws_iam_role" "ecs_execution" {
  name = "nexacart-ecs-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Serverless Container Allocation Blueprints
resource "aws_ecs_task_definition" "backend" {
  family                   = "nexacart-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "nexacart_backend"
      image     = "python:3.11-alpine" # Standard Python baseline image
      essential = true
      portMappings = [{
        containerPort = 8000
        hostPort      = 8000
      }]
      # Injecting real environment variables dynamically from other modules
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql://nexacart_admin:password_placeholder@${var.database_endpoint}/nexacart"
        }
      ]
    }
  ])
}

# Scheduling engine that provisions tasks within private subnets
resource "aws_ecs_service" "backend" {
  name            = "nexacart-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false # True perimeter isolation
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "nexacart_backend"
    container_port   = 8000
  }

  # Ensure the Load Balancer routing table completes creation before spinning up tasks
  depends_on = [aws_lb_listener.http] 
}