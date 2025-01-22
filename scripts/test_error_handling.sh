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

# Test invalid command line arguments
test_invalid_arguments() {
    log_section "Testing invalid command line arguments"

    # Test missing required arguments
    run_test "Missing project type" \
        "${SCRIPT_DIR}/create_project.sh -n test-project" 1

    run_test "Missing project name" \
        "${SCRIPT_DIR}/create_project.sh -t frontend" 1

    # Test invalid project type
    run_test "Invalid project type" \
        "${SCRIPT_DIR}/create_project.sh -t invalid -n test-project" 1
}

# Test invalid project names
test_invalid_project_names() {
    log_section "Testing invalid project names"

    # Test various invalid project names
    run_test "Project name too short" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n ab" 1

    run_test "Project name with spaces" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n 'test project'" 1

    run_test "Project name with special characters" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n 'test@project'" 1

    run_test "Project name starting with number" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n '1test'" 1

    run_test "Reserved project name" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n 'test'" 1
}

# Test directory conflicts
# TODO: clarify
test_directory_conflicts() {
    log_section "Testing directory conflicts"
    cd "$TEST_DIR"

    # Create a directory that will conflict
    local project_name="test-conflict"
    mkdir -p "$project_name"

    # Test creating project with existing directory
    run_test "Existing directory conflict" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n $project_name" 1

    # Clean up
    rm -rf "$project_name"
}

# Test rollback functionality
# TODO: clarify
test_rollback() {
    log_section "Testing rollback functionality"
    cd "$TEST_DIR"

    local project_name="test-rollback"

    # Create a project that will fail mid-creation
    # We'll simulate this by making a directory read-only after initial creation
    run_test "Rollback on failure" \
        "mkdir $project_name && chmod 555 $project_name && ${SCRIPT_DIR}/create-project.sh -t frontend -n $project_name; chmod 755 $project_name; rm -rf $project_name" 1
    
    # Verify cleanup
    run_test "Cleanup after rollback" \
        "[ ! -d '$project_name' ]" 0
}

# Test system requirements validation
# TODO: clarify
test_system_requirements() {
    log_section "Testing system requirements validation"

    # Test with invalid Node.js version (simulated)
    run_test "Invalid Node.js version" \
        "REQUIRED_NODE_VERSION='999.0.0' ${SCRIPT_DIR}/create_project.sh -t frontend -n test-project" 1

    # Test with invalid Java version (simulated)
    run_test "Invalid Java version" \
        "REQUIRED_JAVA_VERSION='999' ${SCRIPT_DIR}/create_project.sh -t backend -n test-project" 1
}

# Test file operation errors
test_file_operations() {
    log_section "Testing file operation errors"
    cd "$TEST_DIR"

    local project_name="test-file-ops"
    mkdir -p "$project_name"

    # Test write permission error
    chmod 555 "$project_name"
    run_test "Write permission error" \
        "${SCRIPT_DIR}/create_project.sh -t frontend -n $project_name" 1

    # Clean up
    chmod 755 "$project_name"
    rm -rf "$project_name"
}

# Cleanup function
cleanup() {
    log_verbose "Cleaning up test directory..."
    rm -rf "$TEST_DIR"
}

# Run tests based on project type
main() {
    local test_type="$1"
    log_section "Starting error handling tests for: $test_type"

    # Set up trap for cleanup
    trap cleanup EXIT

    # Common tests for all project types
    test_invalid_arguments
    test_invalid_project_names
    test_directory_conflicts
    test_rollback
    test_file_operations

    # Project-specific tests
    case "$test_type" in
        "frontend")
            # Frontend-specific error tests
            run_test "Frontend without Node.js" \
                "NODE_PATH=/invalid ${SCRIPT_DIR}/create_project.sh -t frontend -n test-project" 1
            ;;
        "backend")
            # Backend-specific error tests
            run_test "Backend without Java" \
                "JAVA_HOME=/invalid ${SCRIPT_DIR}/create_project.sh -t backend -n test-project" 1
            ;;
        "fullstack")
            # Fullstack-specific error tests
            run_test "Fullstack without Node.js" \
                "NODE_PATH=/invalid ${SCRIPT_DIR}/create_project.sh -t fullstack -n test-project" 1
            run_test "Fullstack without Java" \
                "JAVA_HOME=/invalid ${SCRIPT_DIR}/create_project.sh -t fullstack -n test-project" 1
            ;;
        *)
            log_error "Invalid test type. Must be one of: frontend, backend, fullstack"
            exit 1
            ;;
    esac

    # Print test summary
    log_section "Test Summary"
    echo "Total tests: $TESTS_TOTAL"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"

    # Exit with failure if any tests failed
    [[ $TESTS_FAILED -eq 0 ]] || exit 1
}

# Check command line argument


# Run tests


# TODO:
# Main thing to clarify - How does this script actually end up testing the error handling?
# Is it based on seeing how these simulated errors are handled by the scripts? 
# Would this be reflected in the terminal?

# Usage:
# ./test_error_handling.sh frontend  # Test frontend error handling
# ./test_error_handling.sh backend   # Test backend error handling
# ./test_error_handling.sh fullstack # Test fullstack error handling
