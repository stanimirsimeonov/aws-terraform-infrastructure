# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubernetes_namespace" "main" {
  for_each =  toset(var.K8S_NAMESPACES)
  metadata {
    name = each.value
  }
  depends_on = [
    aws_eks_node_group.private-nodes

  ]
}