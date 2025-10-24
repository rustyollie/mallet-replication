#!/bin/bash

# ============================================================================
# MALLET Topic Inference - Apply Trained Model to New Documents
# ============================================================================
# Purpose: Infer topic distributions for new documents using existing model
# Requires: Trained inferencer file from final_mallet_2025.sh
#
# Version: 1.0
# Last Updated: 2025-10-25
# ============================================================================

# ============================================================================
# CONFIGURABLE PARAMETERS
# ============================================================================
INFERENCER_FILE=""                    # REQUIRED: Trained inferencer.mallet
INPUT=""                              # REQUIRED: New documents (dir or .mallet)
OUTPUT_FILE=""                        # REQUIRED: Output file for inferred topics
RANDOM_SEED=1                         # Default: 1 (for reproducibility)
TEMP_MALLET=""                        # Temporary .mallet file if needed
# ============================================================================

# ============================================================================
# CONFIGURATION FILE LOADING
# ============================================================================
# Load settings from config.sh if it exists
# Command-line arguments will override these settings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

if [[ -f "$CONFIG_FILE" ]]; then
    # Source the config file
    source "$CONFIG_FILE"

    # Map config variables to inference script variables
    if [[ -n "$INFERENCE_INPUT" ]]; then
        INPUT="$INFERENCE_INPUT"
    fi
    if [[ -n "$INFERENCE_OUTPUT" ]]; then
        OUTPUT_FILE="$INFERENCE_OUTPUT"
    fi
    if [[ -n "$INFERENCE_RANDOM_SEED" ]]; then
        RANDOM_SEED="$INFERENCE_RANDOM_SEED"
    fi

    CONFIG_LOADED=true
else
    CONFIG_LOADED=false
fi
# ============================================================================

show_help() {
    cat << EOF
================================================================================
MALLET Topic Inference - Apply Trained Model to New Documents
================================================================================

USAGE:
    ./mallet_inference.sh [OPTIONS]

CONFIGURATION:
    Settings can be provided via config file OR command-line arguments.

    Option 1 - Use config file (recommended):
        Edit config.sh with INFERENCER_FILE, INFERENCE_INPUT, INFERENCE_OUTPUT
        ./mallet_inference.sh

    Option 2 - Use command-line arguments:
        ./mallet_inference.sh --inferencer <path> --input <path> --output <path>

REQUIRED (via config file OR command-line):
    --inferencer <path>     Trained inferencer.mallet file
                            (produced by final_mallet_2025.sh)
    --input <path>          New documents to infer topics for
                            (directory of text files OR .mallet file)
    --output <path>         Output file for inferred topic distributions
                            (will be created)

OPTIONAL ARGUMENTS:
    --random-seed <n>       Random seed (default: 1 for reproducibility)
    --help, -h              Show this help message

EXAMPLES:

    # Infer topics for new documents (from directory):
    ./mallet_inference.sh \\
        --inferencer ./results/inferencer.mallet \\
        --input ./new_documents \\
        --output ./new_topics.txt

    # Infer topics from pre-processed .mallet file:
    ./mallet_inference.sh \\
        --inferencer ./results/inferencer.mallet \\
        --input ./new_docs.mallet \\
        --output ./new_topics.txt

WORKFLOW:

    Step 1: Train model with final_mallet_2025.sh
            This produces inferencer.mallet file

    Step 2: Use this script to apply model to new documents
            This produces topic distributions for new docs

OUTPUT FORMAT:

    The output file contains document-topic distributions:
    <doc_id> <doc_path> <topic:proportion> <topic:proportion> ...

    Example:
    0 file:///path/to/doc001.txt 0:0.15 5:0.22 12:0.18 ...

NOTES:
    - Inferencer file must be from final_mallet_2025.sh
    - Random seed default (1) matches training for consistency
    - If input is directory, files will be imported automatically
    - Requires MALLET installed and in PATH

================================================================================
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --inferencer)
                INFERENCER_FILE="$2"
                shift 2
                ;;
            --input)
                INPUT="$2"
                shift 2
                ;;
            --output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --random-seed)
                RANDOM_SEED="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "ERROR: Unknown option: $1"
                echo "Run with --help for usage information"
                exit 1
                ;;
        esac
    done

    # Check required arguments
    if [[ -z "$INFERENCER_FILE" ]] || [[ -z "$INPUT" ]] || [[ -z "$OUTPUT_FILE" ]]; then
        echo "ERROR: INFERENCER_FILE, INPUT, and OUTPUT_FILE are required"
        echo ""
        echo "Provide them via config file (edit config.sh):"
        echo "  INFERENCER_FILE=\"/path/to/inferencer.mallet\""
        echo "  INFERENCE_INPUT=\"/path/to/new_documents\""
        echo "  INFERENCE_OUTPUT=\"/path/to/output.txt\""
        echo ""
        echo "OR via command-line arguments:"
        echo "  ./mallet_inference.sh --inferencer <path> --input <path> --output <path>"
        echo ""
        echo "Run with --help for more information"
        exit 1
    fi
}

