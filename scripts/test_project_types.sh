#!/bin/bash

# Set strict error handling
set -euo pipefail

# Script location
# TODO: Clarify
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"

# Source required files
source "${SCRIPT_DIR}/lib/logger_utils.sh"

# Counter for tests
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"

    ((TESTS_TOTAL++))

    echo -n "Testing $test_name..."

    if eval "$test_command" > /dev/null 2>&1; then
        local actual_result=0
    else
        local actual_result=1
    fi

    if [[ $actual_result -eq $expected_result ]]; then
        echo "✅ Passed"
        ((TESTS_PASSED++))
    else
        echo "❌ Failed (expected: $expected_result, got: $actual_result)"
        ((TESTS_FAILED++))
    fi
}

# Verify directory structure
verify_directory_structure() {
    local project_dir="$1"
    local project_type="$2"
    local error=0

    # Common directories that should exist in all projects
    local commond_dirs=(
        "docs"
        ".git"
    )

    # Common files that should exist in all projects
    local common_files=(
        ".gitignore"
        "README.md"
        "docs/CONTRIBUTING.md"
    )

    # Check common directories
    for dir in "${common_dirs[@]}"; do
        if [[ ! -d "$project_dir/$dir" ]]; then
            log_error "Missing directory: $dir"
            error=1
        fi
    done

    # Check common files
    for file in "${common_files[@]}"; do
        if [[ ! -f "$project_dir/$file" ]]; then
            log_error "Missing file: $file"
            error=1
        fi
    done

    # Project-specific checks
    # TODO
    case "$project_type" in
        "frontend")
            local frontend_dir="$project_dir/${project_dir}-frontend"
            if [[ ! -d "$frontend_dir" ]]; then
                log_error "Missing frontend directory"
                error=1
            else
                # Check frontend-specific files
                # TODO: Double check this
                local frontend_files=(
                    "package.json"
                    "tsconfig.json"
                    "tsconfig.node.json"
                    "tsconfig.app.json"
                    "vite.config.ts"
                    "tailwind.config.js"
                    "src/index.css"
                )
                for file in "${frontend_files[@]}"; do
                    if [[ ! -f "$frontend_dir/$file" ]]; then
                        log_error "Missing frontend file: $file"
                        error=1
                    fi
                done
            fi
            ;;

        "backend")
            local backend_dir="$project_dir/${project_dir}-backend"
            if [[ ! -d "$backend_dir" ]]; then
                log_error "Missing backend directory"
                error=1
            else
                # Check backend-specific files
                # TODO: Double check this
                local backend_files=(
                    "pom.xml"
                    "mvnw"
                    "mvnw.cmd"
                )
                for file in "${backend_files[@]}"; do
                    if [[ ! -f "$backend_dir/$file" ]]; then
                        log_error "Missing backend file: $file"
                        error=1
                    fi
                done
            fi
            ;;

        "fullstack")
            # Check both frontend and backend
            verify_directory_structure "$project_dir" "frontend"
            verify_directory_structure "$project_dir" "backend"
            ;;
    esac

    return $error
}

# Test frontend project creation
