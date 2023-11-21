load("@masmovil_bazel_rules//toolchains:register.bzl", "register_helm_toolchains")
load("@masmovil_bazel_rules//toolchains/helm:toolchain.bzl", "HELM_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/sops:toolchain.bzl", "SOPS_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/gcloud:toolchain.bzl", "GCLOUD_DEFAULT_VERSION")
load("@masmovil_bazel_rules//toolchains/kubectl:toolchain.bzl", "KUBECTL_DEFAULT_VERSION")

def _toolchains_extension_impl(mctx):
    for mod in mctx.modules:
        for attr in mod.tags.helm:
            register_helm_toolchains(attr.name, attr.version)


toolchains = module_extension(
    implementation = _toolchains_extension_impl,
    tag_classes = {
        "helm": tag_class(attrs = {"name": attr.string(default = "helm"), "version": attr.string(default = HELM_DEFAULT_VERSION)}),
        "kubectl": tag_class(attrs = {"name": attr.string(default = "kubectl"), "version": attr.string(default = KUBECTL_DEFAULT_VERSION)}),
        "gcloud": tag_class(attrs = {"name": attr.string(default = "gcloud"), "version": attr.string(default = GCLOUD_DEFAULT_VERSION)}),
        "sops": tag_class(attrs = {"name": attr.string(default = "sops"), "version": attr.string(default = SOPS_DEFAULT_VERSION)}),
    },
)
