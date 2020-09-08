# Load docker image providers
load(
    "@io_bazel_rules_docker//container:providers.bzl",
    "ImageInfo",
    "LayerInfo",
)

load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")

ChartInfo = provider(fields = [
    "chart",
])

def _helm_chart_impl(ctx):
    """Defines a helm chart (directory containing a Chart.yaml).
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """
    chart_root_path = ""
    tmp_chart_root = ""
    tmp_chart_values_path = ""
    tmp_chart_manifest_path = ""
    tmp_working_dir = "_tmp"
    inputs = [] + ctx.files.srcs

    digest_path = ""
    image_tag = ""
    helm_chart_version = get_make_value_or_default(ctx, ctx.attr.helm_chart_version)
    yq = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/yq:toolchain_type"].yqinfo.tool.files.to_list()[0].path
    stamp_files = [ctx.info_file, ctx.version_file]

    # declare rule output
    targz = ctx.actions.declare_file(ctx.attr.package_name + ".tgz")

    helm_path = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/helm-2-16:toolchain_type"].helminfo.tool.files.to_list()[0].path

    # locate chart root path trying to find Chart.yaml file
    for i, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.endswith("Chart.yaml"):
            chart_root_path = srcfile.dirname
            break

    # move chart files to temporal directory in order to manipulate necessary files
    for i, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.startswith(chart_root_path):
            out = ctx.actions.declare_file(tmp_working_dir + "/" + srcfile.path)
            inputs.append(out)

            # extract location of the chart in the new directory
            if srcfile.path.endswith("Chart.yaml"):
                tmp_chart_root = out.dirname
                tmp_chart_manifest_path = out.path

            # extract location of values file in the new directory
            # TODO: Support values.dev|sta|*.yaml
            if srcfile.path.endswith("values.yaml"):
                tmp_chart_values_path = out.path

            ctx.actions.run_shell(
                outputs = [out],
                inputs = [srcfile],
                arguments = [srcfile.path, out.path],
                command = "cp $1 $2",
            )
    if tmp_chart_root.equals(""):
        print("Chart.yaml not Found !!!!!!!!@@@@@@@"

    # extract docker image info from dependency rule
    if ctx.attr.image:
        digest_file = ctx.attr.image[ImageInfo].container_parts["digest"]
        digest_path = digest_file.path
        inputs = inputs + [ctx.file.image, digest_file]
    else:
        # extract docker image info from make variable or from rule attribute
        image_tag = get_make_value_or_default(ctx, ctx.attr.image_tag)

    deps = ctx.attr.chart_deps or []

    # copy generated charts by other rules into temporal chart_root/charts directory (treated as a helm dependency)
    for i, dep in enumerate(deps):
        dep_files = dep[DefaultInfo].files.to_list()
        out = ctx.actions.declare_file(tmp_working_dir + "/" + chart_root_path + "/charts/" + dep[DefaultInfo].files.to_list()[0].basename)
        inputs = inputs + dep_files + [out]
        ctx.actions.run_shell(
            outputs = [out],
            inputs = dep[DefaultInfo].files,
            arguments = [dep[DefaultInfo].files.to_list()[0].path, out.path],
            command = "cp -f $1 $2; tar -C $(dirname $2) -xzf $2",
            execution_requirements = {
              "local": "1",
            },
        )

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_bash")

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{CHART_PATH}": tmp_chart_root,
            "{CHART_VALUES_PATH}": tmp_chart_values_path,
            "{CHART_MANIFEST_PATH}": tmp_chart_manifest_path,
            "{DIGEST_PATH}": digest_path,
            "{IMAGE_TAG}": image_tag,
            "{YQ_PATH}": yq,
            "{PACKAGE_OUTPUT_PATH}": targz.dirname,
            "{IMAGE_REPOSITORY}": ctx.attr.image_repository,
            "{HELM_CHART_VERSION}": helm_chart_version,
            "{HELM_CHART_NAME}": ctx.attr.package_name,
            "{HELM_PATH}": helm_path,
            "{VALUES_REPO_YAML_PATH}": ctx.attr.values_repo_yaml_path,
            "{VALUES_TAG_YAML_PATH}": ctx.attr.values_tag_yaml_path,
            "%{stamp_statements}": "\n".join([
              "\tread_variables %s" % f.path
              for f in stamp_files]),
        }
    )

    ctx.actions.run(
        inputs = inputs,
        outputs = [targz],
        arguments = [],
        executable = exec_file,
        execution_requirements = {
            "local": "1",
        },
    )

    return [
        DefaultInfo(
            files = depset([targz])
        )
    ]

helm_chart = rule(
    implementation = _helm_chart_impl,
    attrs = {
      "srcs": attr.label_list(allow_files = True, mandatory = True),
      "image": attr.label(allow_single_file = True, mandatory = False),
      "image_tag": attr.string(mandatory = False),
      "package_name": attr.string(mandatory = True),
      "helm_chart_version": attr.string(mandatory = False, default = "1.0.0"),
      "image_repository": attr.string(),
      "values_repo_yaml_path": attr.string(default = "image.repository"),
      "values_tag_yaml_path": attr.string(default = "image.tag"),
      "_script_template": attr.label(allow_single_file = True, default = ":helm-chart-package.sh.tpl"),
      "chart_deps": attr.label_list(allow_files = True, mandatory = False),
    },
    toolchains = [
        "@com_github_masmovil_bazel_rules//toolchains/yq:toolchain_type",
        "@com_github_masmovil_bazel_rules//toolchains/helm-2-16:toolchain_type",
    ],
    doc = "Runs helm packaging updating the image tag on it",
)
