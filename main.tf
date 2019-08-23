variable "cluster" {}
variable "kubeconfig" {}

provider "google" {}
data "google_client_config" "default" {}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig
    }
    command = "gcloud beta container clusters get-credentials ${var.cluster.name} --region ${var.cluster.location} --project ${data.google_client_config.default.project}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm ${var.kubeconfig}"
  }
}

output "kubeconfig" {
  value = var.kubeconfig
}
