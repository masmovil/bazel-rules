package(default_visibility = ["//visibility:private"])

load(":toolchain.bzl", "sops_toolchain", "SOPS_PLATFORMS")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])

[(
    sops_toolchain(
        name = "sops_{platform}".format(platform=platform),
        bin = "@sops_{platform}//file".format(platform=platform),
        visibility = ["//visibility:public"],
    )
) for platform in SOPS_PLATFORMS.keys()]

[(
    toolchain(
        name = "sops_{platform}_toolchain".format(platform=platform),
        exec_compatible_with = SOPS_PLATFORMS[platform].compatible_with,
        toolchain = ":sops_{platform}".format(platform=platform),
        toolchain_type = ":toolchain_type",
    )
) for platform in SOPS_PLATFORMS.keys()]
