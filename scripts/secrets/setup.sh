#!/bin/bash

set -euo pipefail

PROJECT="corpershub"
AGE_KEY_DIR="${HOME}/.config/age/${PROJECT}"
export AGE_KEY_FILE="${AGE_KEY_DIR}/keys.txt"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_age_if_needed

mkdir -p "$AGE_KEY_DIR"

if [ ! -f "$AGE_KEY_FILE" ]; then
    echo "Generating age key at $AGE_KEY_FILE..."
    age-keygen -o "$AGE_KEY_FILE"
    chmod 600 "$AGE_KEY_FILE"
else
    echo "Age key already exists at $AGE_KEY_FILE"
fi

echo ""
echo "Recipient:" $(age-keygen -y "$AGE_KEY_FILE")
