resource "aws_iam_role" "soketi_ecs_task_role" {
  name = "soketi-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "soketi_task_policy" {
  name = "soketi-ecs-task-policy"

  policy = jsonencode({
    Version = "2012-10-17",
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
        Resource = [
          "${aws_dynamodb_table.soketi_apps.arn}",
          "${aws_dynamodb_table.soketi_apps.arn}/index/AppKeyIndex"
        ]
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
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "soketi_exec_policy" {
  name = "soketi-ecs-exec-policy"
  policy = jsonencode({
    Version = "2012-10-17",
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
        Resource = "${aws_dynamodb_table.soketi_apps.arn}"
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
