#!/bin/bash

set -euo pipefail

PROJECT="corpershub"
WORKSPACE="${1:-dev}"
AGE_KEY_PATH="${AGE_KEY_PATH:-${HOME}/.config/age/${PROJECT}/keys.txt}"
DECRYPTED_ENV_FILE="envs/secrets/.env.${WORKSPACE}"
ENCRYPTED_ENV_FILE="envs/secrets/.env.${WORKSPACE}.age"


if [ ! -f "$DECRYPTED_ENV_FILE" ]; then
    echo "Error: $DECRYPTED_ENV_FILE not found."
    exit 1
fi

if [ ! -f "$AGE_KEY_PATH" ]; then
    echo "Error: age key not found at $AGE_KEY_PATH"
    echo "Run: bash ../scripts/secrets/setup.sh"
    exit 1
fi

PUBLIC_KEY="$(age-keygen -y "$AGE_KEY_PATH")"

echo "Encrypting $DECRYPTED_ENV_FILE..."
age -R <(echo "$PUBLIC_KEY") "$DECRYPTED_ENV_FILE" > "$ENCRYPTED_ENV_FILE"
chmod 600 "$ENCRYPTED_ENV_FILE"

echo "Encrypted to $ENCRYPTED_ENV_FILE"
