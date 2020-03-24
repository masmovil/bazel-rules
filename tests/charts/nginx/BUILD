package(default_visibility = ["//visibility:public"])

load("//helm:helm-chart-package.bzl", "helm_chart")
load("//helm:helm-release.bzl", "helm_release")
load("//helm:helm-push.bzl", "helm_push")

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
  name = "nginx_chart_2",
  srcs = glob(["**"]),
  image_tag  = "latest",
  image_repository  = "nginx",
  helm_chart_version = "2.0.0",
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

helm_chart(
  name = "nginx_chart_make_version",
  srcs = glob(["**"]),
  image_tag  = "nginx",
  image_repository  = "nginx",
  helm_chart_version = "{TEST_VERSION}",
  package_name = "nginx",
  values_tag_yaml_path = "image.tag",
  values_repo_yaml_path = "image.repository"
)

helm_chart(
  name = "nginx_chart_no_image",
  srcs = glob(["**"]),
  helm_chart_version = "1.0.0",
  package_name = "nginx"
)

helm_push(
  name = "nginx_push",
  chart = "nginx_chart",
  repository_name = "",
  repository_url = "http://127.0.0.1:8080/",
  repository_username = "test",
  repository_password = "test"
)

helm_push(
  name = "nginx_push_no_slash",
  chart = "nginx_chart_2",
  repository_name = "test",
  repository_url = "http://127.0.0.1:8080",
  repository_username = "test",
  repository_password = "test"
)

helm_release(
  name = "nginx_helm_release",
  chart = ":nginx_chart",
  namespace = "test-nginx",
  release_name = "test-nginx",
  tiller_namespace = "tiller-system"
)