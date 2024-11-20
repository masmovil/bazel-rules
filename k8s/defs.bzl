"""Rules for manipulate k8s resources"""

load("//k8s/private:k8s_namespace.bzl", _k8s_namespace= "k8s_namespace", _namespace_data_info = "NamespaceDataInfo")

# Explicitly re-export the functions
k8s_namespace = _k8s_namespace
NamespaceDataInfo = _namespace_data_info
