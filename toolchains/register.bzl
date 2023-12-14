load("//toolchains/helm:toolchain.bzl", "helm_repo", "helm_toolchain_configure", "HELM_VERSIONS")
load("//toolchains/sops:toolchain.bzl", "sops_repo", "sops_toolchain_configure", "SOPS_VERSIONS")
load("//toolchains/gcloud:toolchain.bzl", "gcloud_repo", "gcloud_toolchain_configure", "GCLOUD_VERSIONS")
load("//toolchains/kubectl:toolchain.bzl", "kubectl_repo", "kubectl_toolchain_configure", "KUBECTL_VERSIONS")

def register_helm_toolchains(name, version):
    helm_platforms = HELM_VERSIONS[version]

    for platform, sha in helm_platforms.items():
        helm_repo(name="%s_%s" % (name, platform), version=version, platform=platform, sha=sha)

    helm_toolchain_configure(name="%s_toolchains" % name)

def register_sops_toolchains(name, version):
    sops_platforms = SOPS_VERSIONS[version]

    for platform, sha in sops_platforms.items():
        sops_repo(name="%s.%s" % (name, platform.replace("_", ".")), version=version, platform=platform, sha=sha)

    sops_toolchain_configure(name="%s_toolchains" % name)

def register_gcloud_toolchains(name, version):
    gcloud_platforms = GCLOUD_VERSIONS[version]

    for platform, sha in gcloud_platforms.items():
        gcloud_repo(name="%s_%s" % (name, platform), version=version, platform=platform, sha=sha)

    gcloud_toolchain_configure(name="%s_toolchains" % name)

def register_kubectl_toolchains(name, version):
    kubectl_platforms = KUBECTL_VERSIONS[version]

    for platform, sha in kubectl_platforms.items():
        kubectl_repo(name="%s_%s" % (name, platform), version=version, platform=platform, sha=sha)

    kubectl_toolchain_configure(name="%s_toolchains" % name)
