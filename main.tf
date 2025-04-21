data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["aws-marketplace"]
}

data "aws_vpc" "default" {
  default = true
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.2.0"
  
  name     = "blog"
  min_size = 1
  max_size = 2

  vpc_zone_identifier = module.blog_vpc.public_subnets
  traffic_source_attachments = {
    alb-target-group   = {
      target_group_arn = module.blog_alb.target_groups.blog-target.arn
      port             = 80
    }
  }
  security_groups = [module.blog_sg.security_group_id]

  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type
}

module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "blog-alb"

  vpc_id          = module.blog_vpc.vpc_id
  subnets          = module.blog_vpc.public_subnets
  security_groups = [module.blog_sg.security_group_id]

  target_groups = {
    blog-target = {
      name_prefix      = "blog-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      target_id        = aws_instance.blog.id
    }
  }

  listeners = {
    http-tcp-listeners = {
        port               = 80
        protocol           = "HTTP"
        forward = {
          target_group_key = "blog-target"
        }
      }
  }

  tags = {
    Environment = "dev"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name    = "blog"
  vpc_id  = module.blog_vpc.vpc_id

  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
