# 1. Fire up Networking Module First
module "networking" {
  source               = "./modules/networking"
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# 2. Fire up Compute Framework Engine
module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.networking.vpc_id
  environment        = var.environment
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  database_endpoint  = module.database.db_endpoint
}

# 3. Securely Instantiate Relational Storage Topology
module "database" {
  source             = "./modules/database"
  vpc_id             = module.networking.vpc_id
  environment        = var.environment
  private_subnet_ids = module.networking.private_subnet_ids
  db_password        = var.db_password
  ecs_tasks_sg_id    = module.compute.ecs_tasks_sg_id # Cross-module linking rule
}