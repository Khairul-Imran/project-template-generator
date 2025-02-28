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

    echo -n "Testing $test_name... "

    if eval "$test_command" > /dev/null 2>&1; then
        # eval -> Executes the command string passed to the function
        # > /dev/null -> redirects standard output to /dev/null (discards it)
        # 2>&1 -> redirects standard error to the same place as standard output
        local actual_result=0 # If command succeeds (exit code 0)
    else
        local actual_result=1 # If command fails (exit code non-zero)
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
    log_section "Testing system requirements validation"

    # Test Node.js validation
    if command -v node &> /dev/null; then
        run_test "Node.js installation" \
            "validate_node" 0
    else
        run_test "Missing Node.js" \
            "validate_node" 1
    fi

    # Test Java validation
    if command -v java &> /dev/null; then
        run_test "Java installation" \
            "validate_java" 0
    else
        run_test "Missing Java" \
            "validate_java" 1
    fi

    # Test Maven validation
    if command -v mvn &> /dev/null; then
        run_test "Maven installation" \
            "validate_maven" 0
    else
        run_test "Missing Maven" \
            "validate_maven" 1
    fi
}

# Test backup and rollback
test_backup_rollback() {
    log_section "Testing backup and rollback"

    # Create test directory
    local test_dir="test-project"

    # Ensure clean state
    if [[ -d "$test_dir" ]] || [[ -d "${test_dir}.bak" ]]; then
        rm -rf "$test_dir" "${test_dir}.bak"
    fi

    mkdir -p "$test_dir"
    if [[ ! -d "$test_dir" ]]; then
        log_error "Failed to create test directory"
        return 1
    fi

    # Test backup creation
    run_test "Backup creation" \
        "create_backup '$test_dir'" 0

    # Verify that backup exists
    run_test "Backup exists" \
        "test -d '${test_dir}.bak'" 0

    # Test rollback
    run_test "Rollback functionality" \
        "rollback '$test_dir'" 0

    # Clean up with verification
    # Double-check variables aren't empty
    if [[ -n "$test_dir" ]]; then

        # Add check if directories exist before listing/removing
        if [[ -d "$test_dir" ]]; then
            log_verbose "Contents of test directory before cleanup:"
            ls -la "$test_dir"
        fi

        log_verbose "Performing cleanup..."
        rm -rf "${test_dir}" "${test_dir}.bak"

        # Verify cleanup
        if [[ -d "$test_dir" ]] || [[ -d "${test_dir}.bak" ]]; then
            log_error "Cleanup failed - directories still exist"
            return 1
        fi
        
        log_verbose "Cleanup completed successfully"
    fi
}

# Run all tests
main() {
    log_section "Starting validation tests"

    test_project_name_validation
    test_version_comparison
    test_system_requirements
    test_backup_rollback

    # Print test summary
    log_section "Test Summary"
    echo "Total tests: $TESTS_TOTAL"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"

    # Exit with failure if any tests failed
    [[ $TESTS_FAILED -eq 0 ]] || exit 1
}

# Run tests
main

# TODO: to test this script
