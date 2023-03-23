"""DEPRECATED: public definitions for k8s rules.
These definitions are marked as deprecated. Instead, def.bzl should be used.
"""

load(
    ":def.bzl",
    _k8s_namespace = "k8s_namespace",
    _namespace_data_info = "NamespaceDataInfo"
)

k8s_namespace = _k8s_namespace
NamespaceDataInfo = _namespace_data_info
