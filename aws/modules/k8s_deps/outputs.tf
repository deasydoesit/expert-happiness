output "alb_security_group_id" {
  description = "Security Group ID for Application Load Balancer Security Group"
  value       = aws_security_group.alb.id
}
