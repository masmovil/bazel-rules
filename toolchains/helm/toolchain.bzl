HelmInfo = provider(
    doc = "Helm info",
    fields = {
        "version": "Helm specific version",
        "binary": "Helm executable binary",
        "xdg_data_home": "Helm data home path",
        "xdg_config_home": "Helm config home path",
        "xdg_cache_home": "Helm cache home path"
    },
)

def _helm_toolchain_impl(ctx):
  for toolFile in ctx.files.tool:
    if toolFile.path.endswith("helm") or toolFile.path.endswith("helm.exe"):
      binary = toolFile

  if not binary:
    fail("Could not locate helm binary")

  toolchain_info = platform_common.ToolchainInfo(
      helminfo = HelmInfo(
          version = ctx.attr.version,
          binary = binary,
          xdg_data_home = ctx.attr.xdg_data_home,
          xdg_config_home = ctx.attr.xdg_config_home,
          xdg_cache_home = ctx.attr.xdg_cache_home
      ),
  )
  return [toolchain_info]

helm_toolchain = rule(
    implementation = _helm_toolchain_impl,
    attrs = {
        "version": attr.string(),
        "tool": attr.label(allow_files = True),
        "xdg_data_home": attr.string(),
        "xdg_config_home": attr.string(),
        "xdg_cache_home": attr.string()
    },
)