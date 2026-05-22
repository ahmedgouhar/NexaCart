output "load_balancer_dns" {
  value       = module.compute.alb_dns_name
  description = "The public web address used to hit your live application infrastructure stack"
}