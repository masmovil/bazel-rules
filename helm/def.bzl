"""def.bzl contains public definitions for helm_rules.
These definitions may be used by Bazel projects for building helm packages.
These definitions should be loaded from here, not any internal directory.
Internal definitions may change without notice.
"""

load(
    "@com_github_masmovil_bazel_rules//helm/private/package:helm_package.bzl",
    _helm_package = "helm_package",
    _ChartInfo = "ChartInfo"
)

load(
    "@com_github_masmovil_bazel_rules//helm/private/repository:chart_dep.bzl",
    _helm_chart_dependency = "helm_chart_dependency",
)

load(
    "@com_github_masmovil_bazel_rules//helm/private/push:helm_push.bzl",
    _helm_push= "helm_push",
)


helm_chart = _helm_package
helm_package = _helm_package
ChartInfo = _ChartInfo
helm_chart_dependency = _helm_chart_dependency
helm_push = _helm_push
