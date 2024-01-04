load("//k8s:k8s.bzl", "NamespaceDataInfo")

_DOC = """
  Installs or upgrades a helm chart in to a cluster using helm binary.

  To load the rule use:
  ```starlark
  load("//helm:defs.bzl", "helm_release")
  ```
"""

_ATTRS = {
  "chart": attr.label(allow_single_file = True, mandatory = True, doc = """
    The packaged chart archive to be published. It can be a reference to a `helm_chart` rule or a reference to a helm archived file"""
  ),
  "namespace": attr.string(default = "default", doc = "The namespace where to install the helm release."),
  "namespace_dep": attr.label(mandatory = False, doc = "A reference to a `k8s_namespace` rule from where to extract the namespace to be used to install the release."),
  "values": attr.label_list(allow_files = True, default = [], doc = "A list of value files to be provided to helm install command through -f flag."),
  "release_name": attr.string(mandatory = True, doc = "The name of the helm release to be installed or upgraded."),
  "kubernetes_context": attr.label(mandatory = False, allow_single_file = True, doc = "Reference to a kubernetes context file used by helm binary."),
  "create_namespace": attr.bool(default = True, doc = "A flag to indicate helm binary to create the kubernetes namespace if it is not already present in the cluster."),
  "wait": attr.bool(default = True, doc = "Helm flag to wait for all resources to be created to exit."),
  "set": attr.string_dict(doc = """
    A dictionary of key value pairs consisting on yaml paths and values to be replaced in the chart via --set helm option before installing it:
    "yaml.path": "value"
  """, default = {}),
  # deprecated
  "values_yaml": attr.label_list(allow_files = True, mandatory = False, doc = "[Deprecated] Use `values` attr instead"),
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
      print("WARN: values_yaml attr is marked as DEPRECATED in helm_release bazel rule. Use `values` attr instead")

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
