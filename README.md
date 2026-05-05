# Cinema Infrastructure

Infrastructure-as-code for deploying the Cinema (Movie Theater) project on a DigitalOcean VPS. Terraform provisions the droplet and generates the Ansible inventory, while Ansible installs Docker, pulls the application repo, renders environment files, and deploys with Docker Compose.

## What This Repo Does

- Provision a DigitalOcean droplet with Terraform
- Write an Ansible inventory pointing to the new VPS
- Install Docker and Docker Compose on the VPS
- Clone the application repo and render .env files
- Build and run the app with Docker Compose

## Tech Stack

- Terraform (DigitalOcean + local provider)
- Ansible
- Docker + Docker Compose
- DigitalOcean Spaces for Terraform state backend

## Repository Structure

- terraform/ - Terraform configuration for droplet + inventory file
- ansible/ - Ansible playbook and env templates

## Prerequisites

- Terraform
- Ansible
- A DigitalOcean account and API token
- An SSH key added to your DigitalOcean account

## Usage

1. Configure Terraform variables in terraform/terraform.tfvars.
2. Initialize and apply Terraform:

```sh
cd terraform
terraform init
terraform apply
```

3. Create or edit the Ansible secrets file:

```sh
cd ../ansible
ansible-vault create secrets.yml
```

4. Run the Ansible playbook:

```sh
ansible-playbook -i hosts.ini install_vps.yml
```

## Notes

- The Ansible inventory is generated at ansible/hosts.ini by Terraform.
- Ensure ansible/ssh-key-do matches the private key used by DigitalOcean.
- Environment templates live in ansible/.env\_\*.j2 and are rendered on the VPS.
