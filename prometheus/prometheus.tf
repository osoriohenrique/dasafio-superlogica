resource "helm_release" "prometheus" {
  count = var.prometheus_install == true ? 1 : 0

  name             = "prometheus-stack"
  chart            = "oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack"
  version          = "79.4.1"
  namespace        = "monitoring"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  values = [
    file("${path.module}/values.yaml")
  ]

}