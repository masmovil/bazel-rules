"""Rules GCS."""

load("//gcs:gcs-upload.bzl", _gcs_upload = "gcs_upload")


# Explicitly re-export the functions
gcs_upload = _gcs_upload
