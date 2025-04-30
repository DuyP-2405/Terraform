Terraform: Hybrid Cloud Infrastructure on Azure
This document outlines the Terraform configurations used to deploy a secure and scalable hybrid cloud infrastructure on Microsoft Azure, designed for the CyberWatch project.

Overview
The infrastructure includes:
- Azure Resource Group
- Virtual Networks (Hub, Product, Dev)
- Azure Web Application Firewall (WAF) Policy
- Azure DDoS Protection Plan
- (Optional) Integration with hybrid connectivity (VPN/ExpressRoute)

Project Structure
terraform-hybrid-cloud-azure/

├── main.tf           # Core infrastructure: RG, VNets, DDoS

├── waf.tf            # WAF policy and configuration

├── variables.tf      # All input variable declarations

├── outputs.tf        # Useful Terraform outputs

├── backend.tf        # Remote backend configuration (optional)

└── README.md         # This file

Prerequisites
- Terraform CLI
  
- Azure subscription
  
- Service principal credentials (client_id, client_secret, etc.)

Setup
1. Clone the repo:

    git clone 

    cd terraform-hybrid-cloud-azure
2. Create terraform.tfvars with your values:
   
subscription_id     = "your-subscription-id"

client_id           = "your-client-id"

client_secret       = "your-client-secret"

tenant_id           = "your-tenant-id"

resource_group_name = "your-RG-name"

location            = "your-location"

3. Initialize and deploy:

    terraform init
   
    terraform plan
   
    terraform apply
   
Security Features
- WAF Policy: OWASP rule set 3.2 with custom exclusions for headers/cookies
- DDoS Plan: Protects against volumetric attacks
- Isolation: Dedicated VNets for product and dev workloads

Future Enhancements
- Hybrid connectivity (VPN/ExpressRoute)
- Hub-and-Spoke topology expansion
- Network Watcher & NSG flow logs
- Monitoring with Log Analytics & Alerts


