#!/bin/bash

# ============================================================================
# Mock MALLET - For Testing Without Real MALLET Installation
# ============================================================================
# Purpose: Simulates MALLET behavior for testing scripts
#
# Supports:
#   - import-dir
#   - train-topics
#   - infer-topics
#
# Creates dummy output files that mimic real MALLET output
# ============================================================================

COMMAND="$1"
shift

# Parse arguments based on command
parse_import_dir() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --input)
                INPUT="$2"
                shift 2
                ;;
            --output)
                OUTPUT="$2"
                shift 2
                ;;
            --keep-sequence)
                KEEP_SEQUENCE=true
                shift
                ;;
            --stoplist-file)
                STOPLIST="$2"
                shift 2
                ;;
            --use-pipe-from)
                USE_PIPE="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Validate required args
    if [[ -z "$INPUT" ]] || [[ -z "$OUTPUT" ]]; then
        echo "ERROR: --input and --output required for import-dir"
        exit 1
    fi

    # Check input exists
    if [[ ! -d "$INPUT" ]] && [[ ! -f "$INPUT" ]]; then
        echo "ERROR: Input not found: $INPUT"
        exit 1
    fi

    # Create dummy .mallet file
    echo "Mock MALLET: Importing from $INPUT to $OUTPUT"
    echo "MALLET_BINARY_FORMAT_V1" > "$OUTPUT"
    echo "# Mock .mallet file created by test suite" >> "$OUTPUT"
    echo "# Documents: 100" >> "$OUTPUT"
    echo "# Vocabulary size: 5000" >> "$OUTPUT"

    return 0
}

parse_train_topics() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --input)
                INPUT="$2"
                shift 2
                ;;
            --num-topics)
                NUM_TOPICS="$2"
                shift 2
                ;;
            --num-threads)
                NUM_THREADS="$2"
                shift 2
                ;;
            --output-topic-keys)
                OUTPUT_KEYS="$2"
                shift 2
                ;;
            --output-model)
                OUTPUT_MODEL="$2"
                shift 2
                ;;
            --topic-word-weights-file)
                OUTPUT_WEIGHTS="$2"
                shift 2
                ;;
            --word-topic-counts-file)
                OUTPUT_COUNTS="$2"
                shift 2
                ;;
            --output-doc-topics)
                OUTPUT_TOPICS="$2"
                shift 2
                ;;
            --inferencer-filename)
                OUTPUT_INFERENCER="$2"
                shift 2
                ;;
            --diagnostics-file)
                DIAGNOSTICS="$2"
                shift 2
                ;;
            --optimize-interval)
                OPTIMIZE="$2"
                shift 2
                ;;
            --random-seed)
                SEED="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Validate required args
    if [[ -z "$INPUT" ]]; then
        echo "ERROR: --input required for train-topics"
        exit 1
    fi

    # Check input exists
    if [[ ! -f "$INPUT" ]]; then
        echo "ERROR: Input file not found: $INPUT"
        exit 1
    fi

    echo "Mock MALLET: Training topics"
    echo "  Input: $INPUT"
    echo "  Topics: ${NUM_TOPICS:-50}"
    echo "  Threads: ${NUM_THREADS:-1}"
    echo "  Random seed: ${SEED:-0}"

    # Create dummy output files
    if [[ -n "$OUTPUT_KEYS" ]]; then
        cat > "$OUTPUT_KEYS" << EOF
0	0.12345	word1 word2 word3 word4 word5 word6 word7 word8 word9 word10
1	0.23456	term1 term2 term3 term4 term5 term6 term7 term8 term9 term10
2	0.34567	token1 token2 token3 token4 token5 token6 token7 token8 token9 token10
EOF
        for i in $(seq 3 59); do
            echo "$i	0.01234	mock$i word$i term$i token$i test$i sample$i example$i data$i text$i doc$i" >> "$OUTPUT_KEYS"
        done
    fi

    if [[ -n "$OUTPUT_MODEL" ]]; then
        echo "MALLET_MODEL_V1" > "$OUTPUT_MODEL"
        echo "# Mock model file" >> "$OUTPUT_MODEL"
    fi

    if [[ -n "$OUTPUT_WEIGHTS" ]]; then
        echo "# Topic-word weights" > "$OUTPUT_WEIGHTS"
        for i in $(seq 0 59); do
            echo "$i word$i 0.05" >> "$OUTPUT_WEIGHTS"
        done
    fi

    if [[ -n "$OUTPUT_COUNTS" ]]; then
        echo "# Word-topic counts" > "$OUTPUT_COUNTS"
        for i in $(seq 0 59); do
            echo "word$i $i 10" >> "$OUTPUT_COUNTS"
        done
    fi

    if [[ -n "$OUTPUT_TOPICS" ]]; then
        cat > "$OUTPUT_TOPICS" << EOF
