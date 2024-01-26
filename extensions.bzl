load("//helm:defs.bzl", "helm_pull", "pull_attrs")
load("//:toolchains.bzl", "register_helm_toolchains", "register_sops_toolchains", "register_gcloud_toolchains", "register_kubectl_toolchains")
load("//helm/private:helm_toolchain.bzl", "HELM_DEFAULT_VERSION")
load("//k8s/private:kubectl_toolchain.bzl", "KUBECTL_DEFAULT_VERSION")
load("//sops/private:sops_toolchain.bzl", "SOPS_DEFAULT_VERSION")
load("//gcs/private:gcloud_toolchain.bzl", "GCLOUD_DEFAULT_VERSION")
load("@bazel_skylib//lib:dicts.bzl", "dicts")

extended_pull_attrs = dicts.add({
    "name": attr.string(mandatory = True),
}, pull_attrs)

def _toolchains_extension_impl(mctx):
    for mod in mctx.modules:
        for attr in mod.tags.install:
            register_helm_toolchains(attr.helm_name, attr.helm_version)
            register_sops_toolchains(attr.sops_name, attr.sops_version)
            register_gcloud_toolchains(attr.gcloud_name, attr.gcloud_version)
            register_kubectl_toolchains(attr.kubectl_name, attr.kubectl_version)


toolchains = module_extension(
    implementation = _toolchains_extension_impl,
    tag_classes = {
        "install": tag_class(
            attrs = {
                "helm_name": attr.string(default = "helm"),
                "helm_version": attr.string(default = HELM_DEFAULT_VERSION),
                "kubectl_name": attr.string(default = "kubectl"),
                "kubectl_version": attr.string(default = KUBECTL_DEFAULT_VERSION),
                "gcloud_name": attr.string(default = "gcloud"),
                "gcloud_version": attr.string(default = GCLOUD_DEFAULT_VERSION),
                "sops_name": attr.string(default = "sops"),
                "sops_version": attr.string(default = SOPS_DEFAULT_VERSION),
            }
        ),
    },
)

def _utils_extension_impl(mctx):
    for mod in mctx.modules:
        for pull in mod.tags.pull:
            helm_pull(
                chart_name = pull.chart_name,
                name = pull.name,
                repo_url = pull.repo_url,
                version = pull.version,
                sha256 = pull.sha256,
            )

utils = module_extension(
    implementation = _utils_extension_impl,
    tag_classes = {
        "pull": tag_class(attrs = extended_pull_attrs),
    },
)
