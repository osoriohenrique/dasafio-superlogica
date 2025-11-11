autodiscovery:
  clusterName: ${cluster_name}
  awsRegion: us-east-1

tolerations:
- key: "tools"
  operator: "Equal"
  effect: "NoSchedule"
  value: "true"

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: "tools"
          operator: "In"
          values: 
          - "true"

rbac:
  serviceAccount:
    annotations: 
      "eks.amazonaws.com/role-arn": ${role_cluster_autoscaler_arn}
    name: ${service_account_name}