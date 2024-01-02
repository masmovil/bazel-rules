"""Rules for manipulation helm packages."""

load("//helm/private:helm_chart_providers.bzl", _chart_info = "ChartInfo")
load("//helm/private:helm_push.bzl", _helm_push = "helm_push")
load("//helm/private:helm_release.bzl", _helm_release = "helm_release")
load("//helm/private:helm_uninstall.bzl", _helm_uninstall = "helm_uninstall")
load("//helm/private:helm_lint_test.bzl", _helm_lint = "helm_lint_test")
load("//helm/private:helm_chart.bzl", _helm_chart = "helm_chart")
load("//helm/private:helm_pull.bzl", _helm_pull = "helm_pull")

def helm_chart(name, **kwargs):
    image = kwargs.get("image")

    if image:
        _helm_chart(
            name = name,
            image_digest = image + ".digest",
            **kwargs,
        )
    else:
        _helm_chart(
            name = name,
            **kwargs,
        )


# Explicitly re-export the functions
helm_push = _helm_push
helm_pull = _helm_pull
helm_release = _helm_release
helm_uninstall = _helm_uninstall
helm_lint_test = _helm_lint
ChartInfo = _chart_info
