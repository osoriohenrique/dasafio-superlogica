resource "helm_release" "cluster_autoscaler" {
  count = var.autoscaler_install == true ? 1 : 0

  name             = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.52.1"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      cluster_name                = var.cluster_name,
      service_account_name        = var.service_account_name
      role_cluster_autoscaler_arn = aws_iam_role.cluster_autoscaler.arn
    })
  ]

  depends_on = [aws_iam_role.cluster_autoscaler]
}
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.cluster_name}-cluster-autoscaler-policy"
  description = "Política IAM para o Cluster Autoscaler do EKS"

  # Política recomendada pela documentação oficial do autoscaler
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Cria a Role que será "assumida" pelo Service Account do Kubernetes
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.cluster_name}-cluster-autoscaler-role"

  # Política de confiança (Assume Role Policy) que permite o OIDC
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            # Limita esta role apenas para o service account 'cluster-autoscaler'
            # no namespace 'kube-system'
            "${var.oidc_provider_arn}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
}

# Anexa a política de permissões à role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}