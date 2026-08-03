terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.8"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Réseau privé
resource "docker_network" "private_network" {
  name   = "network-ggt-private"
  driver = "bridge"

  ipam_config {
    subnet = "10.10.10.0/24"
  }
}

# Images
resource "docker_image" "postgres_image" {
  name = "postgres:15-alpine"
}

resource "docker_image" "nginx_image" {
  name = "nginx:alpine"
}

# Base de données
resource "docker_container" "db_node" {
  name  = "database-production"
  image = docker_image.postgres_image.image_id

  env = [
    "POSTGRES_USER=admin_ggt",
    "POSTGRES_PASSWORD=SecurisePassword2026",
    "POSTGRES_DB=telecom_db"
  ]

  networks_advanced {
    name         = docker_network.private_network.name
    ipv4_address = "10.10.10.50"
  }
}

# Serveur Web
resource "docker_container" "web_node" {
  name  = "web-gateway"
  image = docker_image.nginx_image.image_id

  ports {
    internal = 80
    external = 8081
  }

  networks_advanced {
    name         = docker_network.private_network.name
    ipv4_address = "10.10.10.10"
  }
}