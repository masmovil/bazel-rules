"""Rules for manipulation k8s packages."""

load("//k8s:k8s-namespace.bzl", _k8s_namespace= "k8s_namespace")

# Explicitly re-export the functions
k8s_namespace = _k8s_namespace