load("//helpers:helpers.bzl", "get_make_value_or_default", "write_sh")
load("@aspect_bazel_lib//lib/private:copy_to_bin.bzl", "copy_files_to_bin_actions")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:shell.bzl", "shell")

ChartInfo = provider(fields = [
    "chart",
    "chart_name",
    "chart_version",
    "transitive_deps"
])

# Utility function to normalize yaml paths for yq tool
def normalize_yaml_path(yaml_path):
    if not yaml_path or yaml_path.startswith("."):
        return yaml_path

    if yaml_path and not yaml_path.startswith("."):
        return "." + yaml_path


def _helm_package_impl(ctx):
    """Defines a helm chart (directory containing a Chart.yaml).
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """
    chart_root_path = ""

    digest_path = ""
    image_tag = ""
    helm_chart_version = get_make_value_or_default(ctx, ctx.attr.helm_chart_version)
    app_version = get_make_value_or_default(ctx, ctx.attr.app_version or helm_chart_version)
    yq_bin = ctx.toolchains["@aspect_bazel_lib//lib:yq_toolchain_type"].yqinfo.bin
    copy_to_directory_bin = ctx.toolchains["@aspect_bazel_lib//lib:copy_to_directory_toolchain_type"].copy_to_directory_info.bin
    stamp_files = [ctx.info_file, ctx.version_file]
    chart_name = ctx.attr.chart_name or ctx.attr.package_name

    deps = ctx.attr.chart_deps or []

    inputs = [yq_bin] + deps + ctx.files.srcs

    # locate Chart.yaml file
    for i, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.endswith("Chart.yaml"):
            chart_root_path = srcfile.dirname
            break

    if not chart_root_path:
        fail("Chart.yaml file not found. You must provide valid chart files as src to the rule")

    # chart directory has to be the same as the chart name for helm
    if not chart_name:
        chart_name = paths.basename(chart_root_path)

    copy_files = []

    # copy all chart source files to the output bin directory
    # helm does not support providing values.yaml files as command arguments
    # (useful to provide a values.yaml file from a different directory)
    # so values.yaml is not copied to the output dir here
    for file in ctx.files.srcs:
        if paths.join(chart_name, "values.yaml") not in file.path:
            copy_files.append(file)

    copied_src_files = copy_files_to_bin_actions(
        ctx = ctx,
        files = copy_files,
    )

    inputs += copied_src_files

    # Dictionary structure to hold substitute values
    # Used to replace values.yaml chart file
    values = {}

    default_values_yaml_path = paths.join(chart_root_path, "values.yaml")

    is_image_from_oci = ctx.attr.image

    # image digest is extracted from a file placed in bazel out
    image_digest_shell_expr = ''

    # extract iamge digest from oci bazel rule output
    if is_image_from_oci:
        formatted_digest = ctx.actions.declare_file("%s_image_formatted_digest.yaml" % ctx.label.name)
        digest_file = ctx.file.image
        ctx.actions.run_shell(
            tools = [],
            inputs = [digest_file],
            outputs = [formatted_digest],
            command = "cat %s| awk -F':' '{print $2}' > %s" % (digest_file.path, formatted_digest.path),
            progress_message = "Reading oci image digest sha256...",
            mnemonic = "FormatDigest",
        )

        inputs = inputs + [formatted_digest]

        # extract digest from digest formatted file
        image_digest_shell_expr = "$(cat {formatted_digest})".format(
            formatted_digest=formatted_digest.path
        )
    else:
        # extract docker image info from make variable or from rule attribute
        values[ctx.attr.values_tag_yaml_path] = get_make_value_or_default(ctx, ctx.attr.image_tag)

    # image repository substitution is extracted from values.yaml if force_append_repository attr is provided
    image_repo_shell_expr = ''

    if ctx.attr.image_repository:
        _image_repository = ctx.attr.image_repository

        if is_image_from_oci:
            if not _image_repository and ctx.attr.force_append_repository:
                # Add @sha256 suffix to image repository
                image_repo_shell_expr = "$({yq} {repo} {values})@sha256".format(
                    yq=yq_bin.path,
                    repo=ctx.attr.values_repo_yaml_path,
                    values=default_values_yaml_path,
                )
            else:
                _image_repository += "@sha256"

        if not image_repo_shell_expr:
            values[ctx.attr.values_repo_yaml_path] = _image_repository

    all_values = dicts.add({}, ctx.attr.values, values)

    subst_values = ""

    # generate values substiution expressions for yq
    for yaml_path, value in all_values.items():
        if len(subst_values) > 0:
            subst_values += " |\n"

        yaml_path = normalize_yaml_path(yaml_path)

        subst_values += "{yaml} = \"{value}\"".format(yaml=yaml_path, value=value)

    yq_expression_file = ctx.actions.declare_file(ctx.attr.name + "_yq_values_subst_expression_file")

    ctx.actions.write(
        output = yq_expression_file,
        content = subst_values
    )

    output_values_script_yaml = ctx.actions.declare_file("subst_values.sh")
    output_values_yaml = ctx.actions.declare_file("values.yaml")

    ctx.actions.expand_template(
        template = ctx.file._subst_template,
        output = output_values_script_yaml,
        is_executable = True,
        substitutions = {
            "{yq}": yq_bin.path,
            "{expression}": yq_expression_file.path,
            "{out}": output_values_yaml.path,
            "{values}": default_values_yaml_path,
            "{image_digest_expr}": image_digest_shell_expr,
            "{image_tag_path}": normalize_yaml_path(ctx.attr.values_tag_yaml_path),
            "{image_repo_expr}": image_repo_shell_expr,
            "{image_repo_path}": normalize_yaml_path(ctx.attr.values_repo_yaml_path),
        },
    )

    ctx.actions.run(
        inputs = inputs + [yq_expression_file, output_values_script_yaml],
        outputs = [output_values_yaml],
        executable = output_values_script_yaml,
        progress_message = "Writing values to chart values.yaml file...",
        mnemonic = "SubstChartValues",
    )

    direct_deps = depset(copied_src_files + [output_values_yaml])

    return [
        DefaultInfo(
            files = direct_deps,
        ),
        ChartInfo(
            chart = direct_deps,
            transitive_deps = depset(ctx.files.chart_deps),
            chart_name = chart_name,
            chart_version = ctx.attr.version,
        ),
    ]

