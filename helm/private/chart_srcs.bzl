load("//helpers:helpers.bzl", "get_make_value_or_default")
load("@aspect_bazel_lib//lib:copy_file.bzl", "copy_file_action")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:paths.bzl", "paths")
load(":helm_chart_providers.bzl", "ChartInfo")
load("@io_bazel_rules_docker//container:providers.bzl", "ImageInfo", "LayerInfo")
load("@aspect_bazel_lib//lib:stamping.bzl", "STAMP_ATTRS", "maybe_stamp")

DEFAULT_HELM_API_VERSION = "v2"
DEFAULT_HELM_CHART_VERSION = "1.0.0"

def find_outer_file(files):
    file = None if len(files) == 0 else files[0]

    for f in files:
        if len(f.path) < len(file.path):
            file = f

    return file

def filter_man_values_from_files(files):
    return [f for f in files if not f.path.endswith("Chart.yaml") and not f.path.endswith("values.yaml")]

# filter out from chart src files the Chart.yaml manifest
def locate_chart_roots(srcs, path_to_chart, name=""):
    chart_manifests = []
    values = []

    for src in srcs:
        if src.basename == "Chart.yaml":
            chart_manifests += [src]

        if src.basename == "values.yaml":
            values += [src]

    if len(chart_manifests) == 0 and len(values) == 0 and not path_to_chart:
        fail("Chart must have a Chart.yaml manifest, a values.yaml file or use explicit attr path_to_chart. Root path of the chart %s cannot be located" % name)

    manifest = find_outer_file(chart_manifests or [])
    value_file = find_outer_file(values or [])

    root_path = manifest.dirname if manifest else value_file.dirname if value_file else path_to_chart

    return struct(
        manifest=manifest,
        values=value_file,
        root=root_path,
    )

# get a dict with the content to populate a Chart.yaml manifest with data fom the helm chart
def get_manifest_subst_args(ctx, chart_deps, no_prev_manifest):
    subst_args = {}

    chart_name = ctx.attr.chart_name or ctx.attr.package_name
    version = ctx.attr.version or ctx.attr.helm_chart_version

    if ctx.attr.api_version or no_prev_manifest:
        subst_args["apiVersion"] = ctx.attr.api_version or DEFAULT_HELM_API_VERSION

    subst_args["name"] = chart_name

    if ctx.attr.description:
        subst_args["description"] = ctx.attr.description

    if version or no_prev_manifest:
        subst_args["version"] = version or DEFAULT_HELM_CHART_VERSION

    if ctx.attr.app_version:
        subst_args["appVersion"] = ctx.attr.app_version


    deps_conditions = ctx.attr.deps_conditions or {}

    for i, dep in enumerate(chart_deps):
        subst_args[".dependencies[%s].name" % i] = dep.name

        if dep.version:
            subst_args[".dependencies[%s].version" % i] = dep.version

        condition = deps_conditions.get(dep.name)

        if condition:
            subst_args[".dependencies[%s].condition" % i] = condition

    return subst_args


# generate a file with a yq write expression
def create_yq_substitution_file(ctx, output_name, substitutions):
    out_file = ctx.actions.declare_file(output_name)

    subst_values = ""

    for yaml_path, value in substitutions.items():
        if len(subst_values) > 0:
            subst_values += " |\n"

        yaml_path = normalize_yaml_path(yaml_path)

        if value.startswith("strenv("):
            subst_values += "{yaml} = {value}".format(yaml=yaml_path, value=value)
        else:
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

# function to parse stamp values variables format (${}) to envvariables read from yq (env())
def replace_stamp_values(values):
    values_to_replace = {}

    for key, value in values.items():
        if value.startswith("${") and value.endswith("}"):
            values_to_replace[key] = value.replace("${", "strenv(").replace("}", ")")

    result_dict = dicts.add({}, values, values_to_replace)

    return result_dict

def image_digest_processor(ctx):
    if not ctx.attr.image:
        return None, ""

    # docker_image_provider = ctx.attr.image[ImageInfo]
    docker_image_provider = ""

    is_oci_image = False

    # Check if image attr comes from a docker_rule or oci_image
    # look for a Docker rule ImageInfo provider
    is_oci_image = False if docker_image_provider else True

    sha_file = ""
    sha_shell_extr_expr = ""

    if is_oci_image:
        # if it's a image from oci, we get the .digest file from image_digest attr
        digest_file = ctx.file.image_digest

        sha_file = ctx.actions.declare_file("%s_image_formatted_digest.yaml" % ctx.label.name)
        ctx.actions.run_shell(
            tools = [],
            inputs = [digest_file],
            outputs = [sha_file],
            command = "cat %s| awk -F':' '{print $2}' > %s" % (digest_file.path, sha_file.path),
            progress_message = "Parse oci image digest sha256 file",
            mnemonic = "FormatDigest",
        )
    else:
        # if it's a docker image we get the digest file via bazel providers
        sha_file = docker_image_provider.container_parts["digest"]

    sha_shell_extr_expr = "$(cat {sha_file})".format(
        sha_file=sha_file.path
    )

    return sha_file, sha_shell_extr_expr



