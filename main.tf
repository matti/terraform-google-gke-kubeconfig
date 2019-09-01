variable "project" {}
variable "cluster" {}
variable "kubeconfig" {}
variable "refresh" {
  default = ""
}

provider "google" {}


resource "null_resource" "kubeconfig" {
  triggers = {
    refresh = var.refresh
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig
    }
    command = "gcloud beta container clusters get-credentials ${var.cluster.name} --region ${var.cluster.location} --project ${var.project}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm ${var.kubeconfig}"
  }
}

output "kubeconfig" {
  value = var.kubeconfig
}
