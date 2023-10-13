"""def.bzl contains public definitions for helm_rules.
These definitions may be used by Bazel projects for using gcloud.
These definitions should be loaded from here, not any internal directory.
Internal definitions may change without notice.
"""

load(
    "@masmovil_bazel_rules//toolchains/gcloud:repositories.bzl",
    _gcloud_configure = "gcloud_configure",
)


gcloud_configure = _gcloud_configure
