# Internal use only.
# Install rule dependencies for local testing pourposes only (rule authors).

load("@masmovil_bazel_rules//toolchains:register.bzl", "register_helm_toolchains", "register_sops_toolchains", "register_gcloud_toolchains", "register_kubectl_toolchains")
load("@masmovil_bazel_rules//toolchains/helm:toolchain.bzl", "HELM_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/sops:toolchain.bzl", "SOPS_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/gcloud:toolchain.bzl", "GCLOUD_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/kubectl:toolchain.bzl", "KUBECTL_DEFAULT_VERSION")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def masmovil_bazel_rules_toolchains_repos():
    register_helm_toolchains("helm", HELM_DEFAULT_VERSION)
    register_sops_toolchains("sops", SOPS_DEFAULT_VERSION)
    register_gcloud_toolchains("gcloud", GCLOUD_DEFAULT_VERSION)
    register_kubectl_toolchains("kubectl", KUBECTL_DEFAULT_VERSION)

def docker_rules_repos():
    http_archive(
        name = "io_bazel_rules_docker",
        sha256 = "b1e80761a8a8243d03ebca8845e9cc1ba6c82ce7c5179ce2b295cd36f7e394bf",
        urls = ["https://github.com/bazelbuild/rules_docker/releases/download/v0.25.0/rules_docker-v0.25.0.tar.gz"],
    )
