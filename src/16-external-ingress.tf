resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress"
  version    = "4.3.0"
  create_namespace = true
  values = [
    file("./external-ingress/values.yaml")
  ]
#  depends_on = [
#    kubectl_manifest.prometeus-prometheus
#  ]

  depends_on = [
    aws_eks_node_group.private-nodes,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
}