variable "vpc_id" { type = string }
variable "environment" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "database_endpoint" { type = string }