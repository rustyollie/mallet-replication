#!/bin/bash

# ============================================================================
# SLURM CONFIGURATION (For HPC Users)
# ============================================================================
# Customize these headers for your HPC environment:
# - Change --account to your allocation
# - Adjust --mem, --time, --partition for your cluster
# - Remove these headers entirely if running locally (non-SLURM)
# ============================================================================

#SBATCH --time=40:00:00
#SBATCH --qos=mem
#SBATCH --partition=amem
#SBATCH --ntasks=48
#SBATCH --mem=500000
#SBATCH --nodes=1
#SBATCH --job-name=master-mallet
#SBATCH --output=mallet_run_%j.out    # %j = job ID (auto-generated)
#SBATCH --account=ucb593_asc1          # CHANGE THIS to your account

# ============================================================================
# MALLET Topic Modeling - Replication Script
# ============================================================================
# Purpose: Exact replication of topic modeling analysis
#
# WARNING: Model parameters (num-topics, random-seed) are INTENTIONALLY
# HARDCODED for reproducibility. Changing these produces different results
# and breaks replication. Only configure infrastructure parameters (paths).
#
# Version: 2.0
# Last Updated: 2025-10-25
# ============================================================================

# ============================================================================
# MODEL PARAMETERS - DO NOT MODIFY (Ensures Exact Replication)
# ============================================================================
readonly NUM_TOPICS=60                # Number of topics in the model
readonly RANDOM_SEED=1                # RNG seed for reproducibility
readonly OPTIMIZE_INTERVAL=500        # Hyperparameter optimization frequency

# These values are fixed to ensure your results match the published analysis.
# Changing them means you're running a DIFFERENT analysis.
# ============================================================================

# ============================================================================
# CONFIGURABLE PARAMETERS (Paths and System Resources)
# ============================================================================
INPUT_DIR=""                          # REQUIRED: Where your text files are
OUTPUT_DIR=""                         # REQUIRED: Where results will be saved
STOPLIST_FILE=""                      # Optional: Custom stoplist path
NUM_THREADS=""                        # Auto-detect if not specified
DRY_RUN=false                         # Preview commands without executing

# Module loading (HPC-specific, ignored if modules don't exist)
MODULE_PURGE=true
MODULE_JAVA="jdk/1.8.0"               # Customize for your cluster
# ============================================================================

# ============================================================================
# CONFIGURATION FILE LOADING
# ============================================================================
# Load settings from config.sh if it exists
# Command-line arguments will override these settings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SLURM_SUBMIT_DIR:-$SCRIPT_DIR}/config.sh"

if [[ -f "$CONFIG_FILE" ]]; then
    # Source the config file
    source "$CONFIG_FILE"
    CONFIG_LOADED=true
else
    CONFIG_LOADED=false
fi
# ============================================================================

