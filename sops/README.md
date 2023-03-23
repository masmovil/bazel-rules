
# SOPS

Decrypting secrets using [sops](https://github.com/mozilla/sops).

## How to import

To use `sops_decrypt` rule, import it in your `BUILD.bazel`

```python
load("@com_github_masmovil_bazel_rules//sops:def.bzl", "sops_decrypt")
```

## sops_decrypt

You can decrypt as many secrets as you want using `sops_decrypt` rule. Use the rule attribute `src` to provide the encrypted secrets that you want to decrypt.
The rule also needs the sops config file with the keyring id in order to decrypt files (`.sops.yaml`). You can provide it using the `sops_yaml` rule attribute.

Example of use:
```python
sops_decrypt(
    name = "decrypt_secret_files",
    srcs = [":secrets.yaml"]
    sops_yaml = ":.sops.yaml"
)
```

You can specify which provider integration you want to use (gcp KMS, azure key vault etc.) through the `provider` attribute.
* For the moment only gcp KMS is supported

The following attributes are accepted by the rule (some of them are mandatory).

|  Attribute | Mandatory| Default | Notes |
| ---------- | --- | ------ | -------------- |
| src | yes | - | One or more labels pointing to the secret files to decrypt. It accepts a glob pattern. |
| sops_yaml | yes | - | One label referencing the `.sops.yaml` yaml with the sops config. |
| provider | false | "gcp_kms" | The provider integration used to decrypt/encrypt the secrets. |

The output of the rule are the decrypted secrets that you can pass to `helm_release`.

Example of use:
```python
sops_decrypt(
    name = "decrypt_secret_files",
    srcs = [":secrets.yaml"]
    sops_yaml = ":.sops.yaml"
)

helm_release(
    name = "chart_install",
    chart = ":chart",
    namespace = "myapp",
    tiller_namespace = "tiller-system",
    release_name = "release-name",
    values_yaml = glob(["charts/myapp/values.yaml"]) + [":decrypt_secret_files"],
    kubernetes_context = "mm-k8s-context",
)
```

Env variables are supported by using --action_env flag running `sops_decrypt` rules. This is usefull in scenarios where you need to provide default credentials for cloud services (gcp kms, aws kms).

E.g:

```python
# GOOGLE_APPLICATION_CREDENTIALS env variable needs to be predefined
bazel build :decrypt_secret_files --action_env=GOOGLE_APPLICATION_CREDENTIALS

or

bazel build :decrypt_secret_files --action_env=GOOGLE_APPLICATION_CREDENTIALS=${HOME}/.config/gcloud/application_default_credentials.json
```
