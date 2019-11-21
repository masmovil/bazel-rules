def repositories():
  native.register_toolchains(
    # Register the default docker toolchain that expects the 'docker'
    # executable to be in the PATH
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_linux_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_osx_toolchain",
    "@com_github_masmovil_bazel_rules//toolchains/yq:yq_windows_toolchain",
  )