def _chart_srcs_impl(ctx):
    """Defines a helm chart (directory containing a Chart.yaml).
    Args:
        name: A unique name for this rule.
        srcs: Source files to include as the helm chart. Typically this will just be glob(["**"]).
        update_deps: Whether or not to run a helm dependency update prior to packaging.
    """
    digest_path = ""
    image_tag = ""

    helm_chart_version = get_make_value_or_default(ctx, ctx.attr.helm_chart_version)
    app_version = get_make_value_or_default(ctx, ctx.attr.app_version or helm_chart_version)
    chart_yaml = None
    yq_bin = ctx.toolchains["@aspect_bazel_lib//lib:yq_toolchain_type"].yqinfo.bin
    copy_to_directory_bin = ctx.toolchains["@aspect_bazel_lib//lib:copy_to_directory_toolchain_type"].copy_to_directory_info.bin
    stamp_files = [ctx.info_file, ctx.version_file]
    chart_name = ctx.attr.chart_name or ctx.attr.package_name

    # data structure to hold info about all chart dependencies
    # it's a tuples array with the form: (dependency_name, dependency_version, dep src_files)
    chart_deps = [
        struct(
            name=chart_dep[ChartInfo].chart_name,
            version=chart_dep[ChartInfo].chart_version,
            srcs=chart_dep[ChartInfo].chart_srcs,
        ) for chart_dep in ctx.attr.deps
    ]

    # locate rootpath of the chart
    chart_files = locate_chart_roots(ctx.files.srcs, ctx.attr.path_to_chart)
    chart_root_path = chart_files.root
    chart_yaml = chart_files.manifest

    copied_src_files = []

    # copy all chart source files to the output bin directory
    # values.yaml are not copied to the output dir here to be able to modify the sources
    for file in filter_man_values_from_files(ctx.files.srcs):
        copied_file = ctx.actions.declare_file(paths.join(chart_name, file.path.replace(chart_root_path + "/", "")))
        copied_src_files += [copied_file]
        copy_file_action(
            ctx=ctx,
            src=file,
            dst=copied_file,
        )

    # rewrite Chart.yaml to override chart info
    out_chart_yaml = ctx.actions.declare_file(paths.join(chart_name, "Chart.yaml"))

    outs = copied_src_files + [out_chart_yaml]
    values_inputs = [yq_bin] + ctx.files.srcs + copied_src_files

    yq_subst_expr = create_yq_substitution_file(ctx, "%s_yq_chart_subst_expr" % ctx.attr.name, get_manifest_subst_args(ctx, chart_deps, chart_yaml == None))

    write_manifest_action_inputs = [yq_bin, yq_subst_expr]

    if chart_yaml:
        write_manifest_action_inputs += [chart_yaml]

    ctx.actions.run_shell(
        inputs = write_manifest_action_inputs,
        outputs = [out_chart_yaml],
        command = "cat {chart_manifest}| {yq} --from-file {expr_file} > {out_path}".format(
            yq = yq_bin.path,
            expr_file = yq_subst_expr.path,
            out_path = out_chart_yaml.path,
            chart_manifest = chart_yaml.path if chart_yaml else "",
        ),
        progress_message = "Writing Chart.yaml file to chart output dir...",
        mnemonic = "SubstChartManifest",
    )

    # Dictionary structure to hold substitute values
    # Used to replace values.yaml chart file
    values = {}

    src_values_path = paths.join(chart_root_path, "values.yaml")

    is_image_from_oci = ctx.attr.image

    # image digest is extracted from a file placed in bazel out
    image_digest_shell_expr = ''

    sha_file, sha_extr_expr = image_digest_processor(ctx)

    if sha_file:
        values_inputs += [sha_file]

    if ctx.attr.image_tag:
        # extract docker image info from make variable or from rule attribute
        values[ctx.attr.values_tag_yaml_path] = get_make_value_or_default(ctx, ctx.attr.image_tag)

    if ctx.attr.image_repository:
        values[ctx.attr.values_repo_yaml_path] = ctx.attr.image_repository

    # image repository substitution is extracted from values.yaml if force_append_repository attr is provided
    image_repo_shell_expr = ''

    if ctx.attr.force_append_repository:
        _image_repository = ctx.attr.image_repository

        if is_image_from_oci:
            if not _image_repository:
                # Add @sha256 suffix to image repository based on actual values
                image_repo_shell_expr = "$({yq} {repo} {values})@sha256".format(
                    yq=yq_bin.path,
                    repo=ctx.attr.values_repo_yaml_path,
                    values=src_values_path,
                )
            else:
                values[ctx.attr.values_repo_yaml_path] = _image_repository + "@sha256"

    all_values = dicts.add({}, ctx.attr.values, values)

    stamp = maybe_stamp(ctx)

    if stamp:
        all_values = replace_stamp_values(all_values)

    yq_expression_file = create_yq_substitution_file(ctx, "%s_yq_values_subst_expression_file" % ctx.attr.name, all_values)

    output_values_script_yaml = ctx.actions.declare_file("%s_subst_values.sh" % ctx.attr.name)
    output_values_yaml = ctx.actions.declare_file(paths.join(chart_name, "values.yaml"))

    outs += [output_values_yaml]

    values_substitutions = {
        "{yq}": yq_bin.path,
        "{expression}": yq_expression_file.path,
        "{out}": output_values_yaml.path,
        "{values}": src_values_path,
        "{image_digest_expr}": sha_extr_expr,
        "{image_tag_path}": normalize_yaml_path(ctx.attr.values_tag_yaml_path),
        "{image_repo_expr}": image_repo_shell_expr,
        "{image_repo_path}": normalize_yaml_path(ctx.attr.values_repo_yaml_path)
    }

    if stamp:
        stamp_files = [stamp.volatile_status_file, stamp.stable_status_file]
        values_inputs += stamp_files
        values_substitutions = dicts.add(values_substitutions, {
            "{stable}": stamp.stable_status_file.path,
            "{volatile}": stamp.volatile_status_file.path,
            "{stamp}": "true",
            "%{stamp_statements}": "\n".join([
                "\tread_stamp_variables %s" % f.path
                for f in stamp_files
            ]),
        })

    ctx.actions.expand_template(
        template = ctx.file._subst_template,
        output = output_values_script_yaml,
        is_executable = True,
        substitutions = values_substitutions,
    )

    values_inputs += [yq_expression_file, output_values_script_yaml]

    ctx.actions.run(
        inputs = values_inputs,
        outputs = [output_values_yaml],
        executable = output_values_script_yaml,
        progress_message = "Writing values to chart values.yaml file...",
        mnemonic = "SubstChartValues",
    )

    dep_copied_files = []

    for dep in chart_deps:

        dep_chart_files = locate_chart_roots(dep.srcs, "", dep.name)

        for dep_src in dep.srcs:
            out_path = paths.join(chart_name, "charts", dep.name, dep_src.path.replace(dep_chart_files.root + "/", ""))

            dep_out = ctx.actions.declare_file(out_path)

            copy_file_action(
                ctx=ctx,
                src=dep_src,
                dst=dep_out,
            )

            dep_copied_files += [dep_out]

    return [
        DefaultInfo(
            files = depset(direct = outs, transitive = [depset(dep_copied_files)])
        )
    ]

