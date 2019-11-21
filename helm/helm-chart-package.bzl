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

    # Generates the exec bash file with the provided substitutions
    # helm package {CHART_PATH} --destination {PACKAGE_OUTPUT_PATH} --app-version {HELM_CHART_VERSION} --version {HELM_CHART_VERSION}
    exec_file = write_sh(
        ctx,
        "helm_bash",
        """
        set -e
        set -o pipefail

        DIGEST_PATH={DIGEST_PATH}
        IMAGE_REPOSITORY={IMAGE_REPOSITORY}

        if [ -z $DIGEST_PATH ]; then
            {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_TAG_YAML_PATH} {IMAGE_TAG}
            echo "Packaged image tag: {IMAGE_TAG}"
        else
            # extracts the digest sha and removes 'sha256' text from it
            DIGEST=$(cat {DIGEST_PATH})
            IFS=':' read -ra digest_split <<< "$DIGEST"
            DIGEST_SHA=${digest_split[1]}
            {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_TAG_YAML_PATH} $DIGEST_SHA
            echo "Packaged image tag: "$DIGEST_SHA
        fi

        REPO_URL=""
        REPO_SUFIX=""

        # if the tag is a digest add @sha256 as suffix to the image.repository
        if [ ! -z $DIGEST_PATH ]; then
            REPO_SUFIX="@sha256"
            REPO_URL=$({YQ_PATH} r {CHART_VALUES_PATH} {VALUES_REPO_YAML_PATH})
        fi

        if [ ! -z $IMAGE_REPOSITORY ]; then
            REPO_URL="{IMAGE_REPOSITORY}"
        fi

        # appends suffix if REPO_URL does not already contains it
        if ([ ! -z $REPO_URL ] || [ ! -z $REPO_SUFIX ]) && [[ $REPO_URL != *"$REPO_SUFIX" ]]; then
            {YQ_PATH} w -i {CHART_VALUES_PATH} {VALUES_REPO_YAML_PATH} ${REPO_URL}${REPO_SUFIX}
        fi

        helm init -c
        helm package {CHART_PATH} --destination {PACKAGE_OUTPUT_PATH} --app-version {HELM_CHART_VERSION} --version {HELM_CHART_VERSION}
        """,
        substitutions = {
            "{CHART_PATH}": chart_src,
            "{CHART_VALUES_PATH}": chart_values_path,
            "{CHART_MANIFEST_PATH}": chart_manifest_path,
            "{DIGEST_PATH}": digest_path,
            "{IMAGE_TAG}": image_tag,
            "{YQ_PATH}": ctx.toolchains["//toolchains/yq:toolchain_type"].yqinfo.tool_path,
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
    },
    toolchains = ["//toolchains/yq:toolchain_type"],
    doc = "Runs helm packaging updating the image tag on it",
)
