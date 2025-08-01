output "alb_security_group_id" {
  description = "Security Group ID for Application Load Balancer Security Group"
  value       = module.k8s_deps.alb_security_group_id
}