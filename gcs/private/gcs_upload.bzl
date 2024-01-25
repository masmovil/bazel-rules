
_DOC = """Rule used to upload a single file to a Google Cloud Storage bucket

    To load the rule use:
    ```starlark
    load("//gcs:defs.bzl", "gcs_upload")
    ```

    Example of use:

    ```starlark
    load("//gcs:defs.bzl", "gcs_upload")

    gcs_upload(
        name = "push",
        src = ":file",
        destination = "gs://my-bucket/file.zip"
    )
    ```

    This rule builds an executable. Use `run` instead of `build` to upload the file.
"""

def _gcs_upload_impl(ctx):
    gsutil_bin = ctx.toolchains["@masmovil_bazel_rules_test//gcs:gcloud_toolchain_type"].gcloudinfo.gsutil_bin

    src_file = ctx.file.src

    destination = ctx.attr.destination

    gcs_sh_tpl = ctx.actions.declare_file(ctx.attr.name + "_gcs_upload.tpl")
    exec_file = ctx.actions.declare_file(ctx.label.name + "_gcs_upload.sh")

    ctx.actions.write(
      output = gcs_sh_tpl,
      content = "{GSUTIL} cp {SRC} {DESTINATION}"
    )

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = gcs_sh_tpl,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{SRC}": src_file.short_path,
            "{DESTINATION}": destination,
            "{GSUTIL}": gsutil_bin.short_path,
        }
    )

    runfiles = ctx.runfiles(
        files = [src_file, gsutil_bin]
    )

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

gcs_upload = rule(
    implementation = _gcs_upload_impl,
    attrs = {
      "src": attr.label(allow_single_file = True, mandatory = True, doc = "Source file to upload"),
      "destination": attr.string(mandatory = True, doc = "Google storage destination url. Example: gs://my-bucket/file"),
    },
    doc = _DOC,
    toolchains = [
      "@masmovil_bazel_rules_test//gcs:gcloud_toolchain_type",
    ],
    executable = True,
)
