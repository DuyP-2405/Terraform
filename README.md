# Terraform
This repository contains Terraform configurations and scripts to provision a complete lab environment for learning, testing, and experimenting with Infrastructure as Code (IaC) using Terraform.
🔧 Key Features
Modular and reusable Terraform code

Supports multiple cloud providers (e.g., AWS, Azure, GCP) (optional – remove if only one provider is used)

Examples of resource provisioning: networks, VMs, security groups, etc.

Includes remote backend configuration and state management

Follows best practices for Terraform project structure

Ideal for hands-on DevOps, cloud engineering, or IaC training.

terraform-lab/
│
├── modules/              # Reusable modules
├── environments/         # Dev, staging, prod, etc.
├── main.tf               # Root Terraform configuration
├── variables.tf          # Input variables
├── outputs.tf            # Output values
├── README.md             # Documentation
└── backend.tf            # Remote backend config (if used)
