"""DEPRECATED: public definitions for helm_rules.
These definitions are marked as deprecated. Instead, def.bzl should be used.
"""

load(
    ":def.bzl",
    _helm_package = "helm_package",
    _ChartInfo = "ChartInfo",
    _helm_chart_dependency = "helm_chart_dependency",
    _helm_push= "helm_push",
)

helm_chart = _helm_package
helm_package = _helm_package
ChartInfo = _ChartInfo
helm_chart_dependency = _helm_chart_dependency
helm_push = _helm_push
