# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_secretproviderclasses-crd" {
  yaml_body = file("./secrets-store-csi-driver/0-secretproviderclasses-crd.yaml")
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_secretproviderclasspodstatuses-crd" {
  yaml_body = file("./secrets-store-csi-driver/1-secretproviderclasspodstatuses-crd.yaml")
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_service-account" {
  yaml_body = file("./secrets-store-csi-driver/2-service-account.yaml")
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_cluster-role" {
  yaml_body = file("./secrets-store-csi-driver/3-cluster-role.yaml")
}
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_cluster-role-binding" {
  yaml_body = file("./secrets-store-csi-driver/4-cluster-role-binding.yaml")
}

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_secretprovidersyncing" {
  yaml_body = file("./secrets-store-csi-driver/4-1-rbac-secretprovidersyncing.yaml")
}
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_daemonset" {
  yaml_body = file("./secrets-store-csi-driver/5-daemonset.yaml")
}

# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "secret-store-csi-driver_csi-driver" {
  yaml_body = file("./secrets-store-csi-driver/6-csi-driver.yaml")
}