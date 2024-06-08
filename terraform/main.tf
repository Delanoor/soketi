provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  shared_config_files      = ["~/.aws/config"]
  profile                  = "anychat"
  region                   = "ap-northeast-2"
}

variable "vpc_id" {
  default = "vpc-064d434aebdaaad0d"
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
  default     = ["subnet-0a26fc2b57d32cedc", "subnet-017386709ca45b3ad"]
}

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

resource "aws_cloudwatch_log_group" "soketi_task_log_group" {
  name              = "/ecs/soketi-task"
  retention_in_days = 0
}

resource "aws_ecs_task_definition" "soketi" {
  family                   = "soketi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  task_role_arn      = aws_iam_role.soketi_ecs_task_role.arn
  execution_role_arn = aws_iam_role.soketi_ecs_exec_role.arn
  container_definitions = jsonencode([
    {
      name      = "soketi-container"
      image     = "quay.io/soketi/soketi:1.4-16-alpine"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 6001
          hostPort      = 6001
          protocol      = "tcp"
        },
        {
          containerPort = 9601
          hostPort      = 9601
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "SOKETI_DEBUG"
          value = "1"
        },
        {
          name  = "SOKETI_APP_MANAGER_DRIVER"
          value = "dynamodb"
        },
        {
          name  = "SOKETI_METRICS_ENABLED"
          value = "1"
        },
        {
          name  = "SOKETI_APP_MANAGER_DYNAMODB_REGION"
          value = "ap-northeast-2"
        },
        {
          name  = "SOKETI_APP_MANAGER_DYNAMODB_TABLE"
          value = "soketi-apps"
        }
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

resource "aws_ecs_cluster" "soketi" {
  name = "soketi-cluster"
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
}

resource "aws_iam_role" "soketi_ecs_task_role" {
  name = "soketi-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "soketi_task_policy" {
  name = "soketi-ecs-task-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid : "DynamoDBAccess",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:BatchGetItem",
          "dynamodb:Scan",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables",
          "dynamodb:PartiQLSelect"
        ],
        Resource = "arn:aws:dynamodb:ap-northeast-2:211125474338:table/soketi-apps"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "soketi_task_policy_attachment" {
  policy_arn = aws_iam_policy.soketi_task_policy.arn
  role       = aws_iam_role.soketi_ecs_task_role.name
}

resource "aws_iam_role" "soketi_ecs_exec_role" {
  name = "soketi-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "soketi_exec_policy" {
  name = "soketi-ecs-exec-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:Describe*",
          "dynamodb:List*",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PartiQLSelect"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:ap-northeast-2:211125474338:table/soketi-apps"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "soketi_exec_policy_attachment" {
  name       = "soketi-exec-policy-attachment"
  policy_arn = aws_iam_policy.soketi_exec_policy.arn
  roles      = [aws_iam_role.soketi_ecs_exec_role.name]
}

resource "aws_security_group" "soketi_sg" {
  name        = "soketi-sg"
  description = "Allow traffic to Soketi"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6001
    to_port     = 6001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9601
    to_port     = 9601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ecs_cluster_id" {
  description = "The ECS cluster ID"
  value       = aws_ecs_cluster.soketi.id
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.soketi.name
}
