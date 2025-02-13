#!/bin/bash

# Set strict error handling
set -euo pipefail

# Script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source utility functions
source "${SCRIPT_DIR}/lib/logger_utils.sh"
source "${SCRIPT_DIR}/lib/git_utils.sh"         # For setting up git repository (with the git hooks)
source "${SCRIPT_DIR}/lib/file_utils.sh"        # For creating the directory structure and documentation
source "${SCRIPT_DIR}/lib/template_utils.sh"    # For setting up the project's template (all the necessary files etc.)
source "${SCRIPT_DIR}/lib/validation_utils.sh"  # For validating the various requirements for projects (node, java, maven versions, naming, backup, rollback)

# Cleanup function
cleanup () {
    # Kill any running spinners
    if [[ -n "$SPINNER_PID" ]]; then
        kill $SPINNER_PID 2>/dev/null || true
        tput cnorm # restore cursor
    fi
}

trap cleanup EXIT

# Default values
PROJECT_TYPE=""
# TEMPLATE="" -> not using for now
# Can add the below to the OPTIONS in the future if using multiple templates
# -p, --template TEMPLATE  Specific template to use
PROJECT_NAME=""
VERBOSE=0
SECONDS=0
CONFIG_FILE="${SCRIPT_DIR}/config/default_config.yaml" # Config files to be worked on next time
DRY_RUN=0

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
    -d, --dry-run           Show what would be created without making any changes
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
        -d|--dry-run)
            DRY_RUN=1
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

# Dry run
# Example usage:
# ./create_project.sh --type fullstack --name my-app --dry-run
show_preview() {
    local project_type="$1"
    local project_name="$2"

    log_section "Preview: Project Structure"
    echo "Project Type: $project_type"
    echo "Project Name: $project_name"
    echo ""

    echo "The following will be created:"
    echo "└── $project_name/"

    case "$project_type" in
        "frontend")
            echo "    ├── ${project_name}-frontend/    # Frontend application"
            echo "    │   ├── src/                     # Source files"
            echo "    │   │   ├── assets/              # Static assets"
            echo "    │   │   ├── components/          # React components"
            echo "    │   │   ├── pages/               # Route components"
            echo "    │   │   ├── services/            # API services"
            echo "    │   │   └── types/               # TypeScript definitions"
            echo "    │   ├── public/                  # Public assets"
            echo "    │   ├── index.html               # Entry point"
            echo "    │   ├── package.json             # Dependencies"
            echo "    │   ├── tsconfig.json            # TypeScript config"
            echo "    │   ├── vite.config.ts           # Vite config"
            echo "    │   └── tailwind.config.js       # Tailwind config"
            ;;
        "backend")
            echo "    ├── ${project_name}-backend/     # Backend application"
            echo "    │   ├── src/"
            echo "    │   │   ├── main/"
            echo "    │   │   │   ├── java/            # Java source files"
            echo "    │   │   │   └── resources/       # Application resources"
            echo "    │   │   └── test/                # Test files"
            echo "    │   ├── pom.xml                  # Maven configuration"
            echo "    │   └── README.md                # Backend documentation"
            ;;
        "fullstack")
            echo "    ├── ${project_name}-frontend/    # Frontend application"
            echo "    │   ├── src/"
            echo "    │   │   ├── assets/"
            echo "    │   │   ├── components/"
            echo "    │   │   ├── pages/"
            echo "    │   │   ├── services/"
            echo "    │   │   └── types/"
            echo "    │   └── [Frontend configuration files]"
            echo "    │"
            echo "    ├── ${project_name}-backend/     # Backend application"
            echo "    │   ├── src/"
            echo "    │   │   ├── main/"
            echo "    │   │   └── test/"
            echo "    │   └── [Backend configuration files]"
            ;;
    esac

    echo "    │"
    echo "    ├── docs/                    # Documentation"
    echo "    │   └── CONTRIBUTING.md      # Contribution guidelines"
    echo "    │"
    echo "    ├── .gitignore               # Git ignore rules"
    echo "    └── README.md                # Project documentation"

    echo ""
    log_section "Preview: Git Configuration"
    echo "✓ Git repository will be initialized"
    echo "✓ Git hooks will be set up (including security checks)"
    echo "✓ Initial commit will be created"

    echo ""
    log_section "Preview: Additional Setup"
    case "$project_type" in
        "frontend"|"fullstack")
            echo "✓ Node.js dependencies will be installed"
            echo "✓ Tailwind CSS will be configured"
            echo "✓ TypeScript will be configured"
            echo "✓ Vite development server will be configured"
            ;;
    esac

    case "$project_type" in
        "backend"|"fullstack")
            echo "✓ Spring Boot will be configured"
            echo "✓ Maven will be configured"
            echo "✓ Application properties will be set up"
            ;;
    esac
    
    echo ""
    log_warning "This is a dry run - no files will be created"
}

# Main function to create project
create_project() {
    local project_dir="$PROJECT_NAME"
    local full_path

    # New
    # If dry run selected, show preview and exit
    if [[ $DRY_RUN -eq 1 ]]; then
        show_preview "$PROJECT_TYPE" "$PROJECT_NAME"
        exit 0
    fi

    # New
    # Validate all requirements before starting
    if ! validate_requirements "$PROJECT_TYPE" "$PROJECT_NAME"; then
        log_error "Requirements validation failed"
        exit 1
    fi

    log_section "Creating new $PROJECT_TYPE project: $PROJECT_NAME"

    # Create project directory
    if [[ -d "$project_dir" ]]; then
        log_error "Directory $project_dir already exists"
        exit 1
    fi

    # New
    # Create backup directory
    create_backup "$project_dir" || {
        log_error "Failed to create backup"
        exit 1
    }

    # New 
    # Wrapping the entire project creation process in a trap for cleanup on failure
    # trap 'rollback "$project_dir"' ERR 
    # -> Changed this to ensure the script exits with an error status when something fails
    # -> Prevents the script from continuing execution after a rollback
    # -> Makes it clear to users that something went wrong (through the exit status)
    trap 'rollback "$project_dir"; exit 1' ERR 

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

    # New
    # Remove trap if everything above succeeded
    trap - ERR

    # Success
    log_section "Project creation completed! 🎉"
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
# - Work on the CONFIG_FILE (Leaving it as is for now. Just work with the current stacks you know currently.)


# Next steps
# For the current project generator, we could work on several enhancements:

# 1. **Testing the Scripts**: (TODO next)
#    - Create test cases for different project types
#    - Test error handling scenarios
#    - Verify all components work together correctly

# 2. **Adding Validation and Safety Features**: (Done)

# 3. **Improve User Experience**: (Done)
#    - TODO: To review the preview for the dry-run, to ensure it is representative of what is going to be created

# 4. **Documentation**:
#    - Create a detailed README for the project generator itself
#    - Add inline documentation to the scripts
#    - Create usage examples

# 5. **Additional Features**: (FUTURE IDEAS)
#    - Add Docker setup for projects
#    - Add GitHub Actions/CI setup
#    - Add common testing frameworks setup
#    - Add database configuration options


# To review: 
# - create_project.sh (Mostly done, just need to double check the dry-run sample)

# - logger_utils.sh (Done)
# - file_utils.sh (Done)
# - template_utils.sh (Done)
# - git_utils.sh (Done)
# - validation_utils.sh (Done)

# - test_project_types.sh
# - test_validation.sh
# - test_error_handling.sh
# - test_integration.sh
