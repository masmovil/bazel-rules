"""def.bzl contains public definitions for helm_rules.
These definitions may be used by Bazel projects for building helm packages.
These definitions should be loaded from here, not any internal directory.
Internal definitions may change without notice.
"""

load(
    "@com_github_masmovil_bazel_rules//toolchains/helm:repositories.bzl",
    _helm_configure = "helm_configure",
)


helm_configure = _helm_configure
