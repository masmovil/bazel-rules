def _gcs_upload_impl(ctx):
    """Push an artifact to Google Cloud Storage
    Args:
        name: A unique name for this rule.
        src: Source file to upload.
        destination: Destination. Example: gs://my-bucket/file
    """
    gsutil_bin = ctx.toolchains["@masmovil_bazel_rules//toolchains/gcloud:toolchain_type"].gcloudinfo.gsutil_bin

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
      "src": attr.label(allow_single_file = True, mandatory = True),
      "destination": attr.string(mandatory = True),
    },
    doc = "Upload a file to a Google Cloud Storage Bucket",
    toolchains = [
      "@masmovil_bazel_rules//toolchains/gcloud:toolchain_type",
    ],
    executable = True,
)
