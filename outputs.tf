output "vpc_id" {
  value = module.blog_vpc.vpc_id
}

output "public_subnets" {
  value = module.blog_vpc.public_subnets
}
