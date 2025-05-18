provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Main VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = { "Service" = "ecs-tasks.amazonaws.com" }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_codepipeline" "pipeline" {
  name     = "MyPipeline"
  role_arn = aws_iam_role.ecs_task_role.arn
  artifact_store {
    location = "my-artifact-store"
    type    = "S3"
  }
  stages {
    name = "Source"
    actions {
      name = "Source"
      action_type_id {
        category = "Source"
        owner = "ThirdParty"
        provider = "GitHub"
        version = "1"
      }
      output_artifacts = ["source_output"]
      configuration {
        Owner = "my_github_user"
        Repo = "my_repo"
        Branch = "main"
        OAuthToken = "my_oauth_token"
      }
    }
  }
  // Additional stages would be defined here
}