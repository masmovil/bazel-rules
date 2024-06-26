load("//helpers:helpers.bzl", "write_sh", "get_make_value_or_default")

def runfile(ctx, f):
  """Return the runfiles relative path of f."""
  if ctx.workspace_name:
    return ctx.workspace_name + "/" + f.short_path
  else:
    return f.short_path

def _gcs_upload_impl(ctx):
    """Push an artifact to Google Cloud Storage
    Args:
        name: A unique name for this rule.
        src: Source file to upload.
        destination: Destination. Example: gs://my-bucket/file
        allow_overwrite: Allow overwriting the destination file if it already exists.
    """

    src_file = ctx.file.src

    # get chart museum basic auth credentials
    destination = ctx.attr.destination

    exec_file = ctx.actions.declare_file(ctx.label.name + "_gcs_upload_bash")

    stamp_files = [ctx.info_file, ctx.version_file]

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{SRC_FILE}": src_file.short_path,
            "{DESTINATION}": destination,
            "{NO_CLOBBER}": "-n" if not ctx.attr.allow_overwrite else "", # -n flag to avoid overwriting
            "%{stamp_statements}": "\n".join([
              "read_variables %s" % runfile(ctx, f)
              for f in stamp_files]),
        }
    )

    runfiles = ctx.runfiles(
        files = [ctx.info_file, ctx.version_file, src_file]
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
      "allow_overwrite": attr.bool(default = True),
      "_script_template": attr.label(allow_single_file = True, default = ":gcs-upload.sh.tpl"),
    },
    doc = "Upload a file to a Google Cloud Storage Bucket",
    toolchains = [],
    executable = True,
)
