resource "aws_ecs_task_definition" "service" {
  family                   = "${var.environment}-${var.container_family}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  tags = {
    Environment = var.environment
    Family      = var.container_family
  }
  container_definitions = jsonencode([
    {
      name        = "${var.environment}-${var.container_family}"
      image       = var.docker_image
      cpu         = var.cpu
      memory      = var.memory
      environment = var.container_env_vars
      networkMode = "awsvpc"
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogsGroup        = "/fargate/service/${var.environment}-${var.container_family}"
          awslogsRegion       = var.region
          awsLogsStreamPrefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name          = "${var.environment}-${var.container_family}"
  cluster       = var.cluster_id
  desired_count = var.instance_count

  launch_type = "FARGATE"
  depends_on  = [aws_alb_target_group.front_end, aws_alb.lb]

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.service.family}:${max("${aws_ecs_task_definition.service.revision}", "${aws_ecs_task_definition.service.revision}")}"

  network_configuration {
    security_groups  = flatten([var.service_security_groups, aws_security_group.lb.id])
    subnets          = var.lb_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.front_end.id
    container_name   = "${var.environment}-${var.container_family}"
    container_port   = var.container_port
  }
}

resource "aws_alb" "lb" {
  internal                   = false
  security_groups            = var.service_security_groups
  subnets                    = var.lb_subnets
  enable_deletion_protection = false
  idle_timeout               = var.timeout
  tags = {
    Family = "${var.environment}-${var.container_family}"
  }
}


resource "aws_alb_target_group" "front_end" {
  port        = var.loadbalancer_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled  = var.health_check_enabled
    path     = var.health_check_path
    matcher  = var.matcher_ports
    interval = var.timeout + 10
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Family = "${var.environment}-${var.container_family}"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.front_end.arn
  }
  tags = {
    Family = "${var.environment}-${var.container_family}"
  }
}

# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  description = "controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.loadbalancer_port
    to_port          = var.container_port
    cidr_blocks      = var.ingress_cdir_blocks
    ipv6_cidr_blocks = var.ingress_ipv6_cdir_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allow_all_cdir_blocks
  }
  tags = {
    Family = "${var.environment}-${var.container_family}"
  }
}
