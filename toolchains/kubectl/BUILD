package(default_visibility = ["//visibility:private"])

load(":toolchain.bzl", "kubectl_toolchain", "KUBECTL_PLATFORMS")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])

[(
    kubectl_toolchain(
        name = "kubectl_{platform}".format(platform=platform),
        bin = "@kubectl_{platform}//file".format(platform=platform),
        visibility = ["//visibility:public"],
    )
) for platform in KUBECTL_PLATFORMS.keys()]

[(
    toolchain(
        name = "kubectl_{platform}_toolchain".format(platform=platform),
        exec_compatible_with = KUBECTL_PLATFORMS[platform].compatible_with,
        toolchain = ":kubectl_{platform}".format(platform=platform),
        toolchain_type = ":toolchain_type",
    )
) for platform in KUBECTL_PLATFORMS.keys()]
