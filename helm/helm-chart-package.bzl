# Load docker image providers
load(
    "@io_bazel_rules_docker//container:providers.bzl",
    "ImageInfo",
    "LayerInfo",
)

load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")

def _helm_chart_impl(ctx):
    """Defines a helm chart (directory containing a Chart.yaml).
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """
    chart_src = ""
    chart_values_path = ""
    chart_manifest_path = ""
    digest_path = ""
    image_tag = ""
    helm_chart_version = get_make_value_or_default(ctx, ctx.attr.helm_chart_version)

    # declare output file
    targz = ctx.actions.declare_file(ctx.attr.package_name + "-" + helm_chart_version + ".tgz")

    if (not ctx.attr.image_tag) and (not ctx.attr.image):
        fail("Error: 'image' or 'image_tag' arguments must be provided.")

    for i, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.endswith("Chart.yaml"):
            chart_src = srcfile.dirname
            chart_manifest_path = srcfile.path
            break

    for i, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.endswith("values.yaml"):
            chart_values_path = srcfile.path
            break

    inputs = ctx.files.srcs

    if ctx.attr.image:
        digest_file = ctx.attr.image[ImageInfo].container_parts["digest"]
        digest_path = digest_file.path
        inputs = inputs + [ctx.file.image, digest_file]
    else:
        image_tag = get_make_value_or_default(ctx, ctx.attr.image_tag)

    exec_file = ctx.actions.declare_file(ctx.label.name + "_helm_bash")

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{CHART_PATH}": chart_src,
            "{CHART_VALUES_PATH}": chart_values_path,
            "{CHART_MANIFEST_PATH}": chart_manifest_path,
            "{DIGEST_PATH}": digest_path,
            "{IMAGE_TAG}": image_tag,
            "{YQ_PATH}": ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/yq:toolchain_type"].yqinfo.tool_path,
            "{PACKAGE_OUTPUT_PATH}": targz.dirname,
            "{IMAGE_REPOSITORY}": ctx.attr.image_repository,
            "{HELM_CHART_VERSION}": helm_chart_version,
            "{VALUES_REPO_YAML_PATH}": ctx.attr.values_repo_yaml_path,
            "{VALUES_TAG_YAML_PATH}": ctx.attr.values_tag_yaml_path
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

    return [DefaultInfo(
        files = depset([targz])
    )]

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
    },
    toolchains = ["@com_github_masmovil_bazel_rules//toolchains/yq:toolchain_type"],
    doc = "Runs helm packaging updating the image tag on it",
)
