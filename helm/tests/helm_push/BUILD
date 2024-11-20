load("//helm:defs.bzl", "helm_push", "helm_chart")

# push to local repo
helm_push(
    name = "push_local_registry",
    chart = "//helm/tests/helm_chart:chart_a_values_overrides",
    repository_url = "http://localhost:8080/api/charts",
)

helm_chart(
  name = "chart_to_push",
  chart_name = "chartpush",
  version = "v2.3.4",
  app_version = "v1.0.0",
  api_version = "v2",
  description = "Random description",
  templates = [
    "files/svc.yaml",
  ]
)

# push to local repo using repo_url, repo_config and repo_name attrs
# helm_push(
#     name = "push_local_registry_repo_conf_all",
#     chart = ":chart_to_push",
#     repository_url = "http://localhost:1111/api/charts",
#     repository_config = "repoconfig.yaml",
#     repository_name = "localhost",
# )

# push to local repo using repo_url, repo_config attrs without repo_name
helm_push(
    name = "push_local_registry_repo_conf_url",
    chart = ":chart_to_push",
    repository_url = "http://localhost:8080/api/charts",
    repository_config = "repoconfig.yaml",
)

# push to local repo using repo_config and repo_name attrs
# helm_push(
#     name = "push_local_registry_repo_conf",
#     chart = "//helm/tests/helm_chart:chart_a_values_overrides",
#     repository_config = "repoconfig.yaml",
#     repository_name = "localhost",
# )