helm_package = rule(
    implementation = _helm_package_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "image": attr.label(allow_single_file = True, mandatory = False),
        "values_tag_yaml_path": attr.string(default = "image.tag"),
        "chart_name": attr.string(mandatory = False),
        "helm_chart_version": attr.string(mandatory = False, default = "1.0.0"),
        "app_version": attr.string(mandatory = False),
        "version": attr.string(mandatory = False),
        "_script_template": attr.label(allow_single_file = True, default = ":helm_package.sh.tpl"),
        "_subst_template": attr.label(allow_single_file = True, default = ":substitute.sh.tpl"),
        "chart_deps": attr.label_list(allow_files = True, mandatory = False),
        "templates": attr.label_list(allow_files = True, mandatory = False),
        "values": attr.string_dict(),
        "force_append_repository": attr.bool(default = True),
        # Mark these attrs as deprecated
        "package_name": attr.string(mandatory = False),
        "additional_templates": attr.label_list(allow_files = True, mandatory = False),
        "image_tag": attr.string(mandatory = False),
        "image_repository": attr.string(),
        "values_repo_yaml_path": attr.string(default = "image.repository"),
    },
    toolchains = [
        "@aspect_bazel_lib//lib:yq_toolchain_type",
        "@aspect_bazel_lib//lib:copy_to_directory_toolchain_type"
    ],
    doc = "Runs helm packaging updating the image tag on it",
)
