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
# TEMPLATE="" -> not using for now
# Can add the below to the OPTIONS in the future if using multiple templates
# -p, --template TEMPLATE  Specific template to use
PROJECT_NAME=""
CONFIG_FILE="${SCRIPT_DIR}/config/default_config.yaml" # Config files to be worked on soon

# Print usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Generate a new project based on predefined templates.

Options: 
    -t, --type TYPE          Project type (frontend, backend, fullstack)
    -n, --name NAME         Project name
    -c, --config FILE       Custom configuration file
    -h, --help             Show this help message

Example:
    $(basename "$0") --type frontend --name my-app
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        # -p|--template)
        #     TEMPLATE="$2"
        #     shift 2
        #     ;;
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
validate_arguments() {
    local error=0

    # Note: Template validation can be added in the future if we ever use different templates
    # For now, only project type and name are required

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

    # Get the full path of the project directory
    local full_path="$(pwd)"

    # Setup project files (from file_utils.sh)
    setup_project_files "$PROJECT_TYPE" "$PROJECT_NAME"

    # Setup project template (from template_utils.sh)
    setup_project_template "$PROJECT_TYPE" "$PROJECT_NAME"

    # Setup git (from git_utils.sh)
    # This has to come after all the files have been created
    setup_git "$PROJECT_NAME" "$PROJECT_TYPE"

    echo "✅ Project created successfully!"
    echo "📁 Project location: $full_path"
    echo ""
    echo "Next steps:"
    echo "  cd $PROJECT_NAME"
    echo "  git add ."
    echo "  git commit -m 'Initial commit'"
}

# Main execution
validate_arguments
create_project

# TODO:

# To shift some of the code from the template_utils to their respective templates
# To ensure the code is cleaner (still considering for this)

# create_project.sh
# - Work on the CONFIG_FILE (next step)


# Next steps
# For the current project generator, we could work on several enhancements:

# 1. **Testing the Scripts**:
#    - Create test cases for different project types
#    - Test error handling scenarios
#    - Verify all components work together correctly

# 2. **Adding Validation and Safety Features**:
#    - Check for necessary system requirements before starting (Node.js, Java, Maven versions)
#    - Validate project names (check for invalid characters)
#    - Add a backup/rollback mechanism if something fails mid-creation

# 3. **Improve User Experience**:
#    - Add a verbose mode for detailed logging (`-v` flag)
#    - Add a dry-run mode to show what would be created (`--dry-run`)
#    - Add progress indicators for long-running operations
#    - Add color to console output for better readability

# 4. **Documentation**:
#    - Create a detailed README for the project generator itself
#    - Add inline documentation to the scripts
#    - Create usage examples

# 5. **Additional Features**:
#    - Add Docker setup for projects
#    - Add GitHub Actions/CI setup
#    - Add common testing frameworks setup
#    - Add database configuration options
