load("//helm/private:helm_toolchain.bzl", "helm_repo", "helm_toolchain_configure", "HELM_VERSIONS")
load("//gcs/private:gcloud_toolchain.bzl", "gcloud_repo", "gcloud_toolchain_configure", "GCLOUD_VERSIONS")
load("//k8s/private:kubectl_toolchain.bzl", "kubectl_repo", "kubectl_toolchain_configure", "KUBECTL_VERSIONS")
load("//sops/private:sops_toolchain.bzl", "sops_repo", "sops_toolchain_configure", "SOPS_VERSIONS")

def register_helm_toolchains(name, version, register = False):
    helm_platforms = HELM_VERSIONS[version]

    for platform, sha in helm_platforms.items():
        helm_repo(name="%s_%s" % (name, platform), version=version, platform=platform, sha=sha)

    helm_toolchain_configure(name="%s_toolchains" % name)

    if register:
        native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

def register_sops_toolchains(name, version, register = False):
    sops_platforms = SOPS_VERSIONS[version]

    for platform, sha in sops_platforms.items():
        sops_repo(name="%s.%s" % (name, platform.replace("_", ".")), version=version, platform=platform, sha=sha)

    sops_toolchain_configure(name="%s_toolchains" % name)

    if register:
        native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

def register_gcloud_toolchains(name, version, register = False):
    gcloud_platforms = GCLOUD_VERSIONS[version]

    for platform, sha in gcloud_platforms.items():
        gcloud_repo(name="%s_%s" % (name, platform), version=version, platform=platform, sha=sha)

    gcloud_toolchain_configure(name="%s_toolchains" % name)

    if register:
        native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

def register_kubectl_toolchains(name, version, register = False):
    kubectl_platforms = KUBECTL_VERSIONS[version]

    for platform, sha in kubectl_platforms.items():
        kubectl_repo(name="%s_%s" % (name, platform), version=version, platform=platform, sha=sha)

    kubectl_toolchain_configure(name="%s_toolchains" % name)

    if register:
        native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))
