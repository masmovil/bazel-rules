package(default_visibility = ["//visibility:private"])

load(":kubectl_toolchain.bzl", "kubectl_toolchain")

toolchain_type(name = "toolchain_type", visibility = ["//visibility:public"])

# Helm toolchain that points to helm binary version 2.13.0
kubectl_toolchain(
    name = "kubectl_darwin",
    tool = "@kubectl_darwin//file",
    visibility = ["//visibility:public"],
)

kubectl_toolchain(
    name = "kubectl_linux",
    tool = "@kubectl_linux//file",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "kubectl_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":kubectl_linux",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "kubectl_linux_arm_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":kubectl_linux_arm",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "kubectl_osx_toolchain",
    target_compatible_with = [
        "@platforms//os:osx",
    ],
    toolchain = ":kubectl_darwin",
    toolchain_type = ":toolchain_type",
)

toolchain(
    name = "kubectl_osx_toolchain_arm",
    target_compatible_with = [
        "@platforms//os:osx",
    ],
    toolchain = ":kubectl_darwin_arm",
    toolchain_type = ":toolchain_type",
)
