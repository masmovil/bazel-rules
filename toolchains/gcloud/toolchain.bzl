GcloudInfo = provider(
  doc = "Helm info",
  fields = {
    "version": "Gcloud specific version",
    "gcloud": "Gcloud executable binary",
    "gsutil": "Gsutil executable binary",
  },
)

def _gcloud_toolchain_impl(ctx):
  gsutil=""
  gcloud=""

  for toolFile in ctx.files.tools:
    if toolFile.basename == "gcloud":
      gcloud = toolFile
    elif toolFile.basename == "gsutil":
      gsutil = toolFile

  if not gcloud:
    fail("Could not locate gcloud binary")

  if not gsutil:
    fail("Could not locate gsutil binary")

  toolchain_info = platform_common.ToolchainInfo(
    gcloudinfo = GcloudInfo(
      version = ctx.attr.version,
      gcloud = gcloud,
      gsutil = gsutil,
    )
  )
  return [toolchain_info]

gcloud_toolchain = rule(
  implementation = _gcloud_toolchain_impl,
  attrs = {
    "version": attr.string(),
    "tools": attr.label(allow_files = True),
  },
)