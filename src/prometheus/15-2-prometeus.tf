resource "kubectl_manifest" "prometeus-service-account" {
  yaml_body = file("./prometheus/2-prometheus/0-service-account.yaml")

  depends_on = [
    kubectl_manifest.prometeus-operator-service-operator

  ]
}

resource "kubectl_manifest" "prometeus-cluster-role" {
  yaml_body  = file("./prometheus/2-prometheus/1-cluster-role.yaml")
  depends_on = [
    kubectl_manifest.prometeus-service-account
  ]
}

resource "kubectl_manifest" "prometeus-cluster-role-binding" {
  yaml_body  = file("./prometheus/2-prometheus/2-cluster-role-binding.yaml")
  depends_on = [
    kubectl_manifest.prometeus-cluster-role
  ]
}

resource "kubectl_manifest" "prometeus-prometheus" {
  yaml_body  = file("./prometheus/2-prometheus/3-prometheus.yaml")
  depends_on = [
    kubectl_manifest.prometeus-cluster-role-binding
  ]
}
