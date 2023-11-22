output "dns_name" {
  value = aws_alb.lb.dns_name
}

output "service_name" {
  value = aws_ecs_service.service.name
}
