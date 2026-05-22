output "ecs_tasks_sg_id" { 
  value = aws_security_group.ecs_tasks.id 
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}