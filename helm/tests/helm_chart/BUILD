load("//helm:defs.bzl", "helm_chart")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":charts.bzl", "get_charts")
load("//helm/tests/helm_chart:chart_test.bzl", "chart_test", "add_prefix_to_paths")

[
  helm_chart(
    name = "chart_%s" % chart_data.name,
    chart_name = chart_data.name,
    srcs = getattr(chart_data, "srcs", "") or glob(["charts/%s/**" % chart_data.name]),
    deps = getattr(chart_data, "deps", []),
    version = getattr(chart_data, "version", ""),
  ) for chart_data in get_charts()
]

[
  build_test(
    name = "build_%s" % chart_data.name,
    targets = [
        ":chart_%s" % chart_data.name
    ],
  ) for chart_data in get_charts()
]

chart_a_srcs = add_prefix_to_paths("charts/a", [
  "Chart.yaml",
  "values.yaml",
  "templates/_helpers.tpl",
  "templates/deployment.yaml",
  "templates/svc.yaml",
])

helm_chart(
  name = "chart_a_values_overrides",
  chart_name = "a_values",
  srcs = chart_a_srcs,
  version = "0.0.0",
  values = {
    "labels.somelabel": "testvalue",
    "labels.data": "1",
    "labels.deep.data.dict.key1": "value1",
    "labels.deep.data.dict.key2": "value2",
    "labels.deep.data.dict.key3": "value3",
  }
)

chart_test(
  name = "chart_a_values_test",
  chart = ":chart_a_values_overrides",
  chart_name = "a_values",
  prefix_srcs = "charts/a",
  expected_files = chart_a_srcs,
  expected_values = """
labels:
  somelabel: testvalue
  data: 1
  deep:
    data:
      dict:
        key1: "value1"
        key2: "value2"
        key3: "value3"
image:
  tag: latest
  repository: aio
""",
  expected_manifest = """
apiVersion: v1
name: a_values
description: Helm chart with v1 apiVersion
version: 0.0.0
appVersion: 1.5.0
""",

)

chart_b_srcs = add_prefix_to_paths("charts/b", [
  "Chart.yaml",
  "values.yaml",
  "templates/_helpers.tpl",
  "templates/deployment.yaml",
])

helm_chart(
  name = "chart_b_manifest_overrides",
  chart_name = "b_manifest",
  srcs = chart_b_srcs,
  version = "v2.3.4",
  app_version = "v1.0.0",
  api_version = "v2",
  description = "some description with testing pourposes",
)

chart_test(
  name = "chart_b_manifest_test",
  chart = ":chart_b_manifest_overrides",
  chart_name = "b_manifest",
  prefix_srcs = "charts/b",
  expected_files = chart_b_srcs,
  expected_manifest = """
apiVersion: v2
name: b_manifest
description: some description with testing pourposes
version: v2.3.4
appVersion: v1.0.0
""",

)
