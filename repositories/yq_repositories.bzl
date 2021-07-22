load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

yq_version = "v4.11.1"

def yq_repositories():
    http_file(
        name = "yq_linux",
        urls = ["https://github.com/mikefarah/yq/releases/download/%s/yq_linux_amd64" % yq_version],
        sha256 = "1f63c9fe412c0d17b263e0ccfd91a596bb359db69ef7dddf5f53af1b2e8db898",
        executable = True,
    )

    http_file(
        name = "yq_darwin",
        urls = ["https://github.com/mikefarah/yq/releases/download/%s/yq_darwin_amd64" % yq_version],
        sha256 = "95244750f0d9e2bd37b48e473823cc8dacf8ccc8a69fd5bbd20fe023bfead002",
        executable = True,
    )
