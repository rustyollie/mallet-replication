#!/bin/bash

# ============================================================================
# MALLET Replication Scripts - Test Suite
# ============================================================================
# Purpose: Comprehensive testing without requiring MALLET installation
#
# Tests:
#   - Configuration file loading
#   - CLI argument parsing
#   - Precedence (config vs CLI)
#   - Validation and error handling
#   - Output file creation
#   - Inference script
#   - Help text display
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_WORK_DIR="$SCRIPT_DIR/test_workspace"

# Setup test environment
setup_test_env() {
    echo "================================================================================"
    echo "MALLET Scripts Test Suite"
    echo "================================================================================"
    echo ""
    echo "Setting up test environment..."

    # Clean and create workspace
    rm -rf "$TEST_WORK_DIR"
    mkdir -p "$TEST_WORK_DIR"

    # Create test input data
    mkdir -p "$TEST_WORK_DIR/input"
    for i in $(seq 1 10); do
        echo "This is test document $i with some sample text for topic modeling." > "$TEST_WORK_DIR/input/doc$(printf '%03d' $i).txt"
    done

    # Add mock mallet to PATH
    export PATH="$SCRIPT_DIR:$PATH"

    # Rename mock to 'mallet' for testing
    if [[ -f "$SCRIPT_DIR/mock_mallet.sh" ]]; then
        ln -sf "$SCRIPT_DIR/mock_mallet.sh" "$SCRIPT_DIR/mallet"
        chmod +x "$SCRIPT_DIR/mallet"
    else
        echo "ERROR: mock_mallet.sh not found"
        exit 1
    fi

    echo "  ✓ Test workspace created: $TEST_WORK_DIR"
    echo "  ✓ Test data created: 10 documents"
    echo "  ✓ Mock MALLET added to PATH"
    echo ""
}

# Cleanup test environment
cleanup_test_env() {
    echo ""
    echo "Cleaning up test environment..."
    rm -rf "$TEST_WORK_DIR"
    rm -f "$SCRIPT_DIR/mallet"
    rm -f "$PROJECT_DIR/config.sh"  # Remove any test config
    echo "  ✓ Cleanup complete"
}

# Test result helpers
pass_test() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}✓ PASS${NC}: $1"
}

fail_test() {
    ((TESTS_FAILED++))
    echo -e "${RED}✗ FAIL${NC}: $1"
    if [[ -n "$2" ]]; then
        echo "  Reason: $2"
    fi
}

run_test() {
    ((TESTS_RUN++))
    echo ""
    echo -e "${BLUE}TEST $TESTS_RUN${NC}: $1"
    echo "---"
}

# ============================================================================
# TEST SUITE
# ============================================================================

# Test 1: Help text displays correctly
test_help_text() {
    run_test "Help text displays correctly"

    local output=$("$PROJECT_DIR/final_mallet_2025.sh" --help 2>&1)

    if echo "$output" | grep -q "USAGE:"; then
        pass_test "Help text contains USAGE section"
    else
        fail_test "Help text missing USAGE section"
    fi

    if echo "$output" | grep -q "CONFIGURATION:"; then
        pass_test "Help text contains CONFIGURATION section"
    else
        fail_test "Help text missing CONFIGURATION section"
    fi

    if echo "$output" | grep -q "config.template.sh"; then
        pass_test "Help text mentions config.template.sh"
    else
        fail_test "Help text doesn't mention config template"
    fi
}

# Test 2: Error when no config and no CLI args
test_no_config_no_args() {
    run_test "Error message when no config and no CLI arguments"

    # Ensure no config file exists
    rm -f "$PROJECT_DIR/config.sh"

    cd "$PROJECT_DIR"
    "$PROJECT_DIR/final_mallet_2025.sh" > /tmp/test_output.txt 2>&1
    local exit_code=$?
    local output=$(cat /tmp/test_output.txt)

    if [[ $exit_code -ne 0 ]]; then
        pass_test "Script exits with error code"
    else
        fail_test "Script should exit with error code" "Exit code: $exit_code"
    fi

    if echo "$output" | grep -q "INPUT_DIR and OUTPUT_DIR are required"; then
        pass_test "Error message mentions required fields"
    else
        fail_test "Error message doesn't mention required fields"
    fi

    if echo "$output" | grep -q "config.template.sh config.sh"; then
        pass_test "Error message suggests config file setup"
    else
        fail_test "Error message doesn't suggest config setup"
    fi
}

