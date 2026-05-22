resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Access control matrix for RDS PostgreSQL engine"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_tasks_sg_id] # يسمح فقط للـ Containers بالدخول
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}


resource "aws_db_instance" "postgres" {
  identifier             = "nexacart-${var.environment}-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15" 
  auto_minor_version_upgrade = true 
  instance_class         = "db.t3.micro"
  db_name                = "nexacart"
  
  # Change this from "admin" to a valid database user identifier
  username               = "nexacart_admin" 
  
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
}