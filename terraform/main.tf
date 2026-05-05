variable "do_token" {
  description = "This is the token allow terraform access into your Digital Ocean account"
}

variable "ssh_key" {
  description = "This is SSH key allow terraform access into your droplets"
}

variable "github_access_token" {
  type = string
}

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

provider "digitalocean" {
  token = var.do_token
}

provider "github" {
  token = var.github_access_token
  owner = "Kelvin2k"
}

resource "digitalocean_droplet" "web" {
  image    = "ubuntu-24-04-x64"
  name     = "movie-project-vps"
  region   = "syd1"
  size     = "s-2vcpu-2gb"
  ssh_keys = [var.ssh_key]
}

resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini"
  content  = <<-EOT
    [list_host]
    ${digitalocean_droplet.web.ipv4_address}

    [list_host:vars]
    ansible_user=root
    ansible_private_key_file=./ssh-key-do
    REACT_APP_API_URL=https://api.updatestudentmonash.dev/
    VPS_IP=${digitalocean_droplet.web.ipv4_address}
  EOT
}

resource "github_actions_variable" "vps_host" {
  repository    = "MovieTheater_Project"
  variable_name = "VPS_HOST"
  value         = digitalocean_droplet.web.ipv4_address
}

output "output_name" {
  value = {
    ipVps: digitalocean_droplet.web.ipv4_address
  }
}