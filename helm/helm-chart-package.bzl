load(":helm-chart-package_impl.bzl", "helm_chart_imp")

def helm_chart(**ar):
  helm_chart_imp(
    yq = select({
        "@bazel_tools//src/conditions:darwin": "//libs:yq/yq_darwin",
        "@bazel_tools//src/conditions:darwin_x86_64": "//libs:yq/yq_darwin_86",
        "@bazel_tools//src/conditions:linux_x86_64": "//libs:yq/yq_linux_86",
        "//conditions:default": "//libs:yq/yq",
    }),
    **ar,
  )