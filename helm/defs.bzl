"""Rules for manipulation helm packages."""

load("//helm/private:helm-chart-package.bzl", _helm_chart = "helm_chart", _chart_info = "ChartInfo")
load("//helm/private:helm-push.bzl", _helm_push = "helm_push")
load("//helm/private:helm-release.bzl", _helm_release = "helm_release")
load("//helm/private:helm_uninstall.bzl", _helm_uninstall = "helm_uninstall")
load("//helm/private:helm-lint-test.bzl", _helm_lint = "helm_lint_test")

def helm_chart(name, image="", **kwargs):
    args = kwargs

    if image:
        args["image"] = image + ".digest"

    _helm_chart(
        name = name,
        **args,
    )


# Explicitly re-export the functions
# helm_chart = _helm_chart
helm_push = _helm_push
helm_release = _helm_release
helm_uninstall = _helm_uninstall
helm_lint_test = _helm_lint
ChartInfo = _chart_info
