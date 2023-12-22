load("//helm:defs.bzl", "helm_chart")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load(":charts.bzl", "get_charts")

[
  helm_chart(
    name = "chart_%s" % chart_data.name,
    chart_name = chart_data.name,
    srcs = getattr(chart_data, "srcs", "") or glob(["charts/%s/**" % chart_data.name]),
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
