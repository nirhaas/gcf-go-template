#!/bin/bash
# Unofficial Strict Mode.
set -euo pipefail
IFS=$'\n\t'

# On MacOS you can also use "ln -h".
if [[ "$OSTYPE" == "darwin"* ]]; then
  export ln='gln'
else
  export ln='ln'
fi

# Link local shared module to vendor.
FUNCTIONS_SHARED_LIB_FULL_WITHOUT_ROOT="$(dirname ${FUNCTIONS_SHARED_RELATIVE})"
SHARED_IN_VENDOR="${FUNCTIONS_VENDOR_DIR}/${FUNCTIONS_SHARED_LIB_FULL_WITHOUT_ROOT}"
mkdir -p "${SHARED_IN_VENDOR}"
${ln} -s -f -n "${FUNCTIONS_SHARED_LIB_FULL}" "${SHARED_IN_VENDOR}"

# Empty output dir.
rm -rvf "${FUNCTIONS_ZIPS_DIR}"
mkdir -p "${FUNCTIONS_ZIPS_DIR}"

# Foreach function.
for function_dir in $(find "${FUNCTIONS_FUNCTIONS_DIR}" -mindepth 1 -maxdepth 1 -type d); do
    # Linking vendor dir to each function.
    ${ln} -s -f -n "${FUNCTIONS_VENDOR_DIR}" "${function_dir}/vendor"

    # Zipping.
    pushd "${function_dir}"
    zip -r "${FUNCTIONS_ZIPS_DIR}/$(basename "${function_dir}").zip" .
    popd
done