# Load docker image providers
load(
    "@io_bazel_rules_docker//container:providers.bzl",
    "ImageInfo"
)

load("@bazel_skylib//lib:paths.bzl", "paths")

ChartInfo = provider(fields = [
    "chart",
    "chart_name",
    "chart_version",
    "transitive_deps"
])

def _helm_package_impl(ctx):
    targz = ctx.actions.declare_file(ctx.attr.chart_name + "-" + ctx.attr.version + ".tgz")
    chart_root_path = ""

    inputs = []

    inputs += ctx.files.srcs

    args = ctx.actions.args()

    # Extract image digest from container image info provider
    if ctx.attr.image:
        imageProvider = ctx.attr.image[ImageInfo]
        digest_file = imageProvider.container_parts["digest"]
        digest_path = digest_file.path
        inputs = inputs + [digest_file]
        args.add("--digest_path", digest_path)
    else:
        # Use explicit tag from image_tag argument
        image_tag = ctx.attr.image_tag
        args.add("--image_tag", ctx.attr.image_tag)

    # Locate chart root path trying to find Chart.yaml file
    for i, srcfile in enumerate(ctx.files.srcs):
        if srcfile.path.endswith("Chart.yaml"):
            if paths.basename(paths.dirname(srcfile.path)) == ctx.attr.chart_name:
                chart_root_path = srcfile.dirname
                break
            else:
                fail("Chart folder name does not match the name of the helm chart")

    # Check version attribute if no chart sources are provided
    if len(enumerate(ctx.files.srcs)) == 0 or chart_root_path == "":
        if ctx.attr.version == "" and ctx.attr.chart_version == "":
            fail("Version attribute of the chart must be provided")

    api_version = ctx.attr.api_version

    # Api version must be set in Chart.yaml. Force v2 if no apiversion
    # is specified and no src files are provided
    if api_version == "" and len(ctx.files.srcs) == 0:
        api_version = "v2"

    if ctx.attr.debug:
        debug = "true"
    else:
        debug = "false"

    args.add("--out_dir", targz.dirname)
    args.add("--chart_root_path", chart_root_path)
    args.add("--chart_name", ctx.attr.chart_name)
    args.add("--version", ctx.attr.version or ctx.attr.chart_version)
    args.add_all("--tags", ctx.attr.chart_tags)
    args.add("--api_version", api_version)
    args.add("--values_repo_path", ctx.attr.values_repo_yaml_path)
    args.add("--values_tag_path", ctx.attr.values_tag_yaml_path)
    args.add("--image_repository", ctx.attr.image_repository)


    if len(ctx.attr.app_version) > 0:
        args.add("--app_version", ctx.attr.app_version)
    if len(ctx.attr.description) > 0:
        args.add("--description", ctx.attr.description)
    if len(ctx.attr.condition) > 0:
        args.add("--condition", ctx.attr.condition)
    if len(ctx.attr.keywords) > 0:
        args.add("--keywords", ctx.attr.keywords)
    if len(ctx.attr.kube_version) > 0:
        args.add("--kube_version", ctx.attr.kube_version)
    if len(ctx.attr.values) > 0:
        args.add("--values", ctx.attr.values)

    for _, template in enumerate(ctx.files.templates):
        args.add("--template", template)
        inputs += [template]

    for _, file in enumerate(ctx.files.files):
        args.add("--file", file)
        inputs += [file]

    for _, value_file in enumerate(ctx.files.value_files):
        args.add("--value_file", value_file )
        inputs += [value_file]

    for i, dep in enumerate(ctx.files.deps):
        args.add("--chart_dep", dep)
        inputs += [dep]

    if len(enumerate(ctx.files.chart_deps)) > 0:
        print("""
        WARNING: chart_deps attribute is marked as deprecated and may not be supported in the next major release.
        """)

        for i, dep in enumerate(ctx.files.chart_deps):
            args.add("--chart_dep", dep)
            inputs += [dep]

    args.add("--debug", debug)

    ctx.actions.run(
        inputs = inputs,
        outputs = [targz],
        arguments = [args],
        env = {},
        tools = [],
        executable = ctx.file._bin_go,
        mnemonic = "helmpackaging"
    )

    direct_deps = depset([targz])
    transitive_deps = depset([targz], transitive = [depset(ctx.files.chart_deps)])

    return [
        DefaultInfo(
            files = direct_deps
        ),
        ChartInfo(
            chart = direct_deps,
            transitive_deps = transitive_deps,
            chart_name = ctx.attr.chart_name,
            chart_version = ctx.attr.version,
        )
    ]

helm_package = rule(
    implementation = _helm_package_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = False),
        "image": attr.label(allow_single_file = True, mandatory = False, providers = [ImageInfo]),
        "image_tag": attr.string(mandatory = False),
        "chart_name": attr.string(mandatory = True),
        "chart_tags": attr.string_list(mandatory = False),
        "keywords": attr.string(mandatory = False),
        "condition": attr.string(mandatory = False),
        "description": attr.string(mandatory = False),
        # deprecated
        "chart_version": attr.string(mandatory = False, default = "1.0.0"),
        #
        "version": attr.string(mandatory = False, default = "1.0.0"),
        "app_version": attr.string(mandatory = False),
        "api_version": attr.string(mandatory = False),
        "kube_version": attr.string(mandatory = False),
        "image_repository": attr.string(),
        "values_repo_yaml_path": attr.string(default = "base.k8s.deployment.image.repository"),
        "values_tag_yaml_path": attr.string(default = "base.k8s.deployment.image.tag"),
        # deprecated
        "chart_deps": attr.label_list(allow_files = True, mandatory = False),
        #
        "deps": attr.label_list(allow_files = True, mandatory = False),
        "templates": attr.label_list(allow_files = True, mandatory = False),
        "files": attr.label_list(allow_files = True, mandatory = False),
        "value_files": attr.label_list(allow_files = True, mandatory = False),
        "values": attr.string(mandatory = False),
        # deprecated
        "values_app_version_path": attr.string(default = "base.appVersion"),
        #
        "debug": attr.bool(mandatory = False, default = False),
        "_bin_go": attr.label(allow_single_file = True, default = ":helm_package"),
    },
    doc = "Runs helm packaging updating the image tag on it",
)
