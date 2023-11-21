# Internal use only.
# Install rule dependencies for local testing pourposes only (rule authors).

load("@masmovil_bazel_rules//toolchains:register.bzl", "register_helm_toolchains")
load("@masmovil_bazel_rules//toolchains/helm:toolchain.bzl", "HELM_DEFAULT_VERSION")

def masmovil_bazel_rules_internal_deps():
    register_helm_toolchains("helm", HELM_DEFAULT_VERSION)
