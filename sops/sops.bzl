"""DEPRECATED: public definitions for sops rules.
These definitions are marked as deprecated. Instead, def.bzl should be used.
"""

load(
    ":def.bzl",
    _sops_decrypt = "sops_decrypt",
)

sops_decrypt = _sops_decrypt
