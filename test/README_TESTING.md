# MALLET Replication Scripts - Testing Guide

This directory contains testing tools for the MALLET replication scripts, allowing you to test without having MALLET installed.

## Quick Start

```bash
# Run the full test suite
cd test/
./run_tests.sh
```

That's it! The test suite will:
- Create a mock MALLET environment
- Run 12 comprehensive tests
- Report results
- Clean up automatically

---

## What Gets Tested

### 1. **Help Text Display** ✓
- Verifies `--help` shows proper usage
- Checks for configuration instructions
- Validates documentation completeness

### 2. **Error Handling** ✓
- No config file and no CLI arguments
- Missing input directories
- Existing output directories
- Invalid parameters

### 3. **Configuration Loading** ✓
- Config file is read correctly
- Settings are applied
- Configuration message is displayed

### 4. **CLI Arguments** ✓
- Works without config file
- All arguments parsed correctly
- Output files created as expected

### 5. **Precedence** ✓
- CLI arguments override config file
- Correct values are used
- Both sources can work together

### 6. **Validation** ✓
- Missing directories caught
- Existing output directories rejected
- Clear error messages displayed

### 7. **Dry-Run Mode** ✓
- Commands displayed but not executed
- No files created
- Can preview what will run

### 8. **Inference Script** ✓
- Works with trained models
- Accepts both directories and .mallet files
- Creates output correctly

### 9. **Model Parameters** ✓
- Parameters are `readonly`
- Cannot be modified
- Fixed at correct values (60 topics, seed 1, etc.)

### 10. **Thread Auto-Detection** ✓
- Detects CPU count
- Falls back to safe default
- Can be overridden

### 11. **Stoplist Handling** ✓
- Custom stoplists work
- Default stoplist used if available
- Can run without stoplist

### 12. **Output File Creation** ✓
- All expected files created
- Correct file formats
- Proper naming conventions

---

## Test Files

### `mock_mallet.sh`
A fake MALLET executable that:
- Accepts real MALLET commands (`import-dir`, `train-topics`, `infer-topics`)
- Validates arguments
- Creates dummy output files with realistic structure
- Exits with proper status codes
- Fast execution (no actual processing)

**Supports all MALLET commands used by the scripts:**
```bash
mallet import-dir --input <dir> --output <file> [--stoplist-file <file>]
mallet train-topics --input <file> --num-topics <n> [many options...]
mallet infer-topics --inferencer <file> --input <file> --output <file>
```

### `run_tests.sh`
Comprehensive test suite that:
- Sets up isolated test environment
- Creates test data automatically
- Runs all test scenarios
- Reports results with colored output
- Cleans up after completion

**Features:**
- 12 different test scenarios
- Color-coded output (green=pass, red=fail)
- Detailed error messages
- Test workspace isolation
- Automatic cleanup

---

## Running Tests

### Run All Tests
```bash
cd test/
./run_tests.sh
```

### Expected Output
```
================================================================================
MALLET Scripts Test Suite
================================================================================

Setting up test environment...
  ✓ Test workspace created: .../test_workspace
  ✓ Test data created: 10 documents
  ✓ Mock MALLET added to PATH

================================================================================
Running Tests
================================================================================

TEST 1: Help text displays correctly
---
✓ PASS: Help text contains USAGE section
✓ PASS: Help text contains CONFIGURATION section
✓ PASS: Help text mentions config.template.sh

TEST 2: Error message when no config and no CLI arguments
---
✓ PASS: Script exits with error code
✓ PASS: Error message mentions required fields
✓ PASS: Error message suggests config file setup

...

================================================================================
Test Summary
================================================================================

Total tests run:    12
Tests passed:       12
Tests failed:       0

✓ ALL TESTS PASSED
```

---

## Manual Testing

You can also use the mock MALLET for manual testing:

### 1. Add Mock to PATH
```bash
export PATH="/path/to/project/test:$PATH"
ln -s mock_mallet.sh mallet
```

### 2. Run Scripts Manually
```bash
# Test main script
./final_mallet_2025.sh \
    --input-dir ./test_data \
    --output-dir ./test_results

# Test inference script
./mallet_inference.sh \
    --inferencer ./test_results/inferencer.mallet \
    --input ./new_data \
    --output ./inferred.txt
```

### 3. Verify Output
```bash
ls test_results/
# Should see: keys.txt, topics.txt, model.mallet, inferencer.mallet, etc.
```

---

## Mock MALLET Details

### What It Does
The mock creates realistic output files that mimic MALLET's actual output:

**keys.txt** - Topic keywords:
```
0	0.12345	word1 word2 word3 word4 word5 ...
1	0.23456	term1 term2 term3 term4 term5 ...
```

**topics.txt** - Document-topic distributions:
```
0	file:///mock/doc001.txt	0:0.15 1:0.08 2:0.22 5:0.11
1	file:///mock/doc002.txt	0:0.05 2:0.31 3:0.14 8:0.12
```

**Other files:**
- `.mallet` files (binary format markers)
- `diagnostics.xml` (XML with model info)
- Weight and count files

### What It Doesn't Do
- Actual topic modeling (it's just a test mock)
- Real statistical inference
- Produce meaningful results for analysis

**The mock is for testing scripts, not for real analysis!**

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Test MALLET Scripts

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          cd test
          ./run_tests.sh
```

### GitLab CI Example

```yaml
test:
  script:
    - cd test
    - ./run_tests.sh
  artifacts:
    when: on_failure
    paths:
      - test/test_workspace/
```

---

## Troubleshooting

### "Permission denied" Error
```bash
chmod +x test/run_tests.sh
chmod +x test/mock_mallet.sh
```

### Tests Fail with "mallet: command not found"
The test suite should handle this automatically, but if you see this error:
```bash
cd test/
export PATH="$PWD:$PATH"
ln -s mock_mallet.sh mallet
./run_tests.sh
```

### Test Workspace Not Cleaned Up
If tests fail, the workspace is kept for inspection:
```bash
ls test/test_workspace/
rm -rf test/test_workspace/  # Manual cleanup
```

### Want to See Test Internals
Add debug output to `run_tests.sh`:
```bash
# At top of run_tests.sh
set -x  # Show all commands
```

---

## Adding New Tests

To add a new test to `run_tests.sh`:

```bash
# Test template
test_your_new_test() {
    run_test "Description of what you're testing"

    # Your test logic here
    local output=$("$PROJECT_DIR/final_mallet_2025.sh" --your-args 2>&1)
    local exit_code=$?

    # Assertions
    if [[ $exit_code -eq 0 ]]; then
        pass_test "Your success condition"
    else
        fail_test "Your failure condition" "Reason"
    fi
}

# Add to main() function
main() {
    # ... existing tests ...
    test_your_new_test
}
```

---

## Test Coverage

Current test coverage:

| Component | Tested | Notes |
|-----------|--------|-------|
| CLI argument parsing | ✓ | All arguments |
| Config file loading | ✓ | Both scripts |
| Precedence logic | ✓ | Config vs CLI |
| Validation | ✓ | All checks |
| Error handling | ✓ | All error paths |
| Output creation | ✓ | All files |
| Help text | ✓ | Completeness |
| Model parameters | ✓ | Readonly check |
| Dry-run mode | ✓ | No execution |
| Inference | ✓ | Full workflow |
| Stoplist | ✓ | Custom & default |
| Thread detection | ✓ | Auto & manual |

**Coverage: ~100% of user-facing functionality**

---

## Best Practices

### Before Committing Code
```bash
# Always run tests first
cd test/
./run_tests.sh
```

### Before Releasing
```bash
# Run tests multiple times to catch flakiness
for i in {1..5}; do
    echo "Run $i"
    ./test/run_tests.sh || exit 1
done
```

### When Modifying Scripts
1. Run existing tests first (should pass)
2. Make your changes
3. Run tests again
4. Add new tests for new functionality
5. Ensure all tests pass before committing

---

## FAQ

**Q: Do I need MALLET installed to run tests?**
A: No! That's the whole point. The mock handles everything.

**Q: Can I use the mock for real analysis?**
A: No. It creates dummy output for testing only. Use real MALLET for actual research.

**Q: How long do tests take?**
A: ~5-10 seconds for the full suite. Much faster than testing with real MALLET.

**Q: Can I test on CI/CD without MALLET?**
A: Yes! That's exactly what this is designed for.

**Q: Do tests modify my config.sh?**
A: Tests create temporary config files and clean them up. Your real config.sh is safe.

**Q: What if a test fails?**
A: The test workspace is preserved for inspection. Check `test/test_workspace/` for details.

---

## Contact

For issues with the test suite, check:
1. This README
2. Comments in `run_tests.sh`
3. The main project README

For test failures, the output will guide you to the issue.

---

## Version

Test Suite Version: 1.0
Last Updated: 2025-10-25
Compatible with: final_mallet_2025.sh v2.0, mallet_inference.sh v1.0
