#!/bin/bash

# Set strict error handling
set -euo pipefail

# Required versions
# To decide on the versions later *****
readonly REQUIRED_NODE_VERSION=""
readonly REQUIRED_JAVA_VERSION=""
readonly REQUIRED_MVN_VERSION=""

# Validate Node.js version
validate_node() {
    log_verbose "Checking Node.js installation..."

    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed"
        log_info "Please install Node.js version $REQUIRED_NODE_VERSION or higher"
        return 1
    fi

    local current_version=$(node -v | cut -d 'v' -f2)
    log_verbose "Found Node.js version: $current_version"

    if ! verify_version "$current_version" "$REQUIRED_NODE_VERSION"; then
        log_error "Node.js version $current_version is lower than the required version $REQUIRED_NODE_VERSION"
        return 1
    fi

    log_verbose "Node.js version check passed"
    return 0
}

# Validate Java version
validate_java() {
    log_verbose "Checking Java installation..."

    if ! command -v java &> /dev/null; then
        log_error "Java is not installed"
        log_info "Please install Java version $REQUIRED_JAVA_VERSION or higher"
        return 1
    fi

    local current_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    log_verbose "Found Java version: $current_version"

    if [[ "$current_version" -lt "$REQUIRED_JAVA_VERSION" ]]; then
        log_error "Java version $current_version is lower than the required version $REQUIRED_JAVA_VERSION"
        return 1
    fi

    log_verbose "Java version check passed"
    return 0
}

# Validate Maven version
validate_maven() {
    log_verbose "Checking Maven installation..."

    if ! command -v mvn &> /dev/null; then
        log_error "Maven is not installed"
        log_info "Please install Maven version $REQUIRED_MVN_VERSION or higher"
        return 1
    fi

    local current_version=$(mvn -v | head -n1 | awk '{print $3}')
    log_verbose "Found Maven version: $current_version"

    if ! verify_version "$current_version" "$REQUIRED_MVN_VERSION"; then
        log_error "Maven version $current_version is lower than required version $REQUIRED_MVN_VERSION"
        return 1
    fi

    log_verbose "Maven version check passed"
    return 0
}


# Helper function to compare versions
verify_version() {
    local current=$1
    local required=$2

    # Clarify
    local current_parts=(${current//./ })
    local required_parts=(${required//./ })

    for ((i=0; i<${#required_parts[@]}; i++)); do
        if [[ ${current_parts[i]:-0} -lt ${required_parts[i]:-0} ]]; then
            return 1
        elif [[ ${current_parts[i]:-0} -gt ${required_parts[i]:-0} ]]; then
            return 0
        fi
    done
    return 0
}


# Validate project name
validate_project_name() {
    local project_name="$1"
    local error=0

    log_verbose "Validating project name: $project_name"

    # Check length
    if [[ ${#project_name} -lt 3 || ${#project_name} -gt 50 ]]; then
        log_error "Project name must be between 3 and 50 characters long"
        error=1
    fi

    # Check for invalid characters
    if [[ ! $project_name =~ ^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]]; then
        log_error "Project name must:"
        echo " - Start with a letter"
        echo " - Contain only letters, number, and hyphens"
        echo " - End with a letter or number"
        error=1
    fi

    # Check for  reserved names
    local reserved_names=("node_modules" "build" "dist" "test" "src" "app" "config" "public")
    for reserved in "${reserved_names[@]}"; do
        if [[ "${project_name,,}" == "$reserved" ]]; then
            log_error "Project name cannot be a reserved name: $reserved"
            error=1
        fi
    done

    if [[ $error -eq 1 ]]; then
        return 1
    fi

    log_verbose "Project name validation passed"
    return 0
}

# Backup functionality
create_backup() {
    local project_dir="$1"
    local backup_dir="${project_dir}.bak"

    # .bak is a common file extension convention used to indicate that something is a backup file. 
    # It's not special to the system - it's just a naming convention that developers often use.
    # Used to distinguish the backup from the original while keeping the name similar enough to identify what it's a backup of.

    log_verbose "Creating backup of $project_dir"

    if [[ -d "$project_dir" ]]; then
        if ! cp -r "$project_dir" "$backup_dir"; then
            log_error "Failed to create backup"
            return 1
        fi
        log_verbose "Backup created at $backup_dir"
    fi
    return 0
}

# Rollback functionality
rollback() {
    local project_dir="$1"
    local backup_dir="${project_dir}.bak"

    log_warning "Rolling back changes..."

    if [[ -d "$backup_dir" ]]; then
        # Remove failed project directory
        rm -rf "project_dir"

        # Restore from backup
        mv "$backup_dir" "$project_dir"
        log_success "Rollback completed successfully"
    else
        # If no backup exists, just remove the project directory
        rm -rf "$project_dir"
        log_success "Cleaned up project directory"
    fi
}


# Main validation function
