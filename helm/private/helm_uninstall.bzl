load("//k8s:k8s.bzl", "NamespaceDataInfo")

_DOC = """

"""


_ATTRS = {
  "namespace": attr.string(mandatory = False, doc = ""),
  "namespace_dep": attr.label(mandatory = False, doc = ""),
  "release_name": attr.string(mandatory = True, doc = ""),
  "kubernetes_context": attr.label(mandatory = False, allow_single_file = True, doc = ""),
  "wait": attr.bool(default = True, doc = ""),
}
def _helm_uninstall_impl(ctx):
    """Uninstall a helm release.
    Args:
        name: A unique name for this rule.
        namespace: Namespace where the release is installed
        namespace_dep: Namespace from k8s rule
        release_name: Name of the helm release
    """
    helm_bin = ctx.toolchains["@masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.bin

    namespace = ctx.attr.namespace_dep[NamespaceDataInfo].namespace if ctx.attr.namespace_dep else ctx.attr.namespace

    args = ['uninstall', ctx.attr.release_name]

    if namespace:
        args += ["--namespace", namespace]

    if ctx.attr.kubernetes_context:
      args += ['--kube-context', ctx.attr.file.kubernetes_context.short_path]

    if ctx.attr.wait:
      args.append('--wait')

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_uninstall.sh")

    ctx.actions.write(
        output = exec_file,
        content = """
          {helm} {args}
        """.format(helm=helm_bin.path, args=" ".join(args)),
        is_executable = True
    )

    runfiles = ctx.runfiles(
        files = [
            helm_bin,
        ]
    )

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_uninstall = rule(
    implementation = _helm_uninstall_impl,
    attrs = _ATTRS,
    doc = _DOC,
    toolchains = [
        "@masmovil_bazel_rules//toolchains/helm:toolchain_type",
    ],
    executable = True,
)
