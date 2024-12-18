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
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        -p|--template)
            TEMPLATE="$2"
            shift 2
            ;;
        -n|--name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required arguments
# For now, template and config are not compulsory arguments. Might add validation for them in the future
validate_arguments() {
    local error=0

    # If project type / name is empty
    if [[ -z "$PROJECT_TYPE" ]]; then
        echo "Error: Project type is required"
        error=1
    fi

    if [[ -z "$PROJECT_NAME" ]]; then
        echo "Error: Project name is required"
        error=1
    fi

    # Validate project type
    case "$PROJECT_TYPE" in
        frontend|backend|fullstack)
            ;;
        *)
            echo "Error: Invalid project type. Must be one of the following: frontend, backend, fullstack"
            error=1
            ;;
    esac

    if [[ $error -eq 1 ]]; then
        usage
        exit 1
    fi
}

# Main function to create project
create_project() {
    local project_dir="$PROJECT_NAME"

    echo "Creating new $PROJECT_TYPE project: $PROJECT_NAME"

    # Create project directory
    if [[ -d "$project_dir" ]]; then
        echo "Error: Directory $project_dir already exists"
        exit 1
    fi

    mkdir -p "$project_dir"
    cd "$project_dir"

    # Initialise git repository
    git init

    # Apply template based on project type
    case "$PROJECT_TYPE" in
        frontend)
            setup_frontend_project
            ;;
        backend)
            setup_backend_project
            ;;
        fullstack)
            setup_fullstack_project
            ;;
    esac

    echo "Project created successfully!"
    echo "Next steps:"
    echo "  cd $PROJECT_NAME"
    echo "  git add ."
    echo "  git commit -m 'Initial commit'"
}

# Main execution
validate_arguments
create_project
