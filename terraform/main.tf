variable "do_token" {
  type = string
  description = "This is the token allow terraform access into your Digital Ocean account"
}

variable "ssh_key" {
  type = string
  description = "This is SSH key allow terraform access into your droplets"
}

variable "github_access_token" {
  type = string
}

# Terraform backend and provider configuration.
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://syd1.digitaloceanspaces.com"
    }
    region                      = "us-east-1" 
    bucket                      = "movie-project-tfstate" 
    key                         = "terraform.tfstate" 
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.84.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.12.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

# DigitalOcean provider used to create and manage infrastructure resources.
provider "digitalocean" {
  token = var.do_token
}

# GitHub provider used to manage repository variables and secrets.
provider "github" {
  token = var.github_access_token
  owner = "Kelvin2k"
}

# Main application VPS.
resource "digitalocean_droplet" "web" {
  image    = "ubuntu-24-04-x64"
  name     = "movie-project-vps"
  region   = "syd1"
  size     = "s-2vcpu-2gb"
  ssh_keys = [var.ssh_key]
}

# Generate the Ansible inventory for the application server.
resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini"
  content  = <<-EOT
    [list_host]
    ${digitalocean_droplet.web.ipv4_address}

    [list_host:vars]
    ansible_user=root
    ansible_private_key_file=./ssh-key-do
    VPS_IP=${digitalocean_droplet.web.ipv4_address}
  EOT
}

# Monitoring VPS used for observability services.
resource "digitalocean_droplet" "monitoring" {
  image    = "ubuntu-24-04-x64"
  name     = "movie-monitoring-vps"
  region   = "syd1"
  size     = "s-1vcpu-2gb"
  ssh_keys = [var.ssh_key]
}

# Generate the Ansible inventory for the monitoring server.
resource "local_file" "monitoring_vps" {
  filename = "../ansible/hosts-monitoring.ini"
  content  = <<-EOT
    [list_host]
    ${digitalocean_droplet.monitoring.ipv4_address}

    [list_host:vars]
    ansible_user=root
    ansible_private_key_file=./ssh-key-do
  EOT
}

# GitHub repository configuration exposed to the application and workflow.
resource "github_actions_variable" "vps_host" {
  repository    = "MovieTheater_Project"
  variable_name = "VPS_HOST"
  value         = digitalocean_droplet.web.ipv4_address
}

resource "github_actions_secret" "api_url_secret" {
  repository      = "MovieTheater_Project"
  secret_name     = "REACT_APP_API_URL"
  plaintext_value = "https://be-cinema-project.updatesstudentmonash.dev/"
}

# Useful outputs for other automation layers or manual inspection.
output "project_vps_ip" {
  value = digitalocean_droplet.web.ipv4_address
  
}

output "monitoring_vps_ip" {
  value = digitalocean_droplet.monitoring.ipv4_address
}