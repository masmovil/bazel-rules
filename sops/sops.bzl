
"""Rules for manipulate sops screts."""

load("//sops:sops-decrypt.bzl", _sops_decrypt = "sops_decrypt")

# Explicitly re-export the functions
sops_decrypt = _sops_decrypt