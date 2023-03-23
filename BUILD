load("@bazel_gazelle//:def.bzl", "gazelle")

# gazelle:proto disable_global
# gazelle:prefix github.com/masmovil/mm-monorepo
# gazelle:go_naming_convention go_default_library
# gazelle:exclude node_modules
gazelle(
    name = "gazelle_go",
)

# gazelle:proto disable_global
# gazelle:prefix github.com/masmovil/mm-monorepo
# gazelle:go_naming_convention go_default_library
gazelle(
    name = "gazelle_go_update_repos",
    args = [
        "-from_file=go.mod",
        "-to_macro=go_repositories.bzl%go_repositories",
        "-build_file_proto_mode=disable_global",
    ],
    command = "update-repos",
)
