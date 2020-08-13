"""Rules for manipulation k8s packages."""

load("//k8s:k8s-namespace.bzl", _k8s_namespace= "k8s_namespace", _namespace_data_info = "NamespaceDataInfo")
load("//k8s:k8s-workload-identity.bzl", _k8s_workload_identity= "k8s_workload_identity", _service_account_data_info = "ServiceAccountDataInfo")

# Explicitly re-export the functions
k8s_namespace = _k8s_namespace
NamespaceDataInfo = _namespace_data_info
k8s_workload_identity = _k8s_workload_identity
ServiceAccountDataInfo = _service_account_data_info