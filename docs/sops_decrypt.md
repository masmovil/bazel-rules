<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="sops_decrypt"></a>

## sops_decrypt

<pre>
sops_decrypt(<a href="#sops_decrypt-name">name</a>, <a href="#sops_decrypt-srcs">srcs</a>, <a href="#sops_decrypt-sops_yaml">sops_yaml</a>)
</pre>

Decrypt secrets using [sops](https://github.com/mozilla/sops)

To load the rule use:
```starlark
load("//sops:defs.bzl", "sops_decrypt")
```

You can decrypt as many secrets as you want using `sops_decrypt` rule. Use the rule attribute `src` to provide the encrypted secrets that you want to decrypt.
The rule also needs the sops config file with the keyring id in order to decrypt files (`.sops.yaml`). You can provide it using the `sops_yaml` rule attribute.
If no sops_yaml config is provided, the rule will try to locate a `.sops.yaml` file by default in the same directory where the target is placed.

Example of use:
```starlark
# explicit .sops.yaml config
load("//sops:defs.bzl", "sops_decrypt")

sops_decrypt(
    name = "decrypt_secret_files",
    srcs = [":secrets.yaml"]
    sops_yaml = ":.sops.yaml"
)
```

```starlark
# implicit .sops.yaml config
load("//sops:defs.bzl", "sops_decrypt")

sops_decrypt(
    name = "decrypt_secret_files",
    srcs = [":secrets.yaml"]
)
```

The outputs of the rule are the decrypted secrets that you can later provide to other rules, as for example to `helm_release`:

```starlark
sops_decrypt(
    name = "decrypt_secret_files",
    srcs = [":secrets.yaml"]
)

helm_release(
    name = "chart_install",
    chart = ":chart",
    namespace = "myapp",
    release_name = "release-name",
    values_yaml = glob(["charts/myapp/values.yaml"]) + [":decrypt_secret_files"],
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="sops_decrypt-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="sops_decrypt-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="sops_decrypt-sops_yaml"></a>sops_yaml |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


