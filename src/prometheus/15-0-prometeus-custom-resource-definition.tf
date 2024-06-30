resource "kubectl_manifest" "prometeus-crd-alertmanagerconfigs" {
  yaml_body = file("./prometheus/0-crd/0-alertmanagerconfigs.yaml")
}

resource "kubectl_manifest" "prometeus-crd-alertmanagers" {
  yaml_body  = file("./prometheus/0-crd/1-alertmanagers.yaml")
  depends_on = [
    kubectl_manifest.prometeus-crd-alertmanagerconfigs
  ]
}

resource "kubectl_manifest" "prometeus-crd-podmonitors" {
  yaml_body  = file("./prometheus/0-crd/2-podmonitors.yaml")
  depends_on = [
    kubectl_manifest.prometeus-crd-alertmanagerconfigs,
    kubectl_manifest.prometeus-crd-alertmanagers
  ]
}

resource "kubectl_manifest" "prometeus-crd-probes" {
  yaml_body = file("./prometheus/0-crd/3-probes.yaml")
  depends_on = [
    kubectl_manifest.prometeus-crd-alertmanagerconfigs,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-alertmanagers
  ]
}

resource "kubectl_manifest" "prometeus-crd-prometheuses" {
  yaml_body = file("./prometheus/0-crd/4-prometheuses.yaml")
  depends_on = [
    kubectl_manifest.prometeus-crd-alertmanagerconfigs,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-probes
  ]

}

resource "kubectl_manifest" "prometeus-crd-prometheusrules" {
  yaml_body = file("./prometheus/0-crd/5-prometheusrules.yaml")

  depends_on = [
    kubectl_manifest.prometeus-crd-alertmanagerconfigs,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-probes,
    kubectl_manifest.prometeus-crd-prometheuses
  ]
}

resource "kubectl_manifest" "prometeus-crd-servicemonitors" {
  yaml_body = file("./prometheus/0-crd/6-servicemonitors.yaml")
  depends_on = [
    kubectl_manifest.prometeus-crd-alertmanagerconfigs,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-probes,
    kubectl_manifest.prometeus-crd-prometheuses,
    kubectl_manifest.prometeus-crd-prometheusrules
  ]
}

resource "kubectl_manifest" "prometeus-crd-thanosrulers" {
  yaml_body = file("./prometheus/0-crd/7-thanosrulers.yaml")
  depends_on = [
    kubectl_manifest.prometeus-crd-alertmanagerconfigs,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-alertmanagers,
    kubectl_manifest.prometeus-crd-probes,
    kubectl_manifest.prometeus-crd-prometheuses,
    kubectl_manifest.prometeus-crd-prometheusrules,
    kubectl_manifest.prometeus-crd-servicemonitors
  ]
}
