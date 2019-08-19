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
}

resource "kubernetes_role_binding" "gke-kube-system-sa-cluster-admin" {
  depends_on = [null_resource.kubeconfig]

  metadata {
    name = "gke-kube-system-sa-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
}
