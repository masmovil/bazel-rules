GCLOUD_DEFAULT_VERSION = "450.0.0"

GCLOUD_VERSIONS = {
    "450.0.0": {
        "linux-x86_64": "7a51d06c3edfcda8901983736f402c1024a058fa83790cd5d74a0c88c7ca6e24",
        "linux-arm": "c8ab1e46605ec3b457cf7c2b46ce3a22fce26f420743ec82dd81c8fbc85857a3",
        "linux-x86": "9a6c190a25c6f27e156e52d605e6caa64c67e18d39d903b49fa1536e1ccade08",
        "darwin-x86_64": "fe25b8b77a4f734fd5d00f5ef59adc077cec0818c1a168b068457034b2ede295",
        "darwin-x86": "544acdadd2dbf690a08b058f18d0d00eff2efafda8a3d5ff1f55f25da1bbc4f1",
        "darwin-arm": "3796e974808e321ac107593b15fe8c80f59a0a39dffbf5380ce1722a281e6049",
        # "windows_amd64": "fe1f6299294b47ceda565e1091e843ee3f3db58764901d4298eb00558189e25f"
    }
}

GCLOUD_PLATFORMS = {
    "darwin-x86": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_32",
        ],
    ),
    "darwin-x86_64": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
    ),
    "darwin-arm": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux-arm": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
    ),
    "linux-x86": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_32",
        ],
    ),
    "linux-x86_64": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    ),
    "windows_amd64": struct(
        compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
    ),
}

GcloudInfo = provider(
  doc = "Helm info",
  fields = {
    "gcloud_bin": "Gcloud executable binary",
    "gsutil_bin": "Gsutil executable binary",
  },
)

def _gcloud_toolchain_impl(ctx):
  gcloud=ctx.file.gcloud_bin
  gsutil=ctx.file.gsutil_bin

  template_variables = platform_common.TemplateVariableInfo({
    "GCLOUD_BIN": gcloud.path,
    "GSUTIL_BIN": gsutil.path,
  })
  default_info = DefaultInfo(
    files = depset([gcloud, gsutil]),
    runfiles = ctx.runfiles(files = [gcloud, gsutil]),
  )
  gcloudinfo = GcloudInfo(
    gcloud_bin = gcloud,
    gsutil_bin = gsutil,
  )

  toolchain_info = platform_common.ToolchainInfo(
    default = default_info,
    template_variables = template_variables,
    gcloudinfo = gcloudinfo,
  )

  return [toolchain_info]

gcloud_toolchain = rule(
  implementation = _gcloud_toolchain_impl,
  attrs = {
    "gcloud_bin": attr.label(allow_single_file = True, mandatory = True),
    "gsutil_bin": attr.label(allow_single_file = True, mandatory = True),
  },
)

def _gcloud_repo_impl(rctx):
    version = rctx.attr.version
    platform = rctx.attr.platform
    sha = rctx.attr.sha

    url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-{version}-{platform}.tar.gz".format(
        version=version,
        platform=platform,
    )

    rctx.report_progress("Downloading gcloud-sdk %s" % url)

    rctx.download_and_extract(
        url = url,
        sha256 = sha,
        stripPrefix = "google-cloud-sdk/bin",
    )

    build_content = """
load("@masorange_rules_helm//gcs/private:gcloud_toolchain.bzl", "gcloud_toolchain")

exports_files(["gcloud", "gsutil"])

gcloud_toolchain(name = "gcloud_toolchain", gcloud_bin = "gcloud", gsutil_bin = "gsutil", visibility = ["//visibility:public"])
"""

    # Base BUILD file for this repository
    rctx.file("BUILD.bazel", build_content)

gcloud_repo = repository_rule(
    implementation = _gcloud_repo_impl,
    doc = "Fetch external gcloud binaries",
    attrs = {
        "version": attr.string(mandatory = True, values = GCLOUD_VERSIONS.keys()),
        "platform": attr.string(mandatory = True,),
        "sha": attr.string(mandatory = True),
    },
)

def _gcloud_toolchain_configure_impl(rctx):

    # Expose a concrete toolchain which is the result of Bazel resolving the toolchain
    # for the execution or target platform.
    # Workaround for https://github.com/bazelbuild/bazel/issues/14009
    starlark_content = """

# Forward all the providers
def _resolved_toolchain_impl(ctx):
    toolchain_info = ctx.toolchains["@masorange_rules_helm//gcs:gcloud_toolchain_type"]
    return [
        toolchain_info,
        toolchain_info.default,
        toolchain_info.gcloudinfo,
        toolchain_info.template_variables,
    ]

# Copied from java_toolchain_alias
# https://cs.opensource.google/bazel/bazel/+/master:tools/jdk/java_toolchain_alias.bzl
resolved_toolchain = rule(
    implementation = _resolved_toolchain_impl,
    toolchains = ["@masorange_rules_helm//gcs:gcloud_toolchain_type"],
    incompatible_use_toolchain_transition = True,
)
"""
    rctx.file("defs.bzl", starlark_content)

    build_content = """
package(default_visibility = ["//visibility:public"])

load(":defs.bzl", "resolved_toolchain")

resolved_toolchain(name = "resolved_toolchain", visibility = ["//visibility:public"])
    """

    for [platform, meta] in GCLOUD_PLATFORMS.items():
        # TODO: make repo name a variable with a default to enable override toolchain versions
        build_content += """
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = {compatible_with},
    toolchain = "@gcloud_{platform}//:gcloud_toolchain",
    toolchain_type = "@masorange_rules_helm//gcs:gcloud_toolchain_type",
)
""".format(
            platform = platform,
            compatible_with = meta.compatible_with,
            # user_repository_name = rctx.attr.user_repository_name,
        )

    rctx.file("BUILD.bazel", build_content)


gcloud_toolchain_configure = repository_rule(
    implementation = _gcloud_toolchain_configure_impl,
    doc = """Creates a repository with toolchain definitions for all known platforms
     which can be registered or selected.""",
    attrs = {},
)
