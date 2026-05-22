+ Terraform Modules)

Enterprise-grade, highly available, and secure infrastructure-as-code deployment for **NexaCart**. This architecture shifts the application stack from a local containerized layout into a scalable, serverless container ecosystem using AWS ECS Fargate and a fully managed relational database tier.

## 🏗️ System Architecture Overview

The system architecture enforces strict network perimeter boundaries to isolate internal data tiers from public internet exposure:

*   **Public Network Perimeter:** An AWS Application Load Balancer (ALB) distributed across redundant Availability Zones (AZs) handles incoming internet-facing HTTP traffic on port `80`.
*   **Private Compute Layer:** An AWS ECS Cluster utilizing serverless AWS Fargate tasks processes application logic securely isolated inside Private Subnets. 
*   **Private Data Storage Tier:** A dedicated AWS RDS PostgreSQL instance sits behind an isolated database subnet group, strictly accepting ingress packets exclusively from the dynamic security group footprint of the ECS Fargate tasks on port `5432`.
*   **Outbound Network Access:** A dedicated NAT Gateway mapped to an Elastic IP inside the public subnet layer enables private tasks to safely communicate outwards to fetch container package updates without being reachable from the outside world.

---

## 📂 Repository Directory Layout

The Terraform layout is divided into decoupled, reusable modules following standardized infrastructure design patterns:

```text
terraform/
├── main.tf                  # The Orchestrator engine linking modules together
├── variables.tf             # Global input variables (Region, CIDRs, Environment)
├── outputs.tf               # Root output parameters (ALB DNS, DB Endpoint)
├── providers.tf             # Core AWS Provider and S3 Remote State configuration
└── modules/
    ├── networking/          # Provisions VPC, Subnets, Internet/NAT Gateways, and Route Tables
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── database/            # Provisions AWS RDS PostgreSQL and database security perimeters
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/             # Provisions ECS Cluster, Fargate Task Definitions, and ALB Resources
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
⚙️ Prerequisites & Setup
Before spinning up the state orchestration engines, guarantee the following dependencies are available in your shell:

AWS CLI installed and authenticated via aws configure with deployment administrative tokens.

Terraform CLI (v1.5.0 or greater) installed locally.

State S3 Storage & Locking Ledger: Create an S3 Bucket (nexacart-tf-state) with versioning enabled and a DynamoDB locking table (nexacart-tf-locks) with LockID as the Primary Hash String Key.

🚀 Execution & Deployment Pipeline
1. Set Sensitive Infrastructure Variables
To prevent terminal control character bugs or accidental secrets leakage into code history, inject your administrative database master password cleanly into your environment session:

Bash
export TF_VAR_db_password="YourSecureMasterPassword123"
2. Initialize the Remote Backend Modules
Download necessary infrastructure plugins and establish the secure S3 remote state lock handshake:

Bash
cd terraform/
terraform init -reconfigure
3. Generate and Inspect the Compilation Plan
Verify the exact delta modifications before committing resources to your active AWS cloud dashboard billing matrix:

Bash
terraform plan -out=nexacart.tfplan
4. Execute the Cloud Deployment
Provision the environment layers concurrently. (Note: Deploying RDS physical drive allocations can take between 3 to 5 minutes to fully complete).

Bash
terraform apply nexacart.tfplan
📦 Post-Deployment Container Delivery Pipeline
Once Terraform finishes applying, it will print your unique infrastructure endpoints directly into your terminal. Follow these steps to package and deploy your production backend code onto your new architecture:

1. Authenticate Local Docker Engine to AWS ECR
Bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <YOUR_AWS_ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com
2. Provision Your App Repositories
Bash
aws ecr create-repository --repository-name nexacart-backend --region eu-west-1
3. Build, Tag, and Push Your Core API Container Image
Bash
docker build -t nexacart-backend ./backend
docker tag nexacart-backend:latest <YOUR_AWS_ACCOUNT_ID>[.dkr.ecr.eu-west-1.amazonaws.com/nexacart-backend:latest](https://.dkr.ecr.eu-west-1.amazonaws.com/nexacart-backend:latest)
docker push <YOUR_AWS_ACCOUNT_ID>[.dkr.ecr.eu-west-1.amazonaws.com/nexacart-backend:latest](https://.dkr.ecr.eu-west-1.amazonaws.com/nexacart-backend:latest)
4. Point the Compute Task to Your Image
Update the image variable property path inside your modules/compute/main.tf configuration file to point to your new ECR URI string address instead of the baseline placeholder, then re-run terraform apply to instruct ECS to perform a zero-downtime rolling deployment.

📡 Core Infrastructure Outputs
Upon successful execution, the architecture outputs the structural connection matrix needed to interface with your stack:

database_endpoint : Internal DNS path linking compute containers to the isolated PostgreSQL engine.

load_balancer_dns : Public-facing internet address entry point used to reach your live NexaCart deployment stack.