validate_environment() {
    local errors=0

    echo "Validating environment..."

    # Check if mallet is installed
    if ! command -v mallet &> /dev/null; then
        echo "ERROR: 'mallet' command not found in PATH"
        echo "  Install MALLET from: http://mallet.cs.umass.edu/download.php"
        echo "  Then add to PATH: export PATH=/path/to/mallet/bin:\$PATH"
        ((errors++))
    fi

    # Check if inferencer file exists
    if [[ ! -f "$INFERENCER_FILE" ]]; then
        echo "ERROR: Inferencer file not found: $INFERENCER_FILE"
        echo "  You need to train a model first using final_mallet_2025.sh"
        ((errors++))
    fi

    # Check if input exists
    if [[ ! -d "$INPUT" ]] && [[ ! -f "$INPUT" ]]; then
        echo "ERROR: Input not found: $INPUT"
        echo "  Input must be a directory of text files or a .mallet file"
        ((errors++))
    fi

    # Check if input is empty directory
    if [[ -d "$INPUT" ]] && [[ -z "$(ls -A "$INPUT" 2>/dev/null)" ]]; then
        echo "ERROR: Input directory is empty: $INPUT"
        ((errors++))
    fi

    # Check if output file already exists
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "ERROR: Output file already exists: $OUTPUT_FILE"
        echo "  Please remove it or choose a different output path."
        echo "  To remove: rm \"$OUTPUT_FILE\""
        ((errors++))
    fi

    # Validate random seed
    if ! [[ "$RANDOM_SEED" =~ ^[0-9]+$ ]]; then
        echo "ERROR: --random-seed must be a positive integer"
        ((errors++))
    fi

    if [[ $errors -gt 0 ]]; then
        echo ""
        echo "Found $errors error(s). Please fix them and try again."
        return 1
    fi

    echo "  ✓ Environment validation passed"
    return 0
}

cleanup() {
    # Remove temporary .mallet file if created
    if [[ -n "$TEMP_MALLET" ]] && [[ -f "$TEMP_MALLET" ]]; then
        echo "Cleaning up temporary files..."
        rm -f "$TEMP_MALLET"
        echo "  ✓ Cleanup complete"
    fi
}

main() {
    echo "================================================================================"
    echo "MALLET Topic Inference"
    echo "================================================================================"
    echo ""

    # Display configuration source
    if $CONFIG_LOADED; then
        echo "  ✓ Configuration loaded from: $CONFIG_FILE"
        echo ""
    fi

    # Environment validation
    validate_environment || exit 1
    echo ""

    # Determine if input is directory or .mallet file
    if [[ -d "$INPUT" ]]; then
        # Input is a directory - need to import first
        echo "Input is a directory - importing documents..."
        TEMP_MALLET=$(mktemp --suffix=.mallet)
        INPUT_MALLET="$TEMP_MALLET"

        # Import documents
        IMPORT_CMD="mallet import-dir \\
    --input \"$INPUT\" \\
    --output \"$INPUT_MALLET\" \\
    --keep-sequence \\
    --use-pipe-from \"$INFERENCER_FILE\""

        echo "Running: mallet import-dir..."
        eval "$IMPORT_CMD"
        if [[ $? -ne 0 ]]; then
            echo ""
            echo "ERROR: Document import failed. Aborting."
            cleanup
            exit 1
        fi
        echo "  ✓ Documents imported successfully"
        echo ""
    else
        # Input is already a .mallet file
        INPUT_MALLET="$INPUT"
        echo "Input is a .mallet file - using directly"
        echo ""
    fi

    # Display configuration
    echo "Configuration:"
    echo "  Inferencer:           $INFERENCER_FILE"
    echo "  Input:                $INPUT"
    echo "  Input .mallet:        $INPUT_MALLET"
    echo "  Output:               $OUTPUT_FILE"
    echo "  Random Seed:          $RANDOM_SEED"
    echo ""

    # Run inference
    echo "================================================================================"
    echo "Inferring topics for new documents..."
    echo "================================================================================"
    INFER_CMD="mallet infer-topics \\
    --inferencer \"$INFERENCER_FILE\" \\
    --input \"$INPUT_MALLET\" \\
    --output-doc-topics \"$OUTPUT_FILE\" \\
    --random-seed $RANDOM_SEED"

    echo "Running: mallet infer-topics..."
    eval "$INFER_CMD"
    if [[ $? -ne 0 ]]; then
        echo ""
        echo "ERROR: Topic inference failed. Aborting."
        cleanup
        exit 1
    fi
    echo "  ✓ Topic inference completed successfully"
    echo ""

    # Cleanup temporary files
    cleanup

    # Success message
    echo "================================================================================"
    echo "SUCCESS! Topic inference complete."
    echo "================================================================================"
    echo ""
    echo "Output file: $OUTPUT_FILE"
    echo ""
    echo "The output file contains document-topic distributions."
    echo "Each line shows topic proportions for one document."
    echo ""
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Entry point
parse_arguments "$@"
main
