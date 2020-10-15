package(default_visibility = ["//visibility:public"])

load("//helm:helm.bzl", "helm_chart", "helm_release", "helm_push")
load("//k8s:k8s.bzl", "k8s_namespace", "k8s_workload_identity")
load("@com_github_masmovil_bazel_rules//sops:sops.bzl", "sops_decrypt")

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

sops_decrypt(
  name = "sops",
  srcs = [
    ":secrets.yaml"
  ],
  sops_yaml = ":.sops.yaml"
)

helm_release(
  name = "nginx_helm_release_sops",
  chart = ":nginx_chart",
  namespace = "test-nginx-sops",
  release_name = "test-nginx-sops",
  tiller_namespace = "tiller-system",
  values_yaml = [":sops"]
)

k8s_namespace(
  name = "test-namespace",
  namespace_name = "test-namespace",
)

helm_release(
  name = "nginx_helm_release_namespace",
  chart = ":nginx_chart",
  namespace_dep = ":test-namespace",
  release_name = "test-nginx-namespace"
)

k8s_namespace(
  name = "test-sa-namespace",
  namespace_name = "test-sa"
)

k8s_workload_identity(
  name = "test-sa",
  namespace = ":test-sa-namespace",
  kubernetes_sa = "default",
  gcp_sa_project = "test-project",
  gcp_sa = "test@test.iam.gserviceaccount.com",
  gcp_gke_project = "test-gke-project",
  workload_identity_namespace = "test-sa-namespace.svc.id.goog",
)

helm_release(
  name = "nginx_helm_release_workload",
  chart = ":nginx_chart",
  namespace_dep = ":test-sa-namespace",
  deps = [
    ":test-sa"
  ],
  release_name = "test-nginx-workload"
)
