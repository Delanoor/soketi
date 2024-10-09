resource "aws_ecs_cluster" "soketi" {
  name = "soketi-cluster"
}

resource "aws_ecs_task_definition" "soketi" {
  family                   = "soketi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.soketi_ecs_task_role.arn
  execution_role_arn       = aws_iam_role.soketi_ecs_exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "soketi-container"
      image     = "quay.io/soketi/soketi:1.4-16-alpine"
      portMappings = [
        {
          containerPort = 6001
          protocol      = "tcp"
        },
        {
          containerPort = 9601
          protocol      = "tcp"
        }
      ]
      environment = [
        { name  = "SOKETI_DEBUG", value = "1" },
        { name  = "SOKETI_APP_MANAGER_DRIVER", value = "dynamodb" },
        { name  = "SOKETI_METRICS_ENABLED", value = "1" },
        { name  = "SOKETI_APP_MANAGER_DYNAMODB_REGION", value = "ap-northeast-2" },
        { name  = "SOKETI_APP_MANAGER_DYNAMODB_TABLE", value = "soketi-apps" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = "/ecs/soketi-task"
          "awslogs-region"        = "ap-northeast-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "soketi" {
  name            = "soketi-service"
  cluster         = aws_ecs_cluster.soketi.id
  task_definition = aws_ecs_task_definition.soketi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.soketi_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.soketi_tg.arn
    container_name   = "soketi-container"
    container_port   = 6001
  }
}