chart_srcs = rule(
    implementation = _chart_srcs_impl,
    attrs = dict({
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "chart_name": attr.string(mandatory = True),
        "image": attr.label(allow_single_file = True, mandatory = False),
        "image_digest": attr.label(allow_single_file = True, mandatory = False),
        "values_tag_yaml_path": attr.string(default = ".image.tag"),
        "version": attr.string(mandatory = False),
        "app_version": attr.string(),
        "api_version": attr.string(),
        "description": attr.string(),
        "_subst_template": attr.label(allow_single_file = True, default = ":substitute.sh.tpl"),
        "deps": attr.label_list(allow_files = True, mandatory = False, providers = [ChartInfo]),
        "deps_conditions": attr.string_dict(),
        "templates": attr.label_list(allow_files = True, mandatory = False),
        "values": attr.string_dict(),
        "force_append_repository": attr.bool(default = True),
        "path_to_chart": attr.string(),
        # Mark these attrs as deprecated
        "chart_deps": attr.label_list(allow_files = True, mandatory = False, providers = [ChartInfo]),
        "helm_chart_version": attr.string(mandatory = False),
        "package_name": attr.string(mandatory = False),
        "additional_templates": attr.label_list(allow_files = True, mandatory = False),
        "image_tag": attr.string(mandatory = False),
        "image_repository": attr.string(),
        "values_repo_yaml_path": attr.string(default = ".image.repository"),
    }, **STAMP_ATTRS),
    toolchains = [
        "@aspect_bazel_lib//lib:yq_toolchain_type",
        "@aspect_bazel_lib//lib:copy_to_directory_toolchain_type",
    ],
    doc = "Runs helm packaging updating the image tag on it",
)
