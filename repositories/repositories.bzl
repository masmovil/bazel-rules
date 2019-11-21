def repositories():
  native.register_toolchains(
    # Register the default docker toolchain that expects the 'docker'
    # executable to be in the PATH
    "@io_bazel_rules_docker//toolchains/docker:default_linux_toolchain",
    "@io_bazel_rules_docker//toolchains/docker:default_windows_toolchain",
    "@io_bazel_rules_docker//toolchains/docker:default_osx_toolchain",
  )