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

resource "docker_image" "nginx_image" {
  name         = "nginx:alpine"
  keep_locally = false
}

resource "docker_container" "web_server" {
  image = docker_image.nginx_image.image_id
  name  = "srv-web-ggt-docker"

  ports {
    internal = 80
    external = 8080
  }
}