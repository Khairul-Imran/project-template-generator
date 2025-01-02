#!/bin/bash

# Set strict error handling
set -euo pipefail

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility functions
source "${SCRIPT_DIR}/lib/logger_utils.sh"
source "${SCRIPT_DIR}/lib/git_utils.sh"
source "${SCRIPT_DIR}/lib/file_utils.sh"
source "${SCRIPT_DIR}/lib/template_utils.sh"

# Default values
PROJECT_TYPE=""
# TEMPLATE="" -> not using for now
# Can add the below to the OPTIONS in the future if using multiple templates
# -p, --template TEMPLATE  Specific template to use
PROJECT_NAME=""
VERBOSE=0
SECONDS=0
CONFIG_FILE="${SCRIPT_DIR}/config/default_config.yaml" # Config files to be worked on soon

# Print usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Generate a new project based on predefined templates.

Options: 
    -t, --type TYPE         Project type (frontend, backend, fullstack)
    -n, --name NAME         Project name
    -c, --config FILE       Custom configuration file
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

Example:
    $(basename "$0") --type frontend --name my-app
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            PROJECT_TYPE="$2"
            log_verbose "Setting project type: $PROJECT_TYPE"
            shift 2
            ;;
        # -p|--template)
        #     TEMPLATE="$2"
        #     shift 2
        #     ;;
        -n|--name)
            PROJECT_NAME="$2"
            log_verbose "Setting project name: $PROJECT_NAME"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            log_verbose "Using config file: $CONFIG_FILE"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option $1"
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

    log_verbose "Validating project arguments..."

    # If project type / name is empty
    if [[ -z "$PROJECT_TYPE" ]]; then
        log_error "Project type is required"
        error=1
    else
        log_verbose "Project type is valid: $PROJECT_TYPE"
    fi

    if [[ -z "$PROJECT_NAME" ]]; then
        log_error "Project name is required"
        error=1
    else 
        log_verbose "Project name is valid: $PROJECT_NAME"
    fi

    # Validate project type
    case "$PROJECT_TYPE" in
        frontend|backend|fullstack)
            ;;
        *)
            log_error "Invalid project type. Must be one of the following: frontend, backend, fullstack"
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
    local full_path

    log_section "Creating new $PROJECT_TYPE project: $PROJECT_NAME"

    # Create project directory
    if [[ -d "$project_dir" ]]; then
        log_error "Directory $project_dir already exists"
        exit 1
    fi

    log_info "Creating project directory..."
    mkdir -p "$project_dir"
    cd "$project_dir"
    full_path="$(pwd)"
    log_success "Created directory: $full_path"

    # Setup project files (from file_utils.sh)
    log_section "Setting up project files"
    start_spinner "Creating project structure..."
    setup_project_files "$PROJECT_TYPE" "$PROJECT_NAME"
    stop_spinner $? "Project structure created successfully!" "Failed to create project structure"

    # Setup project template (from template_utils.sh)
    log_section "Generating project template"
    setup_project_template "$PROJECT_TYPE" "$PROJECT_NAME"

    # Setup git (from git_utils.sh)
    # This has to come after all the files have been created
    log_section "Setting up Git repository"
    start_spinner "Initialising Git..."
    setup_git "$PROJECT_NAME" "$PROJECT_TYPE"
    stop_spinner $? "Git repository initialised successfully!" "Failed to initialise Git repository"

    # Success
    log_section "Project creattion completed! 🎉"
    log_success "Project location: $full_path"

    # Verbose logging of configuration
    if [[ $VERBOSE -eq 1 ]]; then
        log_verbose "Project summary:"
        log_verbose "- Type: $PROJECT_TYPE"
        log_verbose "- Name: $PROJECT_NAME"
        log_verbose "- Location: $full_path"
        log_verbose "- Git initialised: yes"
        log_verbose "Total time elapsed: $SECONDS seconds"
    fi
    
    echo ""
    log_info "Next steps:"
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

# 2. **Adding Validation and Safety Features**: (WIP***)
#    - Check for necessary system requirements before starting (Node.js, Java, Maven versions)
#    - Validate project names (check for invalid characters)
#    - Add a backup/rollback mechanism if something fails mid-creation

# 3. **Improve User Experience**: (WIP***)
#    - Add a dry-run mode to show what would be created (`--dry-run`)

# 4. **Documentation**:
#    - Create a detailed README for the project generator itself
#    - Add inline documentation to the scripts
#    - Create usage examples

# 5. **Additional Features**:
#    - Add Docker setup for projects
#    - Add GitHub Actions/CI setup
#    - Add common testing frameworks setup
#    - Add database configuration options