0	file:///mock/doc001.txt	0:0.15 1:0.08 2:0.22 5:0.11 10:0.09
1	file:///mock/doc002.txt	0:0.05 2:0.31 3:0.14 8:0.12 15:0.07
2	file:///mock/doc003.txt	1:0.19 4:0.16 6:0.13 12:0.10 20:0.08
EOF
        for i in $(seq 3 99); do
            echo "$i	file:///mock/doc$(printf '%03d' $i).txt	0:0.1 1:0.1 2:0.1 3:0.1 5:0.1" >> "$OUTPUT_TOPICS"
        done
    fi

    if [[ -n "$OUTPUT_INFERENCER" ]]; then
        echo "MALLET_INFERENCER_V1" > "$OUTPUT_INFERENCER"
        echo "# Mock inferencer file" >> "$OUTPUT_INFERENCER"
    fi

    if [[ -n "$DIAGNOSTICS" ]]; then
        cat > "$DIAGNOSTICS" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<model>
  <topics>60</topics>
  <iterations>1000</iterations>
  <seed>${SEED:-0}</seed>
  <optimize-interval>${OPTIMIZE:-10}</optimize-interval>
</model>
EOF
    fi

    return 0
}

parse_infer_topics() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --inferencer)
                INFERENCER="$2"
                shift 2
                ;;
            --input)
                INPUT="$2"
                shift 2
                ;;
            --output-doc-topics)
                OUTPUT="$2"
                shift 2
                ;;
            --random-seed)
                SEED="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Validate required args
    if [[ -z "$INFERENCER" ]] || [[ -z "$INPUT" ]] || [[ -z "$OUTPUT" ]]; then
        echo "ERROR: --inferencer, --input, and --output-doc-topics required for infer-topics"
        exit 1
    fi

    # Check files exist
    if [[ ! -f "$INFERENCER" ]]; then
        echo "ERROR: Inferencer file not found: $INFERENCER"
        exit 1
    fi
    if [[ ! -f "$INPUT" ]]; then
        echo "ERROR: Input file not found: $INPUT"
        exit 1
    fi

    echo "Mock MALLET: Inferring topics"
    echo "  Inferencer: $INFERENCER"
    echo "  Input: $INPUT"
    echo "  Output: $OUTPUT"

    # Create dummy output
    cat > "$OUTPUT" << EOF
0	file:///mock/new_doc001.txt	0:0.18 2:0.14 5:0.22 8:0.11 12:0.09
1	file:///mock/new_doc002.txt	1:0.25 3:0.13 6:0.17 10:0.10 15:0.08
2	file:///mock/new_doc003.txt	2:0.21 4:0.15 7:0.14 11:0.12 18:0.07
EOF

    return 0
}

# Main command dispatcher
case "$COMMAND" in
    import-dir)
        parse_import_dir "$@"
        ;;
    train-topics)
        parse_train_topics "$@"
        ;;
    infer-topics)
        parse_infer_topics "$@"
        ;;
    --help|-h)
        cat << EOF
Mock MALLET - Testing Tool

Supported commands:
  import-dir      Import documents
  train-topics    Train topic model
  infer-topics    Infer topics on new documents

This is a mock implementation for testing scripts without MALLET installed.
EOF
        exit 0
        ;;
    *)
        echo "ERROR: Unknown MALLET command: $COMMAND"
        echo "Supported: import-dir, train-topics, infer-topics"
        exit 1
        ;;
esac

exit $?
