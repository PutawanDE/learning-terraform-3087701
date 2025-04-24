variable "instance_type" {
 description = "Type of EC2 instance to provision"
 type        = string
 default     = "t3.micro"
}

variable "region" {
  description = "AWS region to deploy the resources"
  type        = string
  default     = "ap-southeast-7"
  
}

variable "azs" {
  description = "Availability Zones to use for the resources"
  type        = list(string)
  default     = ["ap-southeast-7a", "ap-southeast-7b", "ap-southeast-7c"] 
  
}

variable "ami_filter" {
  description = "Name filter and owner for AMI"

  type = object({
    name = string
    owner = string
  })
  
  default = {
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami*"
    owner = "aws-marketplace"
  }
}

variable "environment" {
  description = "Development environment"

  type = object({
    name           = string
    network_prefix = string
  })

  default = {
    name           = "dev"
    network_prefix = "10.0"
  }
}

variable "asg_min_size" {
  description = "Minimum number of instances in the autoscaling group"
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the autoscaling group"
  default     = 2
}
