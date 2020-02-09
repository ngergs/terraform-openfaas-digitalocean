# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Configure helm chart
data "helm_repository" "openfaas" {
  name = "openfaas"
  url  = "https://openfaas.github.io/faas-netes/"
}


################
# k8s
################
resource "digitalocean_kubernetes_cluster" "k8s_openfaas" {
  name   = "${var.project_name}-k8s"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = var.k8s_version

  node_pool {
    name       = "${var.project_name}-pool"
    size       = var.k8s_node_size
    auto_scale = true
    min_nodes  = var.k8s_min_nodes
    max_nodes  = var.k8s_max_nodes
  }
}

provider "kubernetes" {
  version          = "1.9" // see https://github.com/terraform-providers/terraform-provider-kubernetes/issues/679 regarding version 1.10
  load_config_file = false
  host             = digitalocean_kubernetes_cluster.k8s_openfaas.endpoint
  token            = digitalocean_kubernetes_cluster.k8s_openfaas.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.k8s_openfaas.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    load_config_file = false
    host             = digitalocean_kubernetes_cluster.k8s_openfaas.endpoint
    token            = digitalocean_kubernetes_cluster.k8s_openfaas.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.k8s_openfaas.kube_config[0].cluster_ca_certificate
    )
  }
}


################
# openfaas
################
resource "kubernetes_namespace" "openfaas" {
  metadata {
    name = "openfaas"
    labels = {
      role            = "openfaas-system"
      access          = "openfaas-system"
      istio-injection = "enabled"
    }
  }
}
resource "kubernetes_namespace" "openfaas_fn" {
  metadata {
    name = "openfaas-fn"
    labels = {
      role            = "openfaas-fn"
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "openfaas" {
  name       = "openfaas"
  repository = "https://openfaas.github.io/faas-netes/" // see issue https://github.com/terraform-providers/terraform-provider-helm/issues/335
  chart      = "openfaas"
  version    = var.openfaas_chart_version
  namespace  = kubernetes_namespace.openfaas.metadata[0].name

  set {
    name  = "functionNamespace"
    value = kubernetes_namespace.openfaas_fn.metadata[0].name
  }

  set {
    name  = "generateBasicAuth"
    value = true
  }

  set {
    name  = "serviceType"
    value = "LoadBalancer"
  }

  provisioner "local-exec" {
    command = "doctl auth init -t ${var.do_token} && doctl kubernetes cluster kubeconfig save ${digitalocean_kubernetes_cluster.k8s_openfaas.name}  && kubectl -n ${kubernetes_namespace.openfaas.metadata[0].name} get secret basic-auth -o jsonpath=\"{.data.basic-auth-password}\" | base64 --decode | awk '{print \"openfaas password: \"$1}'"
  }
}