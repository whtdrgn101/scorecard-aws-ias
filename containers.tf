resource "aws_security_group" "scorecard_web_sg" {
  name        = "${var.environment} WEB"
  vpc_id      = aws_vpc.sc_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = var.public_subnet_cidrs
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_lb_target_group" "scorecard_lb_target_group" {
  name        = "scorecard-target-group"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.sc_vpc.id
  target_type = "ip"
}



resource "aws_lb" "scorecard_lb" {
  name            = "scorecard-lb"
  subnets         = aws_subnet.sc_public_subnets.*.id
  security_groups = [aws_security_group.scorecard_web_sg.id]
}


resource "aws_lb_listener" "scorecard_lb_listener" {
  load_balancer_arn = aws_lb.scorecard_lb.id
  port              = "8000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.scorecard_lb_target_group.id
    type             = "forward"
  }
}

resource "aws_ecs_task_definition" "scorecard_ecs_task_def" {
  family                   = "scorecard-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  
  container_definitions = <<DEFINITION
[
  {
    "image": "whtdrgn101/scorecard-api:latest",
    "cpu": 512,
    "memory": 1024,
    "name": "scorecard-api",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000
      }
    ],
    "environment": [
        {
            "name":"SCORECARD_USER",
            "value":"scorecard"
        },
        {
            "name":"SCORECARD_PASS",
            "value":"${random_password.sc_random_db_pass.result}"
        },
        {
            "name":"SCORECARD_HOST",
            "value":"${module.database.scorecard_database_hostname}"
        },
        {
            "name":"SCORECARD_DB",
            "value":"scorecard_db"
        },
        {
            "name":"JWT_SECRET_KEY",
            "value":"lk76YU_90LOO1"
        },
        {
            "name":"JWT_REFRESH_SECRET_KEY",
            "value":"B4lq78mn_634b2309zz"
        }
    ]
  }
]
DEFINITION
}

resource "aws_security_group" "scorecard-api-sg" {
  name        = "${var.environment} FAST-API"
  vpc_id      = aws_vpc.sc_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 8000
    to_port         = 8000
    security_groups = [aws_security_group.scorecard_web_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "scorecard_ecs_cluster" {
  name = "scorecard-cluster"
}

resource "aws_ecs_service" "scorecard_service" {
  name            = "scorecard-service"
  cluster         = aws_ecs_cluster.scorecard_ecs_cluster.id
  task_definition = aws_ecs_task_definition.scorecard_ecs_task_def.arn
  desired_count   = var.api_app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups     = [aws_security_group.scorecard-api-sg.id]
    subnets             = aws_subnet.sc_public_subnets.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.scorecard_lb_target_group.id
    container_name   = "scorecard-api"
    container_port   = 8000
  }
  
  depends_on = [aws_lb_listener.scorecard_lb_listener]
  
}