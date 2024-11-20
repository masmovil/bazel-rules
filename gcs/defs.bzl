"""Rules GCS."""

load("//gcs/private:gcs_upload.bzl", _gcs_upload = "gcs_upload")


# Explicitly re-export the functions
gcs_upload = _gcs_upload