show_help() {
    cat << EOF
================================================================================
MALLET Topic Modeling - Replication Script
================================================================================

USAGE:
    ./final_mallet_2025.sh [OPTIONS]

CONFIGURATION:
    Settings can be provided via config file OR command-line arguments.

    Option 1 - Use config file (recommended):
        1. cp config.template.sh config.sh
        2. Edit config.sh with your paths
        3. ./final_mallet_2025.sh

    Option 2 - Use command-line arguments:
        ./final_mallet_2025.sh --input-dir <path> --output-dir <path>

    Option 3 - Mix both (CLI overrides config):
        Edit config.sh for standard settings, override specific ones via CLI

REQUIRED (via config file OR command-line):
    --input-dir <path>      Directory containing input text files
    --output-dir <path>     Directory where output files will be created
                            (must not already exist)

OPTIONAL ARGUMENTS:
    --stoplist <path>       Custom stoplist file
                            (default: ./default_stoplist.txt if exists)
    --num-threads <n>       Number of threads (default: auto-detect)
    --dry-run               Show commands without executing
    --help, -h              Show this help message

EXAMPLES:

    # Using config file (recommended):
    cp config.template.sh config.sh
    vim config.sh                    # Edit your paths
    ./final_mallet_2025.sh          # Run with config

    # Using command-line arguments:
    ./final_mallet_2025.sh \\
        --input-dir ./my_data \\
        --output-dir ./results

    # Mix config + CLI override:
    ./final_mallet_2025.sh --output-dir ./special_output

    # HPC with config file:
    cp config.template.sh config.sh
    vim config.sh                    # Edit your paths
    sbatch final_mallet_2025.sh

    # Preview without running (dry-run):
    ./final_mallet_2025.sh --dry-run

OUTPUT FILES:
    input.mallet              - Preprocessed corpus
    keys.txt                  - Topic keywords (human-readable descriptions)
    model.mallet              - Trained model
    topic_word_weights.txt    - Word-topic distributions
    word_topic_counts.txt     - Count matrices
    topics.txt                - Document-topic distributions (main output)
    inferencer.mallet         - Inference model (for new documents)
    diagnostics.xml           - Training diagnostics

MODEL PARAMETERS (FIXED FOR REPLICATION):
    Topics: $NUM_TOPICS
    Random Seed: $RANDOM_SEED
    Optimization Interval: $OPTIMIZE_INTERVAL

NOTES:
    - Model parameters are hardcoded to ensure exact replication
    - Requires MALLET installed and in PATH
    - For HPC: Customize SLURM headers at top of script
    - For inference on new data, use mallet_inference.sh separately

DOCUMENTATION:
    See README.md for detailed setup and troubleshooting

================================================================================
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --input-dir)
                INPUT_DIR="$2"
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --stoplist)
                STOPLIST_FILE="$2"
                shift 2
                ;;
            --num-threads)
                NUM_THREADS="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
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
    if [[ -z "$INPUT_DIR" ]] || [[ -z "$OUTPUT_DIR" ]]; then
        echo "ERROR: INPUT_DIR and OUTPUT_DIR are required"
        echo ""
        echo "Provide them via config file:"
        echo "  1. cp config.template.sh config.sh"
        echo "  2. Edit config.sh with your paths"
        echo ""
        echo "OR via command-line arguments:"
        echo "  ./final_mallet_2025.sh --input-dir <path> --output-dir <path>"
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

    # Check input directory exists
    if [[ ! -d "$INPUT_DIR" ]]; then
        echo "ERROR: Input directory does not exist: $INPUT_DIR"
        ((errors++))
    else
        # Check if input directory has files
        if [[ -z "$(ls -A "$INPUT_DIR" 2>/dev/null)" ]]; then
            echo "ERROR: Input directory is empty: $INPUT_DIR"
            ((errors++))
        fi
    fi

    # Check if output directory already exists (MUST NOT EXIST)
    if [[ -d "$OUTPUT_DIR" ]]; then
        echo "ERROR: Output directory already exists: $OUTPUT_DIR"
        echo "  Please remove it or choose a different output directory."
        echo "  To remove: rm -rf \"$OUTPUT_DIR\""
        ((errors++))
    fi

    # Check stoplist if specified
    if [[ -n "$STOPLIST_FILE" ]] && [[ ! -f "$STOPLIST_FILE" ]]; then
        echo "ERROR: Stoplist file not found: $STOPLIST_FILE"
        ((errors++))
    fi

    # Validate numeric parameters
    if [[ -n "$NUM_THREADS" ]] && ! [[ "$NUM_THREADS" =~ ^[0-9]+$ ]]; then
        echo "ERROR: --num-threads must be a positive integer"
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

detect_threads() {
    if [[ -z "$NUM_THREADS" ]]; then
        # Try various methods to detect CPU count
        if command -v nproc &> /dev/null; then
            NUM_THREADS=$(nproc)
        elif [[ -f /proc/cpuinfo ]]; then
            NUM_THREADS=$(grep -c ^processor /proc/cpuinfo)
        elif command -v sysctl &> /dev/null; then
            NUM_THREADS=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)
        else
            NUM_THREADS=4  # Conservative default
        fi
        echo "  ✓ Auto-detected $NUM_THREADS threads"
    else
        echo "  ✓ Using $NUM_THREADS threads (user-specified)"
    fi
}

run_command() {
    if $DRY_RUN; then
        echo "$1"
        echo ""
    else
        eval "$1"
        if [[ $? -ne 0 ]]; then
            echo ""
            echo "ERROR: Command failed. Aborting."
            exit 1
        fi
    fi
}

