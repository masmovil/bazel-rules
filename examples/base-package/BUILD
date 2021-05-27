package(default_visibility = ["//visibility:public"])

load("//helm:helm-chart-package.bzl", "helm_chart")
load("//helm:helm-release.bzl", "helm_release")

helm_chart(
  name = "base_package",
  srcs = glob(["**"]),
  image_tag  = "latest",
  image_repository  = "gcr.io/lab/base-replaced-by-rule-image-url",
  helm_chart_version = "1.0.0",
  package_name = "base-package",
  values_tag_yaml_path = "image.tag",
  values_repo_yaml_path = "image.repository",
)

helm_release(
  name = "base_release",
  chart = ":base_package",
  namespace = "examples",
  release_name = "base-release",
  kubernetes_context = "gke_mm-k8s-dev-02_europe-west2_mm-k8s-dev-02"
)