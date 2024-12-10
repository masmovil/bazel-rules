load("@bazel_skylib//lib:paths.bzl", "paths")
load(":sops_decrypt.bzl", sops_decrypt_rule = "sops_decrypt")

def sops_decrypt(name, srcs, sops_yaml=":.sops.yaml"):

    sops_decrypt_rule(
        name = name,
        srcs = srcs,
        sops_yaml = sops_yaml,
    )
