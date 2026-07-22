#!/bin/bash

set -euo pipefail

PROJECT="corpershub"
WORKSPACE="${1:-dev}"
AGE_KEY_PATH="${AGE_KEY_PATH:-${HOME}/.config/age/${PROJECT}/keys.txt}"
DECRYPTED_ENV_FILE="envs/secrets/.env.${WORKSPACE}"
ENCRYPTED_ENV_FILE="envs/secrets/.env.${WORKSPACE}.age"


if [ -f "$ENCRYPTED_ENV_FILE" ] && [ ! -f "$DECRYPTED_ENV_FILE" ]; then
    if [ ! -f "$AGE_KEY_PATH" ]; then
        echo "Error: age key not found at $AGE_KEY_PATH"
        echo "Run: bash ../scripts/secrets/setup.sh"
        exit 1
    fi

    echo "Decrypting $ENCRYPTED_ENV_FILE..."
    age -d -i "$AGE_KEY_FILE" "$ENCRYPTED_ENV_FILE" > "$DECRYPTED_ENV_FILE"
    chmod 600 "$DECRYPTED_ENV_FILE"
fi

if [ ! -f "$DECRYPTED_ENV_FILE" ]; then
    echo "Error: neither $DECRYPTED_ENV_FILE nor $ENCRYPTED_ENV_FILE exists."
    echo "Copy $(basename "$DECRYPTED_ENV_FILE").example to $(basename "$DECRYPTED_ENV_FILE") and add your local secrets."
    exit 1
fi

echo "Environment file ready: $DECRYPTED_ENV_FILE"
