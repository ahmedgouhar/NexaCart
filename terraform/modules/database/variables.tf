variable "vpc_id" { type = string }
variable "environment" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_password" { type = string }
variable "ecs_tasks_sg_id" { type = string } # للربط الأمني مع الـ Containers