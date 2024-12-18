#!/bin/bash

# Set strict error handling
set -euo pipefail

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility functions
source "${SCRIPT_DIR}/lib/git_utils.sh"
source "${SCRIPT_DIR}/lib/file_utils.sh"
source "${SCRIPT_DIR}/lib/template_utils.sh"

# Default values
PROJECT_TYPE=""
TEMPLATE=""
PROJECT_NAME=""
CONFIG_FILE="${SCRIPT_DIR}/config/default_config.yaml"

# Print usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Generate a new project based on predefined templates.

Options: 
    -t, --type TYPE          Project type (frontend, backend, fullstack)
    -p, --template TEMPLATE  Specific template to use
    -n, --name NAME         Project name
    -c, --config FILE       Custom configuration file
    -h, --help             Show this help message

Example:
    $(basename "$0") --type frontend --template react-ts --name my-app
EOF
}

# Parse command line arguments
