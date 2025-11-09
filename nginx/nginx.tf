resource "helm_release" "nginx" {
  count = var.nginx_install == true ? 1 : 0

  name = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = "4.14.0"
  namespace = "ingress-nginx"
  values = [
    "${file("values.yaml")}"
  ]
  
}