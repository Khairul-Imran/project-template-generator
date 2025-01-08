#!/bin/bash

# Set strict error handling
set -euo pipefail

# Script location
# Clarify ***
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required files
source "${SCRIPT_DIR}/lib/logger_utils.sh"
source "${SCRIPT_DIR}/lib/validation_utils.sh"

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

# Test project name validation
test_project_name_validation() {
    log_section "Testing project name validation"

    # Valid cases (should return 0)
    run_test "Valid project name" \
        "validate_project_name 'my-project'" 0

    run_test "Project name with numbers" \
        "validate_project_name 'project123'" 0
    
    run_test "Project name with hyphens" \
        "validate_project_name 'my-cool-project'" 0
    
    # Invalid cases (should return 1)
    run_test "Too short name" \
        "validate_project_name 'ab'" 1
    
    run_test "Too long name" \
        "validate_project_name $(printf 'a%.0s' {1..51})" 1
    
    run_test "Name with spaces" \
        "validate_project_name 'my project'" 1
    
    run_test "Name with special characters" \
        "validate_project_name 'project@123'" 1
    
    run_test "Name starting with number" \
        "validate_project_name '123project'" 1
    
    run_test "Reserved name" \
        "validate_project_name 'test'" 1
}

# Test version comparison
# TODO To clarify how this should be done.... 
test_version_comparison() {
    log_section "Testing version comparison"

    run_test "Equal versions" \
        "verify_version '1.0.0' '1.0.0'" 0
    
    run_test "Higher version" \
        "verify_version '2.0.0' '1.0.0'" 0
    
    run_test "Lower version" \
        "verify_version '1.0.0' '2.0.0'" 1
    
    run_test "Complex version comparison" \
        "verify_version '2.1.3' '2.1.2'" 0
}

# Test system requirements validation
test_system_requirements() {
    
}

# Test backup and rollback
test_backup_rollback() {

}

# Run all tests
main() {

}

# Run tests
main