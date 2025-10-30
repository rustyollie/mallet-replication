#!/bin/bash
# ============================================================================
# Test Runner for HTRC Preprocessing Pipeline
# ============================================================================
# Runs unit tests for preprocessing functions
# Tests do NOT require HTRC files or MALLET installation
# ============================================================================

set -e  # Exit on error

# Get directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================================================"
echo "HTRC Preprocessing - Test Suite"
echo "================================================================================"
echo ""

# Check if Python is available
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "ERROR: Python not found"
    exit 1
fi

# Use python3 if available, otherwise python
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi

echo "Using Python: $($PYTHON_CMD --version)"
echo ""

# Check if required modules are installed
echo "Checking dependencies..."
$PYTHON_CMD -c "import pandas, nltk, pycountry" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "ERROR: Required Python modules not installed"
    echo "Install with: pip install pandas nltk pycountry"
    exit 1
fi
echo "  ✓ All required modules installed"
echo ""

# Run tests
echo "Running tests..."
echo ""
$PYTHON_CMD test_preprocessing.py

# Check exit code
if [ $? -eq 0 ]; then
    echo ""
    echo "================================================================================"
    echo "✓ ALL TESTS PASSED"
    echo "================================================================================"
    exit 0
else
    echo ""
    echo "================================================================================"
    echo "✗ TESTS FAILED"
    echo "================================================================================"
    exit 1
fi
