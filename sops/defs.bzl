
"""Rules for manipulate sops screts."""

load("//sops/private:sops_decrypt_macro.bzl", _sops_decrypt = "sops_decrypt")

# Explicitly re-export the functions
sops_decrypt = _sops_decrypt
