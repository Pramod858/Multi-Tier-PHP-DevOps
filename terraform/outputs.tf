output "vpc_id" {
    value = module.vpc.vpc_id
}

output "ecs_alb_dns_addr" {
    value = module.ecs.alb_dns_addr
}
