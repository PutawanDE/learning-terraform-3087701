variable "instance_type" {
 description = "Type of EC2 instance to provision"
 type        = string
 default     = "t3.micro"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "region" {
 description = "AWS region to deploy resources"
 type        = string
 default     = "ap-southeast-7"
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-7a", "ap-southeast-7b", "ap-southeast-7c"]
}
