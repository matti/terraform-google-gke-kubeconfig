variable "cluster" {}
variable "kubeconfig" {}

variable "project" {
  default = null
}
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
    refresh    = var.refresh
    kubeconfig = var.kubeconfig
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig
    }
    command = "gcloud beta container clusters get-credentials ${var.cluster.name} --region ${var.cluster.location} --project ${local.google_project}"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "rm ${self.triggers.kubeconfig}"
    on_failure = continue
  }
}

output "kubeconfig" {
  value = var.kubeconfig
}
