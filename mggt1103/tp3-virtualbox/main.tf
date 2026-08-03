variable "vboxmanage" {
  default = "/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
}

variable "vm_name" {
  default = "Serveur-Automatique-GGT"
}

variable "source_vm" {
  default = "VM-Ubuntu-Mggt1103"
}

resource "null_resource" "srv_ggt_vm" {

  triggers = {
    vm_name = var.vm_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      VBM="${var.vboxmanage}"
      "$VBM" clonevm "${var.source_vm}" --name "${var.vm_name}" --register
      "$VBM" discardstate "${var.vm_name}" || true
      "$VBM" modifyvm "${var.vm_name}" --cpus 1 --memory 1024
      "$VBM" modifyvm "${var.vm_name}" --nic1 hostonly --hostonlyadapter1 "VirtualBox Host-Only Ethernet Adapter"
      "$VBM" startvm "${var.vm_name}" --type headless
    EOT
    interpreter = ["bash", "-c"]
  }

  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      "/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" controlvm "${self.triggers.vm_name}" poweroff || true
      sleep 3
      "/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe" unregistervm "${self.triggers.vm_name}" --delete || true
    EOT
    interpreter = ["bash", "-c"]
  }
}

output "vm_status" {
  value = "VM deployee et demarree automatiquement via Terraform (local-exec + VBoxManage)."
}
