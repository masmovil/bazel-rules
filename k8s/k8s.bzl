"""Rules for manipulation k8s packages."""

load("//k8s:k8s-namespace.bzl", _k8s_namespace= "k8s_namespace", _namespace_data_info = "NamespaceDataInfo")
load("//k8s:k8s-sa.bzl", _k8s_service_account= "k8s_service_account", _service_account_data_info = "ServiceAccountDataInfo")

# Explicitly re-export the functions
k8s_namespace = _k8s_namespace
NamespaceDataInfo = _namespace_data_info
k8s_service_account = _k8s_service_account
ServiceAccountDataInfo = _service_account_data_info