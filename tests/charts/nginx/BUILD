package(default_visibility = ["//visibility:public"])

load("//helm:helm-chart-package.bzl", "helm_chart")
load("//helm:helm-release.bzl", "helm_release")

helm_chart(
  name = "nginx_chart",
  srcs = glob(["**"]),
  image_tag  = "latest",
  image_repository  = "nginx",
  helm_chart_version = "1.0.0",
  package_name = "nginx",
  values_tag_yaml_path = "image.tag",
  values_repo_yaml_path = "image.repository"
)

helm_chart(
  name = "nginx_chart_make",
  srcs = glob(["**"]),
  image_tag  = "{TEST_IMAGE_TAG}",
  image_repository  = "nginx",
  helm_chart_version = "1.0.0",
  package_name = "nginx",
  values_tag_yaml_path = "image.tag",
  values_repo_yaml_path = "image.repository"
)

helm_release(
  name = "nginx_helm_release",
  chart = ":nginx_chart",
  namespace = "test-nginx",
  release_name = "test-nginx",
  values_yaml = glob(["values.yaml"]),
  tiller_namespace = "tiller-system"
)