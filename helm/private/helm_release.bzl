load("//k8s:k8s.bzl", "NamespaceDataInfo")

_DOC = """
  Installs or upgrades a helm release.
  Args:
      name: A unique name for this rule.
      chart: Chart to install
      namespace: Namespace where release is installed to
      namespace_dep: Namespace from k8s rule
      release_name: Name of the helm release
      values: Specify values yaml to override default
      set: Specify key value set config
"""

_ATTRS = {
  "chart": attr.label(allow_single_file = True, mandatory = True, doc = ""),
  "namespace": attr.string(default = "default", doc = ""),
  "namespace_dep": attr.label(mandatory = False, doc = ""),
  "values": attr.label_list(allow_files = True, mandatory = False, doc = ""),
  "release_name": attr.string(mandatory = True, doc = ""),
  "kubernetes_context": attr.label(mandatory = False, allow_single_file = True, doc = ""),
  "create_namespace": attr.bool(default = True, doc = ""),
  "wait": attr.bool(default = True, doc = ""),
  "set": attr.string_dict(doc = ""),
  # "_script_template": attr.label(allow_single_file = True, default = ":helm-release.sh.tpl", doc = ""),
  # deprecated
  "values_yaml": attr.label_list(allow_files = True, mandatory = False, doc = ""),
}

def _helm_release_impl(ctx):
    helm_bin = ctx.toolchains["@masmovil_bazel_rules//toolchains/helm:toolchain_type"].helminfo.bin

    namespace = ctx.attr.namespace_dep[NamespaceDataInfo].namespace if ctx.attr.namespace_dep else ctx.attr.namespace

    args = ['upgrade', ctx.attr.release_name, ctx.file.chart.short_path, "--install", "--namespace", namespace]

    if ctx.attr.create_namespace:
      args.append('--create-namespace')

    if ctx.attr.kubernetes_context:
      args += ['--kube-context', ctx.attr.file.kubernetes_context.short_path]

    if ctx.attr.wait:
      args.append('--wait')

    for values in ctx.files.values:
      args += ['-f', values.short_path]

    if ctx.attr.values_yaml:
      print("WARN: values_yaml attr is marked as DEPRECATED in helm_release bazel rule. Use values attr instead")

    for values in ctx.files.values_yaml:
      args += ['-f', values.short_path]

    for key, value in ctx.attr.set.items():
      args += ['--set', key + '=' + value]

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_release.sh")

    ctx.actions.write(
        output = exec_file,
        content = """
          {helm} {args}
        """.format(helm=helm_bin.path, args=" ".join(args)),
        is_executable = True
    )

    runfiles = ctx.runfiles(
        files = [
            ctx.file.chart,
            ctx.info_file,
            ctx.version_file,
            helm_bin,
        ] + ctx.files.values_yaml + ctx.files.values
    )

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_release = rule(
    implementation = _helm_release_impl,
    attrs = _ATTRS,
    doc = _DOC,
    toolchains = [
        "@masmovil_bazel_rules//toolchains/helm:toolchain_type",
    ],
    executable = True,
)
