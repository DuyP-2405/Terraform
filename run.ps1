Set-Location C:\DuyP\Project
terraform init
terraform validate
terraform plan -out Project.tfplan
terraform apply "Project.tfplan"