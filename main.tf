variable "project" {
  default = null
}
variable "cluster" {}
variable "kubeconfig" {}
variable "refresh" {
  default = ""
}

provider "google" {}

data "google_project" "default" {}

locals {
  google_project = var.project == null ? data.google_project.default.project_id : var.project
}

resource "null_resource" "kubeconfig" {
  triggers = {
    refresh = var.refresh
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig
    }
    command = "gcloud beta container clusters get-credentials ${var.cluster.name} --region ${var.cluster.location} --project ${local.google_project}"
  }

  provisioner "local-exec" {
    when       = "destroy"
    command    = "rm ${var.kubeconfig}"
    on_failure = "continue"
  }
}

output "kubeconfig" {
  value = var.kubeconfig
}
