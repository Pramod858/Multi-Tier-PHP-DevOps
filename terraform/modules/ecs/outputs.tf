output "alb_dns_addr" {
    value = aws_lb.alb.dns_name
}

output "alb_zone_id" {
    value = aws_lb.alb.zone_id
}