main() {
    echo "================================================================================"
    echo "MALLET Topic Modeling - Replication Script"
    echo "================================================================================"
    echo ""

    # Display configuration source
    if $CONFIG_LOADED; then
        echo "  ✓ Configuration loaded from: $CONFIG_FILE"
        echo ""
    fi

    # Module loading (HPC only)
    if $MODULE_PURGE && command -v module &> /dev/null; then
        echo "Loading HPC modules..."
        module purge
        module load $MODULE_JAVA
        echo "  ✓ Modules loaded"
        echo ""
    fi

    # Environment validation
    validate_environment || exit 1
    echo ""

    # Auto-detect threads
    detect_threads
    echo ""

    # Handle stoplist
    if [[ -z "$STOPLIST_FILE" ]]; then
        # Look for default in script directory
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        DEFAULT_STOPLIST="$SCRIPT_DIR/default_stoplist.txt"
        if [[ -f "$DEFAULT_STOPLIST" ]]; then
            STOPLIST_FILE="$DEFAULT_STOPLIST"
            echo "  ✓ Using default stoplist: $STOPLIST_FILE"
        else
            echo "  ⚠ No stoplist specified (proceeding without one)"
        fi
    else
        echo "  ✓ Using stoplist: $STOPLIST_FILE"
    fi

    # Build stoplist argument
    STOPLIST_ARG=""
    if [[ -n "$STOPLIST_FILE" ]]; then
        STOPLIST_ARG="--stoplist-file \"$STOPLIST_FILE\""
    fi

    # Display configuration
    echo ""
    echo "Configuration:"
    echo "  Input Directory:      $INPUT_DIR"
    echo "  Output Directory:     $OUTPUT_DIR"
    echo "  Stoplist:             ${STOPLIST_FILE:-none}"
    echo "  Threads:              $NUM_THREADS"
    echo "  Topics:               $NUM_TOPICS (fixed)"
    echo "  Random Seed:          $RANDOM_SEED (fixed)"
    echo "  Optimization:         Every $OPTIMIZE_INTERVAL iterations (fixed)"
    echo ""

    if $DRY_RUN; then
        echo "================================================================================"
        echo "DRY RUN MODE - Commands that would be executed:"
        echo "================================================================================"
        echo ""
    fi

    # Create output directory
    run_command "mkdir -p \"$OUTPUT_DIR\""

    # Step 1: Import documents
    echo "================================================================================"
    echo "Step 1/2: Importing documents..."
    echo "================================================================================"
    IMPORT_CMD="mallet import-dir \\
    --input \"$INPUT_DIR\" \\
    --output \"$OUTPUT_DIR/input.mallet\" \\
    --keep-sequence \\
    $STOPLIST_ARG"

    if $DRY_RUN; then
        echo "$IMPORT_CMD"
        echo ""
    else
        echo "Running: mallet import-dir..."
        eval "$IMPORT_CMD"
        if [[ $? -ne 0 ]]; then
            echo ""
            echo "ERROR: Document import failed. Aborting."
            exit 1
        fi
        echo "  ✓ Documents imported successfully"
    fi
    echo ""

    # Step 2: Train topics
    echo "================================================================================"
    echo "Step 2/2: Training topic model..."
    echo "================================================================================"
    TRAIN_CMD="mallet train-topics \\
    --num-threads $NUM_THREADS \\
    --input \"$OUTPUT_DIR/input.mallet\" \\
    --num-topics $NUM_TOPICS \\
    --output-topic-keys \"$OUTPUT_DIR/keys.txt\" \\
    --output-model \"$OUTPUT_DIR/model.mallet\" \\
    --topic-word-weights-file \"$OUTPUT_DIR/topic_word_weights.txt\" \\
    --word-topic-counts-file \"$OUTPUT_DIR/word_topic_counts.txt\" \\
    --output-doc-topics \"$OUTPUT_DIR/topics.txt\" \\
    --inferencer-filename \"$OUTPUT_DIR/inferencer.mallet\" \\
    --optimize-interval $OPTIMIZE_INTERVAL \\
    --diagnostics-file \"$OUTPUT_DIR/diagnostics.xml\" \\
    --random-seed $RANDOM_SEED"

    if $DRY_RUN; then
        echo "$TRAIN_CMD"
        echo ""
    else
        echo "Running: mallet train-topics..."
        echo "(This may take a while depending on corpus size...)"
        eval "$TRAIN_CMD"
        if [[ $? -ne 0 ]]; then
            echo ""
            echo "ERROR: Topic training failed. Aborting."
            exit 1
        fi
        echo "  ✓ Topic model trained successfully"
    fi
    echo ""

    # Success message
    if ! $DRY_RUN; then
        echo "================================================================================"
        echo "SUCCESS! Topic modeling complete."
        echo "================================================================================"
        echo ""
        echo "Output files in: $OUTPUT_DIR"
        echo ""
        echo "Key output files:"
        echo "  - keys.txt                   Topic keywords (human-readable)"
        echo "  - topics.txt                 Document-topic distributions"
        echo "  - topic_word_weights.txt     Word-topic distributions"
        echo "  - inferencer.mallet          For inference on new documents"
        echo "  - diagnostics.xml            Training diagnostics"
        echo ""
        echo "To apply this model to new documents, use: mallet_inference.sh"
        echo ""
    else
        echo "================================================================================"
        echo "DRY RUN COMPLETE - No commands were executed"
        echo "================================================================================"
        echo ""
        echo "Remove --dry-run flag to execute these commands."
        echo ""
    fi
}

# Entry point
parse_arguments "$@"
main
