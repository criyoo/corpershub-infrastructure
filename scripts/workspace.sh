#!/usr/bin/env bash

set -euo pipefail

WORKSPACE="${1:-}"

if [ -z "$WORKSPACE" ]; then
    echo "usage: $0 <workspace>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "${SCRIPT_DIR}/../terraform" && pwd)"

cd "${TERRAFORM_DIR}"

CURRENT_WORKSPACE="$(terraform workspace show -no-color | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
if [ "$CURRENT_WORKSPACE" = "$WORKSPACE" ]; then
    echo "workspace: $WORKSPACE is already selected!"
    exit 0
fi

if terraform workspace list -no-color | sed 's/^[*[:space:]]*//' | grep -Fxq "$WORKSPACE"; then
    echo "workspace: $WORKSPACE exists, selecting it!"
    terraform workspace select "${WORKSPACE}"
else
    echo "workspace: $WORKSPACE does not exist, creating it!"
    terraform workspace new "${WORKSPACE}"
fi
