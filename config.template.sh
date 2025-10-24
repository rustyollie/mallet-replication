#!/bin/bash

# ============================================================================
# MALLET Topic Modeling - Configuration Template
# ============================================================================
#
# SETUP INSTRUCTIONS:
#   1. Copy this file:     cp config.template.sh config.sh
#   2. Edit config.sh with your actual paths (NOT this template)
#   3. Run the script:     ./final_mallet_2025.sh
#
# NOTES:
#   - config.sh is gitignored (your personal settings, not committed)
#   - config.template.sh is the template (committed to repository)
#   - Command-line arguments override config file settings
#   - Leave settings empty ("") to use auto-detection or defaults
#
# ============================================================================

# ============================================================================
# REQUIRED SETTINGS - You MUST configure these
# ============================================================================

# Input Directory: Where your text files are located
# - One document per file
# - Plain text format (UTF-8 recommended)
# - Example: "/Users/username/data/documents"
INPUT_DIR=""

# Output Directory: Where results will be saved
# - Will be created by the script
# - Must not already exist (script will fail if it does)
# - Example: "/Users/username/results/run_001"
OUTPUT_DIR=""

# ============================================================================
# OPTIONAL SETTINGS - Customize as needed
# ============================================================================

# Stoplist File: Words to exclude from topic modeling
# - One word per line in the file
# - Leave empty ("") to use ./default_stoplist.txt if it exists
# - Set to "NONE" to run without any stoplist
# - Example: "/Users/username/my_custom_stoplist.txt"
STOPLIST_FILE=""

# Number of Threads: CPU threads for parallel processing
# - Leave empty ("") for auto-detection (recommended)
# - Or specify a number: "48"
# - Auto-detection works on most systems
NUM_THREADS=""

# ============================================================================
# HPC/SLURM SETTINGS - Only needed if using SLURM batch system
# ============================================================================
#
# If submitting to SLURM (sbatch), you should edit the SLURM headers
# directly in the script file (final_mallet_2025.sh, lines 12-20).
#
# Key settings to customize:
#   #SBATCH --account=YOUR_ACCOUNT      # Your allocation
#   #SBATCH --partition=YOUR_PARTITION  # Your partition
#   #SBATCH --mem=500000                # Memory (MB)
#   #SBATCH --time=40:00:00             # Max runtime
#
# The config file settings below are for reference only.
# ============================================================================

# SLURM Account/Allocation
# SLURM_ACCOUNT="ucb593_asc1"

# SLURM Partition
# SLURM_PARTITION="amem"

# SLURM QOS
# SLURM_QOS="mem"

# SLURM Memory (in MB)
# SLURM_MEMORY="500000"

# SLURM Time Limit
# SLURM_TIME="40:00:00"

# SLURM Number of Tasks
# SLURM_NTASKS="48"

# ============================================================================
# INFERENCE SETTINGS - For mallet_inference.sh
# ============================================================================

# Inferencer File: Trained model from main script
# - Produced by final_mallet_2025.sh (inferencer.mallet)
# - Used by mallet_inference.sh to infer topics on new documents
# - Example: "/Users/username/results/inferencer.mallet"
INFERENCER_FILE=""

# New Documents Input: For inference on new documents
# - Can be a directory of text files OR a .mallet file
# - Example: "/Users/username/new_documents"
INFERENCE_INPUT=""

# Inference Output: Where to save inferred topic distributions
# - Will be created by mallet_inference.sh
# - Must not already exist
# - Example: "/Users/username/results/new_topics.txt"
INFERENCE_OUTPUT=""

# Random Seed for Inference: For reproducibility
# - Default is 1 (matches training seed)
# - Usually no need to change this
INFERENCE_RANDOM_SEED="1"

# ============================================================================
# MODEL PARAMETERS - DO NOT MODIFY
# ============================================================================
#
# These parameters are HARDCODED in the scripts for scientific reproducibility.
# They cannot be changed via this config file.
#
# Fixed values:
#   - Number of topics: 60
#   - Random seed: 1
#   - Optimization interval: 500
#
# Changing these would produce a different analysis and break replication.
# See README.md "Model Parameters" section for detailed explanation.
#
# ============================================================================

# ============================================================================
# EXAMPLE CONFIGURATIONS
# ============================================================================
#
# Example 1: Local machine, basic setup
# --------------------------------------
# INPUT_DIR="/Users/myname/Documents/my_corpus"
# OUTPUT_DIR="/Users/myname/Documents/results/mallet_output"
# STOPLIST_FILE=""
# NUM_THREADS=""
#
# Example 2: HPC cluster
# ----------------------
# INPUT_DIR="/pl/active/econlab/Cleaned_Nov2024"
# OUTPUT_DIR="/pl/active/econlab/results_2025"
# STOPLIST_FILE="/pl/active/econlab/scripts/custom_stoplist.txt"
# NUM_THREADS="48"
#
# Example 3: Running inference
# ----------------------------
# INFERENCER_FILE="/Users/myname/results/mallet_output/inferencer.mallet"
# INFERENCE_INPUT="/Users/myname/new_documents"
# INFERENCE_OUTPUT="/Users/myname/results/new_topics.txt"
#
# ============================================================================
