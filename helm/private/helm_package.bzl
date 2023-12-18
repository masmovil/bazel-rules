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

def get_chart_subst_args(ctx):
    subst_args = {}

    chart_name = ctx.attr.chart_name or ctx.attr.package_name
    version = ctx.attr.version or ctx.attr.helm_chart_version

    if ctx.attr.api_version:
        subst_args["apiVersion"] = ctx.attr.api_version

    subst_args["name"] = chart_name

    if ctx.attr.description:
        subst_args["description"] = ctx.attr.description

    subst_args["version"] = version

    if ctx.attr.app_version:
        subst_args["appVersion"] = ctx.attr.app_version

    return subst_args


# generate a file with a write expression for yq
def create_yq_substitution_file(ctx, output_name, substitutions):
    out_file = ctx.actions.declare_file(output_name)

    subst_values = ""

    for yaml_path, value in substitutions.items():
        if len(subst_values) > 0:
            subst_values += " |\n"

        yaml_path = normalize_yaml_path(yaml_path)

        subst_values += "{yaml} = \"{value}\"".format(yaml=yaml_path, value=value)

    ctx.actions.write(
        output = out_file,
        content = subst_values
    )

    return out_file

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
    chart_manifest_path = ""

    digest_path = ""
    image_tag = ""

    helm_chart_version = get_make_value_or_default(ctx, ctx.attr.helm_chart_version)
    app_version = get_make_value_or_default(ctx, ctx.attr.app_version or helm_chart_version)
    chart_yaml = None
    yq_bin = ctx.toolchains["@aspect_bazel_lib//lib:yq_toolchain_type"].yqinfo.bin
    copy_to_directory_bin = ctx.toolchains["@aspect_bazel_lib//lib:copy_to_directory_toolchain_type"].copy_to_directory_info.bin
    stamp_files = [ctx.info_file, ctx.version_file]
    chart_name = ctx.attr.chart_name or ctx.attr.package_name

    deps = ctx.attr.chart_deps or []

    inputs = [yq_bin] + deps + ctx.files.srcs
    outs = []

    # locate rootpath of the chart
    for i, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.endswith("Chart.yaml"):
            chart_root_path = srcfile.dirname
            chart_manifest_path = srcfile.path
            break

        if srcfile.path.endswith("values.yaml") and not chart_root_path:
            chart_root_path = srcfile.dirname

    copy_files = []

    # copy all chart source files to the output bin directory
    # values.yaml are not copied to the output dir here to be able to modify the sources
    for file in ctx.files.srcs:
        if paths.join(chart_name, "values.yaml") not in file.path and paths.join(chart_name, "Chart.yaml") not in file.path:
            copy_files.append(file)

        if paths.join(chart_name, "Chart.yaml") in file.path:
            chart_yaml = file

    copied_src_files = copy_files_to_bin_actions(
        ctx = ctx,
        files = copy_files,
    )

    out_chart_yaml = ctx.actions.declare_file("Chart.yaml")

    outs += copied_src_files + [out_chart_yaml]

    # if the chart has not Chart.yaml manifest file,
    # we create one
    if not chart_manifest_path:
        ctx.actions.write(
            output = out_chart_yaml,
            content = """apiVersion: {api_version}
description: {description}
name: {name}
version: {version}
appVersion: {app_version}""".format(
                api_version=ctx.attr.api_version,
                description=ctx.attr.description or "",
                name=chart_name,
                version=ctx.attr.version or ctx.attr.helm_chart_version,
                progress_message = "Writing Chart.yaml file to Chart...",
                app_version=ctx.attr.app_version or "",
            )
        )
    else:
        yq_subst_expr = create_yq_substitution_file(ctx, "yq_chart_subst_expr", get_chart_subst_args(ctx))

        ctx.actions.run_shell(
            inputs = [yq_bin, chart_yaml, yq_subst_expr],
            outputs = [out_chart_yaml],
            command = "{yq} --from-file {expr_file} > {out_path}".format(
                yq = yq_bin.path,
                expr_file = yq_subst_expr.path,
                out_path = out_chart_yaml.path,
            ),
            progress_message = "Writing Chart.yaml file to chart output dir...",
            mnemonic = "SubstChartManifest",
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

    yq_expression_file = create_yq_substitution_file(ctx, ctx.attr.name + "_yq_values_subst_expression_file", all_values)

    output_values_script_yaml = ctx.actions.declare_file("subst_values.sh")
    output_values_yaml = ctx.actions.declare_file("values.yaml")

    outs += [output_values_yaml]

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

    direct_deps = depset(outs)

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
        "chart_name": attr.string(mandatory = True),
        "image": attr.label(allow_single_file = True, mandatory = False),
        "values_tag_yaml_path": attr.string(default = "image.tag"),
        "version": attr.string(mandatory = False),
        "app_version": attr.string(default = "1.0.0"),
        "api_version": attr.string(default = "v1"),
        "description": attr.string(default = "Helm chart"),
        "_script_template": attr.label(allow_single_file = True, default = ":helm_package.sh.tpl"),
        "_subst_template": attr.label(allow_single_file = True, default = ":substitute.sh.tpl"),
        "chart_deps": attr.label_list(allow_files = True, mandatory = False),
        "templates": attr.label_list(allow_files = True, mandatory = False),
        "values": attr.string_dict(),
        "force_append_repository": attr.bool(default = True),
        # Mark these attrs as deprecated
        "helm_chart_version": attr.string(mandatory = False, default = "1.0.0"),
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
