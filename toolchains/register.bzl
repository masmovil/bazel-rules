load("//toolchains/helm:toolchain.bzl", "helm_repo", "helm_toolchain_configure", "HELM_VERSIONS")

def register_helm_toolchains(name, version):
    helm_platforms = HELM_VERSIONS[version]

    for platform, sha in helm_platforms.items():
        helm_repo(name="%s_%s" % (name, platform), version=version, platform=platform, sha=sha)

    helm_toolchain_configure(name="%s_toolchains" % name)
