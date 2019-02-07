#!/bin/bash
# Unofficial Strict Mode.
set -euo pipefail
IFS=$'\n\t'

# Foreach zip.
for zip_file in $(find "${FUNCTIONS_ZIPS_DIR}" -name "*.zip" -mindepth 1 -maxdepth 1); do
    ZIP_FILE_BASENAME="$(basename "${zip_file}")"

    # Upload zip go GCS.
    gsutil cp "${zip_file}" "gs://${FUNCTIONS_GCS_BUCKET}"

    # Create function.
    gcloud functions deploy "${ZIP_FILE_BASENAME%.*}" --runtime go111 --trigger-http --source "gs://${FUNCTIONS_GCS_BUCKET}/${ZIP_FILE_BASENAME}" --region "${REGION}"
done