# 1. Configuration des exigences du provider VirtualBox
terraform {
  required_providers {
    virtualbox = {
      source  = "shekeriev/virtualbox"
      version = "0.0.4"
    }
  }
}

# 2. Configuration de la connexion à l'API de l'hôte Windows
provider "virtualbox" {
  delay      = 60
  mintimeout = 5
}

# 3. Déclaration de notre machine virtuelle d'infrastructure
resource "virtualbox_vm" "srv_ggt_vm" {
  name   = "Serveur-Automatique-GGT"
  image  = "https://vagrantcloud.com/ubuntu/boxes/jammy64/versions/20230616.0.0/providers/virtualbox.box)"
  cpus   = 1
  memory = "1024 mib" # 1 Go de RAM alloué

  # Configuration du réseau de la VM
  network_adapter {
    type           = "hostonly" # Réseau privé hôte
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}
