output "instance_ami" {
 value = aws_instance.blog.ami
}

output "instance_arn" {
 value = aws_instance.blog.arn
}

output "vpc_id" {
  value = module.blog_vpc.vpc_id
}

output "public_subnets" {
  value = module.blog_vpc.public_subnets
}

output "instance_public_ip" {
  value = aws_instance.blog.public_ip
}