# Test 3: CLI arguments work
test_cli_arguments() {
    run_test "Script works with CLI arguments only"

    cd "$PROJECT_DIR"
    local output=$("$PROJECT_DIR/final_mallet_2025.sh" \
        --input-dir "$TEST_WORK_DIR/input" \
        --output-dir "$TEST_WORK_DIR/output_cli" \
        2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass_test "Script completes successfully with CLI args"
    else
        fail_test "Script failed with CLI args" "Exit code: $exit_code"
        return
    fi

    # Check output files created
    if [[ -f "$TEST_WORK_DIR/output_cli/keys.txt" ]]; then
        pass_test "Output file keys.txt created"
    else
        fail_test "Output file keys.txt not created"
    fi

    if [[ -f "$TEST_WORK_DIR/output_cli/topics.txt" ]]; then
        pass_test "Output file topics.txt created"
    else
        fail_test "Output file topics.txt not created"
    fi

    if [[ -f "$TEST_WORK_DIR/output_cli/inferencer.mallet" ]]; then
        pass_test "Output file inferencer.mallet created"
    else
        fail_test "Output file inferencer.mallet not created"
    fi
}

# Test 4: Config file works
test_config_file() {
    run_test "Script works with config file"

    # Create test config
    cat > "$PROJECT_DIR/config.sh" << EOF
INPUT_DIR="$TEST_WORK_DIR/input"
OUTPUT_DIR="$TEST_WORK_DIR/output_config"
NUM_THREADS="8"
EOF

    cd "$PROJECT_DIR"
    local output=$("$PROJECT_DIR/final_mallet_2025.sh" 2>&1)
    local exit_code=$?

    if echo "$output" | grep -q "Configuration loaded from:"; then
        pass_test "Config file loaded message displayed"
    else
        fail_test "Config file loaded message not displayed"
    fi

    if [[ $exit_code -eq 0 ]]; then
        pass_test "Script completes successfully with config file"
    else
        fail_test "Script failed with config file" "Exit code: $exit_code"
        rm -f "$PROJECT_DIR/config.sh"
        return
    fi

    # Check output files
    if [[ -d "$TEST_WORK_DIR/output_config" ]]; then
        pass_test "Output directory created from config"
    else
        fail_test "Output directory not created from config"
    fi

    # Cleanup
    rm -f "$PROJECT_DIR/config.sh"
}

# Test 5: CLI overrides config
test_cli_overrides_config() {
    run_test "CLI arguments override config file"

    # Create config with one output dir
    cat > "$PROJECT_DIR/config.sh" << EOF
INPUT_DIR="$TEST_WORK_DIR/input"
OUTPUT_DIR="$TEST_WORK_DIR/output_from_config"
NUM_THREADS="4"
EOF

    # Run with different output dir via CLI
    cd "$PROJECT_DIR"
    local output=$("$PROJECT_DIR/final_mallet_2025.sh" \
        --output-dir "$TEST_WORK_DIR/output_from_cli" \
        2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass_test "Script completes with CLI override"
    else
        fail_test "Script failed with CLI override" "Exit code: $exit_code"
        rm -f "$PROJECT_DIR/config.sh"
        return
    fi

    # Check that CLI output dir was used, not config
    if [[ -d "$TEST_WORK_DIR/output_from_cli" ]]; then
        pass_test "CLI argument overrode config value"
    else
        fail_test "CLI argument didn't override config value"
    fi

    if [[ ! -d "$TEST_WORK_DIR/output_from_config" ]]; then
        pass_test "Config value was not used (correctly overridden)"
    else
        fail_test "Config value was used (should have been overridden)"
    fi

    # Cleanup
    rm -f "$PROJECT_DIR/config.sh"
}

# Test 6: Validation catches missing input
test_validation_missing_input() {
    run_test "Validation catches missing input directory"

    cd "$PROJECT_DIR"
    "$PROJECT_DIR/final_mallet_2025.sh" \
        --input-dir "$TEST_WORK_DIR/nonexistent" \
        --output-dir "$TEST_WORK_DIR/output_test" \
        > /tmp/test_output.txt 2>&1
    local exit_code=$?
    local output=$(cat /tmp/test_output.txt)

    if [[ $exit_code -ne 0 ]]; then
        pass_test "Script exits with error for missing input"
    else
        fail_test "Script should exit with error for missing input"
    fi

    if echo "$output" | grep -q "Input directory does not exist"; then
        pass_test "Error message mentions missing input directory"
    else
        fail_test "Error message doesn't mention missing input"
    fi
}

# Test 7: Validation catches existing output
test_validation_existing_output() {
    run_test "Validation catches existing output directory"

    # Create output directory first
    mkdir -p "$TEST_WORK_DIR/output_exists"

    cd "$PROJECT_DIR"
    "$PROJECT_DIR/final_mallet_2025.sh" \
        --input-dir "$TEST_WORK_DIR/input" \
        --output-dir "$TEST_WORK_DIR/output_exists" \
        > /tmp/test_output.txt 2>&1
    local exit_code=$?
    local output=$(cat /tmp/test_output.txt)

    if [[ $exit_code -ne 0 ]]; then
        pass_test "Script exits with error for existing output"
    else
        fail_test "Script should exit with error for existing output"
    fi

    if echo "$output" | grep -q "Output directory already exists"; then
        pass_test "Error message mentions existing output directory"
    else
        fail_test "Error message doesn't mention existing output"
    fi
}

# Test 8: Dry-run mode doesn't create files
test_dry_run_mode() {
    run_test "Dry-run mode doesn't create files"

    cd "$PROJECT_DIR"
    local output=$("$PROJECT_DIR/final_mallet_2025.sh" \
        --input-dir "$TEST_WORK_DIR/input" \
        --output-dir "$TEST_WORK_DIR/output_dryrun" \
        --dry-run \
        2>&1)
    local exit_code=$?

    if echo "$output" | grep -q "DRY RUN MODE"; then
        pass_test "Dry-run mode message displayed"
    else
        fail_test "Dry-run mode message not displayed"
    fi

    if echo "$output" | grep -q "mallet import-dir"; then
        pass_test "Import command shown in dry-run"
    else
        fail_test "Import command not shown in dry-run"
    fi

    if echo "$output" | grep -q "mallet train-topics"; then
        pass_test "Train command shown in dry-run"
    else
        fail_test "Train command not shown in dry-run"
    fi

    if [[ ! -d "$TEST_WORK_DIR/output_dryrun" ]]; then
        pass_test "Output directory not created in dry-run"
    else
        fail_test "Output directory should not be created in dry-run"
    fi
}

# Test 9: Inference script works
test_inference_script() {
    run_test "Inference script works correctly"

    # First, create an inferencer file (from previous main script run)
    mkdir -p "$TEST_WORK_DIR/model"
    echo "MALLET_INFERENCER_V1" > "$TEST_WORK_DIR/model/inferencer.mallet"
    echo "MALLET_INPUT_V1" > "$TEST_WORK_DIR/model/input.mallet"

    cd "$PROJECT_DIR"
    local output=$("$PROJECT_DIR/mallet_inference.sh" \
        --inferencer "$TEST_WORK_DIR/model/inferencer.mallet" \
        --input "$TEST_WORK_DIR/model/input.mallet" \
        --output "$TEST_WORK_DIR/inferred_topics.txt" \
        2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass_test "Inference script completes successfully"
    else
        fail_test "Inference script failed" "Exit code: $exit_code"
        return
    fi

    if [[ -f "$TEST_WORK_DIR/inferred_topics.txt" ]]; then
        pass_test "Inference output file created"
    else
        fail_test "Inference output file not created"
    fi
}

# Test 10: Model parameters are fixed
test_model_parameters_fixed() {
    run_test "Model parameters are hardcoded (readonly)"

    # Check if parameters are readonly in script
    local script_content=$(cat "$PROJECT_DIR/final_mallet_2025.sh")

    if echo "$script_content" | grep -q "readonly NUM_TOPICS=60"; then
        pass_test "NUM_TOPICS is readonly and set to 60"
    else
        fail_test "NUM_TOPICS is not properly fixed"
    fi

    if echo "$script_content" | grep -q "readonly RANDOM_SEED=1"; then
        pass_test "RANDOM_SEED is readonly and set to 1"
    else
        fail_test "RANDOM_SEED is not properly fixed"
    fi

    if echo "$script_content" | grep -q "readonly OPTIMIZE_INTERVAL=500"; then
        pass_test "OPTIMIZE_INTERVAL is readonly and set to 500"
    else
        fail_test "OPTIMIZE_INTERVAL is not properly fixed"
    fi
}

# Test 11: Thread auto-detection
test_thread_autodetection() {
    run_test "Thread count auto-detection works"

    cd "$PROJECT_DIR"
    local output=$("$PROJECT_DIR/final_mallet_2025.sh" \
        --input-dir "$TEST_WORK_DIR/input" \
        --output-dir "$TEST_WORK_DIR/output_threads" \
        2>&1)

    if echo "$output" | grep -q "Auto-detected.*threads"; then
        pass_test "Thread auto-detection message displayed"
    else
        fail_test "Thread auto-detection message not displayed"
    fi
}

# Test 12: Stoplist handling
test_stoplist_handling() {
    run_test "Stoplist file handling"

    # Create a test stoplist
    cat > "$TEST_WORK_DIR/test_stoplist.txt" << EOF
the
a
an
is
EOF

    cd "$PROJECT_DIR"
    local output=$("$PROJECT_DIR/final_mallet_2025.sh" \
        --input-dir "$TEST_WORK_DIR/input" \
        --output-dir "$TEST_WORK_DIR/output_stoplist" \
        --stoplist "$TEST_WORK_DIR/test_stoplist.txt" \
        2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass_test "Script works with custom stoplist"
    else
        fail_test "Script failed with custom stoplist" "Exit code: $exit_code"
    fi

    if echo "$output" | grep -q "test_stoplist.txt"; then
        pass_test "Stoplist path shown in configuration"
    else
        fail_test "Stoplist path not shown in configuration"
    fi
}

# ============================================================================
# MAIN TEST EXECUTION
# ============================================================================

main() {
    setup_test_env

    echo "================================================================================"
    echo "Running Tests"
    echo "================================================================================"

    # Run all tests
    test_help_text
    test_no_config_no_args
    test_cli_arguments
    test_config_file
    test_cli_overrides_config
    test_validation_missing_input
    test_validation_existing_output
    test_dry_run_mode
    test_inference_script
    test_model_parameters_fixed
    test_thread_autodetection
    test_stoplist_handling

    # Print summary
    echo ""
    echo "================================================================================"
    echo "Test Summary"
    echo "================================================================================"
    echo ""
    echo "Total tests run:    $TESTS_RUN"
    echo -e "Tests passed:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed:       ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        echo ""
        cleanup_test_env
        exit 0
    else
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        echo ""
        echo "Keeping test workspace for inspection: $TEST_WORK_DIR"
        rm -f "$SCRIPT_DIR/mallet"  # Still cleanup the mock
        exit 1
    fi
}

# Run main
main
