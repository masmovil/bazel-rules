# Internal use only.
# Install rule dependencies for local testing pourposes only (rule authors).

load("@masmovil_bazel_rules//toolchains:register.bzl", "register_helm_toolchains", "register_sops_toolchains", "register_gcloud_toolchains", "register_kubectl_toolchains")
load("@masmovil_bazel_rules//toolchains/helm:toolchain.bzl", "HELM_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/sops:toolchain.bzl", "SOPS_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/gcloud:toolchain.bzl", "GCLOUD_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/kubectl:toolchain.bzl", "KUBECTL_DEFAULT_VERSION")

def masmovil_bazel_rules_internal_deps():
    register_helm_toolchains("helm", HELM_DEFAULT_VERSION)
    register_sops_toolchains("sops", SOPS_DEFAULT_VERSION)
    register_gcloud_toolchains("gcloud", GCLOUD_DEFAULT_VERSION)
    register_kubectl_toolchains("kubectl", KUBECTL_DEFAULT_VERSION)
