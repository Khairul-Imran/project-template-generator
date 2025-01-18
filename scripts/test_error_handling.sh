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
test_directory_conflicts() {
    
}
