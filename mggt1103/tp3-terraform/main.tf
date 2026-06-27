# ==============================================================================
# CONFIGURATION DE BASE TERRAFORM - SEANCE 3
# ==============================================================================

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

# Déclaration d'une variable
variable "dns_primary_ip" {
  description = "Adresse IP du serveur DNS principal"
  type        = string
  default     = "192.168.56.200"
}

# Ressource utilisant la variable
resource "local_file" "dns_config" {
  filename = "/tmp/dns_config.txt"
  content  = "nameserver ${var.dns_primary_ip}\nnameserver 8.8.8.8"
}