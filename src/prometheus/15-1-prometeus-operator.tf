resource "kubectl_manifest" "prometeus-operator-monitoring" {
  yaml_body  = file("./prometheus/1-prometheus-operator/0-monitoring-ns.yaml")
  depends_on = [
    kubectl_manifest.prometeus-crd-thanosrulers,
  ]
}
resource "kubectl_manifest" "prometeus-operator-crd-cluster-roles" {
  yaml_body  = file("./prometheus/1-prometheus-operator/1-crd-cluster-roles.yaml")
  depends_on = [
    kubectl_manifest.prometeus-operator-monitoring
  ]
}
resource "kubectl_manifest" "prometeus-operator-service-account" {
  yaml_body  = file("./prometheus/1-prometheus-operator/2-service-account.yaml")
  depends_on = [
    kubectl_manifest.prometeus-operator-crd-cluster-roles
  ]
}
resource "kubectl_manifest" "prometeus-operator-cluster-role" {
  yaml_body  = file("./prometheus/1-prometheus-operator/3-cluster-role.yaml")
  depends_on = [
    kubectl_manifest.prometeus-operator-service-account
  ]
}
resource "kubectl_manifest" "prometeus-operator-cluster-role-binding" {
  yaml_body  = file("./prometheus/1-prometheus-operator/4-cluster-role-binding.yaml")
  depends_on = [
    kubectl_manifest.prometeus-operator-cluster-role
  ]
}
resource "kubectl_manifest" "prometeus-operator-deployment" {
  yaml_body  = file("./prometheus/1-prometheus-operator/5-deployment.yaml")
  depends_on = [
    kubectl_manifest.prometeus-operator-cluster-role-binding
  ]
}
resource "kubectl_manifest" "prometeus-operator-service" {
  yaml_body  = file("./prometheus/1-prometheus-operator/6-service.yaml")
  depends_on = [
    kubectl_manifest.prometeus-operator-deployment
  ]
}
resource "kubectl_manifest" "prometeus-operator-service-operator" {
  yaml_body  = file("./prometheus/1-prometheus-operator/7-service-operator.yaml")
  depends_on = [
    kubectl_manifest.prometeus-operator-service

  ]
}
