package(default_visibility = ["//visibility:private"])

load(":toolchain.bzl", "gcloud_toolchain", "GCLOUD_PLATFORMS")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])


[(
    gcloud_toolchain(
        name = "gcloud_{platform}".format(platform=platform),
        gcloud_bin = "@gcloud_{platform}//:gcloud".format(platform=platform),
        gsutil_bin = "@gcloud_{platform}//:gsutil".format(platform=platform),
        visibility = ["//visibility:public"],
    )
) for platform in GCLOUD_PLATFORMS.keys()]

[(
    toolchain(
        name = "gcloud_{platform}_toolchain".format(platform=platform),
        exec_compatible_with = GCLOUD_PLATFORMS[platform].compatible_with,
        toolchain = "@gcloud_toolchain_configure//:gcloud_{platform}".format(platform=platform),
        toolchain_type = ":toolchain_type",
    )
) for platform in GCLOUD_PLATFORMS.keys()]
