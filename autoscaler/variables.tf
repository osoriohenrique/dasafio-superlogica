variable "cluster_name" {
  description = "name of the cluster"
  default     = ""
  type        = string
}

variable "autoscaler_install" {
  description = "define whether it will be installed or not"
  default     = true
  type        = bool
}

variable "oidc_provider_arn" {
  description = "ARN EKS"
}

variable "namespace" {
  default = "cluster-autoscaler"
  type    = string
}

variable "service_account_name" {
  default = "cluster-autoscaler"
  type    = string
}