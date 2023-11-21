package(default_visibility = ["//visibility:public"])

load(":toolchain.bzl", "helm_toolchain", "HELM_PLATFORMS")

toolchain_type(name = "toolchain_type")

[(
    helm_toolchain(
        name = "helm_{platform}".format(platform=platform),
        bin = "helm_{platform}_bin".format(platform=platform),
        visibility = ["//visibility:public"],
    )
) for platform in HELM_PLATFORMS.keys()]

[(
    toolchain(
        name = "helm_{platform}_toolchain".format(platform=platform),
        exec_compatible_with = HELM_PLATFORMS[platform].compatible_with,
        toolchain = ":helm_{platform}".format(platform=platform),
        toolchain_type = ":toolchain_type",
    )
) for platform in HELM_PLATFORMS.keys()]
