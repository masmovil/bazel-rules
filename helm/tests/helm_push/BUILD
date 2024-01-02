load("//helm:defs.bzl", "helm_push")

# push to local repo
helm_push(
    name = "push_local_registry",
    chart = "//helm/tests/helm_chart:chart_a_values_overrides",
    repository_url = "http://localhost:8080/api/charts",
)
