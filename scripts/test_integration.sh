#!/bin/bash

# Set strict error handling
set -euo pipefail

# Script location
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

# Test validation and git integration
test_validation_git_integration() {
    log_section "Testing validation and git integration"
    cd "$TEST_DIR"

    local project_name="test-validation-git"

    # Create project
    run_test "Project creation with git setup" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n $project_name" 0

    # Verify git setup
    run_test "Git repository initialisation" \
        "[ -d '$project_name/.git' ]" 0

    run_test "Git hooks setup" \
        "[ -x '$project_name/.git/hooks/pre-commit' ]" 0

    # Test git hooks functionality
    # To clarify this part
    cd "$project_name"
    echo "API_KEY=secret123" > .env

    run_test "Git hooks blocks sensitive file" \
        "git add .env && git commit -m 'test commit'" 1

    # Clean up
    cd "$TEST_DIR"
    rm -rf "$project_name"
}

# Test template and file utils integration
test_template_file_integration() {
    log_section "Testing template and file utils integration"
    cd "$TEST_DIR"

    local project_name="test-template-file"

    # Create project
    run_test "Project creation with template setup" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n $project_name" 0

    # Verify file structure
    run_test "Documentation creation" \
        "[ -f '$project_name/README.md' ] && [ -f '$project_name/docs/CONTRIBUTING.md' ]" 0

    # Verify template setup
    local frontend_dir="${project_name}/${project_name}-frontend"
    run_test "Frontend template setup" \
        "[ -f '$frontend_dir/package.json' ] && [ -f '$frontend_dir/tsconfig.json' ]" 0

    # Verify template customization
    run_test "Template customization" \
        "grep -q '$project_name' '$frontend_dir/README.md'" 0

    # Clean up
    rm -rf "$project_name"
}

# Test validation and template integration
test_validation_template_integration() {
    log_section "Testing validation and template integration"
    cd "$TEST_DIR"

    # Test with invalid project name but valid template
    run_test "Invalid name with valid template" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n 'invalid name'" 1

    # Test with valid project name but simulated missing dependencies
    if command -v node &> /dev/null; then
        local original_path="$PATH"
        PATH="/bin:/usr/bin"  # Temporarily remove node from PATH (TODO: double check this)
        run_test "Valid name with missing dependencies" \
            "${SCRIPT_DIR}/create_project.sh -t frontend -n valid-name" 1
        PATH="$original_path"  # Restore PATH
    fi
}

# Test file utils and git integration
test_file_git_integration() {
    log_section "Testing file utils and git integration"
    cd "$TEST_DIR"

    local project_name="test-file-git"

    # Create project
    run_test "Project creation" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n $project_name" 0
    
    cd "$project_name"

    # Verify gitignore rules with file creation
    touch .env
    touch .DS_Store

    run_test "Gitignore functionality" \
        "! git status --porcelain | grep -E '\.(env|DS_Store)'" 0 # TODO: clarify
    
    # Clean up
    cd "$TEST_DIR"
    rm -rf "$project_name"
}

# Comprehensive integration test
test_all_components() {
    log_section "Testing all components together"
    cd "$TEST_DIR"

    local project_name="test-integration"

    # Create fullstack project (tests all components)
    run_test "Fullstack project creation" \
        "${SCRIPT_DIR}/create_project.sh -t fullstack -n $project_name" 0
    
    # Verify complete project setup
    run_test "Complete project structure" \
        "[ -d '$project_name' ] && \
        [ -d '$project_name/.git' ] && \
        [ -d '$project_name/${project_name}-frontend' ] && \
        [ -d '$project_name/${project_name}-backend' ] && \
        [ -f '$project_name/README.md' ]" 0
    
    # Clean up
    rm -rf "$project_name"
}

# Cleanup function


# Run integration test based on project type
main() {

}

# Check command line argument


# Run tests

