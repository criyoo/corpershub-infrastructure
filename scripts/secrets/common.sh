#!/usr/bin/env bash

set -euo pipefail

function install_age_package() {
    case "$(uname -s)" in
        Darwin)
            echo "macOS detected"
            brew install age
            ;;
        Linux)
            echo "Linux detected"

            # Check if it's Ubuntu
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                if [ "$ID" = "ubuntu" ]; then
                    sudo apt-get update
                    sudo apt-get install -y age
                else
                    echo "Unsupported Linux distribution: $ID"
                    exit 1
                fi
            fi
            ;;
        *)
            echo "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

function install_age_if_needed() {
    if ! command -v age-keygen >/dev/null 2>&1; then
        echo "Error: 'age-keygen' is not installed."
        echo "Installing age..."
        install_age_package
        if ! command -v age-keygen >/dev/null 2>&1; then
            echo "Failed to install age."
            exit 1
        fi
    fi
}