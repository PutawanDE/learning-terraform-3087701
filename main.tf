data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner]
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = var.azs
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"] 

  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

module "blog_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.2.0"
  
  name     = "${var.environment.name}-blog"
  min_size = var.asg_min_size
  max_size = var.asg_max_size

  vpc_zone_identifier = module.blog_vpc.public_subnets
  traffic_source_attachments = {
    alb-target-group   = {
      traffic_source_type        = "elbv2"
      traffic_source_identifier  = module.blog_alb.target_groups["blog-target"].arn
    }
  }
  security_groups = [module.blog_sg.security_group_id]

  image_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type
}

module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${var.environment.name}-blog-alb"

  vpc_id          = module.blog_vpc.vpc_id
  subnets          = module.blog_vpc.public_subnets
  security_groups = [module.blog_sg.security_group_id]

  enable_deletion_protection = false

  target_groups = {
    blog-target = {
      name_prefix       = "${var.environment.name}-"
      backend_protocol  = "HTTP"
      backend_port      = 80
      target_type       = "instance"
      create_attachment = false
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
    Environment = var.environment.name
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name    = "${var.environment.name}-blog"
  vpc_id  = module.blog_vpc.vpc_id

  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
