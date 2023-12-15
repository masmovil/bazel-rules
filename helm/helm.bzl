"""Maintained as publi export api for retro-compatibility"""

load("//helm:defs.bzl",
    _helm_package = "helm_package",
    _helm_chart = "helm_chart",
    _helm_push = "helm_push",
    _helm_release = "helm_release",
    _helm_lint = "helm_lint_test",
    _helm_uninstall = "helm_uninstall",
    _chart_info = "ChartInfo"
)

# Explicitly re-export the functions
helm_chart = _helm_chart
helm_package = _helm_package
helm_push = _helm_push
helm_release = _helm_release
helm_uninstall = _helm_uninstall
helm_lint_test = _helm_lint
ChartInfo = _chart_info
