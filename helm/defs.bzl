"""Rules for manipulation helm packages."""

load("//helm/private:helm_package.bzl", _helm_package = "helm_package", _chart_info = "ChartInfo")
load("//helm/private:helm_push.bzl", _helm_push = "helm_push")
load("//helm/private:helm_release.bzl", _helm_release = "helm_release")
load("//helm/private:helm_uninstall.bzl", _helm_uninstall = "helm_uninstall")
load("//helm/private:helm_lint_test.bzl", _helm_lint = "helm_lint_test")

def helm_package(name, image="", **kwargs):
    args = kwargs

    if image:
        args["image"] = image + ".digest"

    _helm_package(
        name = name,
        **args,
    )


# Explicitly re-export the functions
helm_chart = helm_package
helm_push = _helm_push
helm_release = _helm_release
helm_uninstall = _helm_uninstall
helm_lint_test = _helm_lint
ChartInfo = _chart_info
