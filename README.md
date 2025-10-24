# MALLET Topic Modeling - Replication Scripts

This repository contains scripts for exact replication of topic modeling analysis using MALLET (MAchine Learning for LanguagE Toolkit).

## Purpose

These scripts are designed for **exact replication** of published research results. Model parameters are intentionally hardcoded to ensure identical results across different computing environments.

## What's Included

- `final_mallet_2025.sh` - Main topic modeling script
- `mallet_inference.sh` - Apply trained model to new documents
- `default_stoplist.txt` - Default stopword list (template)
- `README.md` - This documentation

---

## Table of Contents

1. [Requirements](#requirements)
2. [Quick Start (Local Machine)](#quick-start-local-machine)
3. [HPC/SLURM Usage](#hpcslurm-usage)
4. [Command-Line Reference](#command-line-reference)
5. [Output Files](#output-files)
6. [Inference on New Documents](#inference-on-new-documents)
7. [Model Parameters](#model-parameters)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Topics](#advanced-topics)

---

## Requirements

### 1. MALLET

Download and install MALLET from http://mallet.cs.umass.edu/

**Installation:**

```bash
# Download
wget http://mallet.cs.umass.edu/dist/mallet-2.0.8.tar.gz
tar -xzf mallet-2.0.8.tar.gz

# Add to PATH (add to ~/.bashrc for persistence)
export PATH=/path/to/mallet-2.0.8/bin:$PATH

# Test installation
mallet --help
```

### 2. Java

MALLET requires Java 1.8 or higher.

```bash
# Check version
java -version  # Should show 1.8+

# Install on Ubuntu/Debian
sudo apt-get install openjdk-8-jdk

# Install on CentOS/RHEL
sudo yum install java-1.8.0-openjdk

# Install on macOS (with Homebrew)
brew install openjdk@8
```

### 3. Bash

Requires Bash 4.0+ (standard on modern Linux/macOS systems).

```bash
# Check version
bash --version
```

---

## Quick Start (Local Machine)

### 1. Prepare Your Data

- Place all text files in a directory
- One document per file
- Plain text format (UTF-8 recommended)

Example structure:
```
my_documents/
├── doc001.txt
├── doc002.txt
└── doc003.txt
```

### 2. Set Up Configuration (Recommended)

```bash
# Copy the template
cp config.template.sh config.sh

# Edit with your paths
vim config.sh  # or nano, emacs, etc.
```

Edit these required fields in `config.sh`:
```bash
INPUT_DIR="/path/to/your/my_documents"
OUTPUT_DIR="/path/to/your/results"
```

### 3. Make Scripts Executable

```bash
chmod +x final_mallet_2025.sh mallet_inference.sh
```

### 4. Run the Script

**Using config file (recommended):**
```bash
./final_mallet_2025.sh
```

**Or using command-line arguments:**
```bash
./final_mallet_2025.sh \
    --input-dir ./my_documents \
    --output-dir ./results
```

### 5. View Results

Results are saved in your output directory (e.g., `./results/`):
- `keys.txt` - Topic keywords (human-readable topic descriptions)
- `topics.txt` - Document-topic distributions (main output)
- `model.mallet` - Trained model (for later use)
- `inferencer.mallet` - For applying model to new documents

---

## HPC/SLURM Usage

### 1. Set Up Configuration

```bash
# Copy and edit config file
cp config.template.sh config.sh
vim config.sh
```

Edit `config.sh` with your HPC paths:
```bash
INPUT_DIR="/pl/active/your_lab/data"
OUTPUT_DIR="/pl/active/your_lab/results"
NUM_THREADS="48"  # Or leave empty for auto-detect
```

### 2. Customize SLURM Headers

Edit `final_mallet_2025.sh` (lines 12-20) to match your HPC environment:

```bash
#SBATCH --account=YOUR_ACCOUNT         # Your allocation
#SBATCH --partition=YOUR_PARTITION     # Your partition
#SBATCH --mem=500000                   # Adjust memory as needed
#SBATCH --time=40:00:00                # Adjust time limit
```

### 3. Submit Job

**Using config file (recommended):**
```bash
sbatch final_mallet_2025.sh
```

**Or override config with CLI arguments:**
```bash
sbatch final_mallet_2025.sh \
    --output-dir /pl/active/your_lab/special_run \
    --num-threads 64
```

### 4. Monitor Job

```bash
# Check job status
squeue -u $USER

# Watch output file
tail -f mallet_run_JOBID.out

# Check completed job
sacct -j JOBID --format=JobID,JobName,Elapsed,State,ExitCode
```

---

## Configuration File

### Overview

The recommended way to use these scripts is with a configuration file. This approach:
- **Simplifies repeated runs** - Set paths once, run many times
- **Documents your setup** - Config file serves as methods documentation
- **Enables version control** - Commit config to track analysis parameters
- **Reduces errors** - No typos in repeated command-line arguments

### Setup

```bash
# 1. Copy the template
cp config.template.sh config.sh

# 2. Edit with your settings
vim config.sh  # Use your preferred editor

# 3. Run (config file is used automatically)
./final_mallet_2025.sh
```

### Configuration Precedence

Settings are applied in this order (later overrides earlier):
1. **Script defaults** (lowest priority)
2. **Config file** (`config.sh`) - Your standard settings
3. **Command-line arguments** (highest priority) - Override for specific runs

Example:
```bash
# config.sh has: INPUT_DIR="/data/corpus1"

# This uses corpus1 from config.sh
./final_mallet_2025.sh

# This overrides to use corpus2 instead
./final_mallet_2025.sh --input-dir /data/corpus2
```

### Key Settings

**Main Script (`final_mallet_2025.sh`):**
```bash
INPUT_DIR="/path/to/input/documents"     # Required
OUTPUT_DIR="/path/to/output/results"     # Required
STOPLIST_FILE="/path/to/stoplist.txt"    # Optional (uses default if empty)
NUM_THREADS="48"                         # Optional (auto-detects if empty)
```

**Inference Script (`mallet_inference.sh`):**
```bash
INFERENCER_FILE="/path/to/inferencer.mallet"  # Required
INFERENCE_INPUT="/path/to/new_documents"       # Required
INFERENCE_OUTPUT="/path/to/output.txt"         # Required
INFERENCE_RANDOM_SEED="1"                      # Optional (default: 1)
```

### Version Control Best Practices

The `.gitignore` file is configured to:
- ✅ **Commit** `config.template.sh` (template for others)
- ❌ **Ignore** `config.sh` (your personal settings)
- ❌ **Ignore** output files (large binary files)

To share your configuration:
```bash
# Don't commit config.sh directly
# Instead, document your settings in your README or methods section
```

For reproducibility, document your `config.sh` settings in your paper's methods section or supplementary materials.

---

## Command-Line Reference

### Required Arguments

| Argument | Description |
|----------|-------------|
| `--input-dir <path>` | Directory containing input text files |
| `--output-dir <path>` | Directory where output files will be created (must not exist) |

### Optional Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--stoplist <path>` | Custom stoplist file | `./default_stoplist.txt` if exists |
| `--num-threads <n>` | Number of threads | Auto-detect |
| `--dry-run` | Preview commands without executing | Off |
| `--help, -h` | Show help message | - |

### Examples

**Basic usage:**
```bash
./final_mallet_2025.sh --input-dir ./data --output-dir ./results
```

**Custom stoplist:**
```bash
./final_mallet_2025.sh \
    --input-dir ./data \
    --output-dir ./results \
    --stoplist ./my_stoplist.txt
```

**Specify threads:**
```bash
./final_mallet_2025.sh \
    --input-dir ./data \
    --output-dir ./results \
    --num-threads 32
```

**Preview without running:**
```bash
./final_mallet_2025.sh \
    --input-dir ./data \
    --output-dir ./results \
    --dry-run
```

---

## Output Files

The script produces the following files in the output directory:

| File | Description |
|------|-------------|
| `input.mallet` | Preprocessed corpus in MALLET format |
| `keys.txt` | Topic keywords (most probable words per topic) |
| `model.mallet` | Trained topic model (binary format) |
| `topic_word_weights.txt` | Word-topic probability distributions |
| `word_topic_counts.txt` | Raw count matrices |
| `topics.txt` | **Document-topic distributions (main output)** |
| `inferencer.mallet` | Model for inferring topics in new documents |
| `diagnostics.xml` | Training diagnostics and statistics |

### Understanding Key Output Files

#### keys.txt - Human-readable topic descriptions

Format:
```
0  0.12345  word1 word2 word3 word4 word5 ...
1  0.23456  word1 word2 word3 word4 word5 ...
```

- **Column 1:** Topic ID (0-59)
- **Column 2:** Topic weight (Dirichlet parameter)
- **Columns 3+:** Top words for this topic (ranked by probability)

#### topics.txt - Document-topic distributions

Format:
```
0  file:///path/to/doc001.txt  0:0.15 1:0.05 2:0.30 ...
1  file:///path/to/doc002.txt  0:0.08 1:0.22 2:0.12 ...
```

- **Column 1:** Document ID
- **Column 2:** Document path/name
- **Columns 3+:** Topic:Proportion pairs (only non-zero proportions shown)

This is the **primary output** for analysis - it shows which topics are present in each document and their relative weights.

---

## Inference on New Documents

Use `mallet_inference.sh` to apply the trained model to new documents.

### Setup

```bash
chmod +x mallet_inference.sh
```

### Usage

```bash
./mallet_inference.sh \
    --inferencer ./results/inferencer.mallet \
    --input ./new_documents \
    --output ./new_topics.txt
```

### Arguments

| Argument | Description |
|----------|-------------|
| `--inferencer <path>` | Trained inferencer.mallet file (from main script) |
| `--input <path>` | New documents (directory or .mallet file) |
| `--output <path>` | Output file for inferred topic distributions (will be created) |
| `--random-seed <n>` | Random seed (default: 1) |
| `--help, -h` | Show help message |

### Example Workflow

```bash
# Step 1: Train model on corpus
./final_mallet_2025.sh \
    --input-dir ./training_data \
    --output-dir ./model_output

# Step 2: Apply to new documents
./mallet_inference.sh \
    --inferencer ./model_output/inferencer.mallet \
    --input ./new_documents \
    --output ./new_topics.txt
```

### Output Format

The output file contains document-topic distributions for the new documents, in the same format as `topics.txt` from the main script.

---

## Model Parameters (Hardcoded for Replication)

This script is designed for **exact replication** of published research.

### Fixed Parameters

| Parameter | Value | Why Fixed? |
|-----------|-------|-----------|
| `num-topics` | 60 | Fundamental model structure |
| `random-seed` | 1 | Ensures identical initialization |
| `optimize-interval` | 500 | Affects convergence behavior |

### Why Are These Hardcoded?

Changing these parameters produces a **fundamentally different topic model**:

- **Different number of topics** → different topic structure and interpretations
- **Different random seed** → different initialization → different final results
- **Different optimization** → different hyperparameters → different distributions

For **replication**, these must remain fixed so that:
1. Multiple users get identical results
2. Results can be compared to published analysis
3. Science is reproducible

### Configurable Parameters

These adapt to your computing environment **without affecting results**:

| Parameter | Configurable? | Why? |
|-----------|---------------|------|
| Input/output paths | ✓ | System-dependent |
| CPU threads | ✓ | Hardware-dependent |
| Memory allocation | ✓ | System-dependent |
| SLURM settings | ✓ | Cluster-dependent |
| Stoplist path | ✓ | User preference |

### Running Different Analyses

If you want to explore different model configurations:
1. Create a copy of the script
2. Clearly label it as exploratory (not replication)
3. Document all parameter changes
4. **Do not call it a replication**

---

## Troubleshooting

### "mallet: command not found"

**Problem:** MALLET is not installed or not in PATH.

**Solution:**
```bash
# Install MALLET
wget http://mallet.cs.umass.edu/dist/mallet-2.0.8.tar.gz
tar -xzf mallet-2.0.8.tar.gz

# Add to PATH
export PATH=/path/to/mallet-2.0.8/bin:$PATH

# Make permanent (add to ~/.bashrc or ~/.bash_profile)
echo 'export PATH=/path/to/mallet-2.0.8/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Test
mallet --help
```

### "Output directory already exists"

**Problem:** Output directory from previous run exists.

**Solution:**
```bash
# Option 1: Remove old results
rm -rf ./results

# Option 2: Use different output directory
./final_mallet_2025.sh \
    --input-dir ./data \
    --output-dir ./results_v2
```

### "Input directory is empty"

**Problem:** No text files in input directory.

**Solution:**
- Check that files are in the correct directory: `ls -la ./my_documents`
- Ensure files are plain text (not .doc, .pdf, etc.)
- Check file permissions: `ls -l ./my_documents`
- Verify files have content: `head ./my_documents/doc001.txt`

### "Permission denied"

**Problem:** Script is not executable.

**Solution:**
```bash
chmod +x final_mallet_2025.sh
chmod +x mallet_inference.sh
```

### Out of Memory Errors

**Problem:** Insufficient memory for large corpus.

**Solution:**

For HPC: Increase memory in SLURM headers
```bash
#SBATCH --mem=500000  # Increase this value (in MB)
```

For local machine: Increase Java heap size
```bash
# Set MALLET memory before running
export MALLET_MEMORY=8g
./final_mallet_2025.sh --input-dir ./data --output-dir ./results
```

### Module Load Errors (HPC)

**Problem:** Java module not available on your cluster.

**Solution:**
```bash
# Find available Java modules
module avail java
module avail jdk

# Edit script (line 57) to use correct module name
MODULE_JAVA="java/11"  # Or whatever is available

# Or load manually before running
module load java/11
./final_mallet_2025.sh --input-dir ./data --output-dir ./results
```

### Very Slow Training

**Problem:** Topic training is taking too long.

**Possible causes and solutions:**
1. **Large corpus:** This is expected. Check progress in output file.
2. **Too few threads:** Specify more threads: `--num-threads 48`
3. **Slow disk I/O:** Move data to faster storage (local SSD vs network)
4. **Insufficient RAM:** Increase memory allocation (see above)

### Empty Output Files

**Problem:** Output files are created but empty or incomplete.

**Solution:**
1. Check the log output for errors
2. Verify input files have content: `head ./my_documents/*`
3. Check disk space: `df -h`
4. Review MALLET error messages in output

---

## Advanced Topics

### Custom Stoplist

Create a custom stoplist file with one word per line:

```
the
a
an
is
are
was
were
```

Use it:
```bash
./final_mallet_2025.sh \
    --input-dir ./data \
    --output-dir ./results \
    --stoplist ./custom_stoplist.txt
```

**Tip:** The `default_stoplist.txt` provided is a template. Replace it with your actual project-specific stoplist.

### Testing on Small Dataset

Use `--dry-run` to preview commands without executing:

```bash
./final_mallet_2025.sh \
    --input-dir ./data \
    --output-dir ./results \
    --dry-run
```

This shows exactly what will be executed without actually running the analysis. Useful for:
- Verifying paths are correct
- Checking MALLET command syntax
- Testing configuration before long runs

### Monitoring Long-Running Jobs

For large datasets, monitor progress:

**On local machine:**
```bash
# Watch output in real-time
tail -f mallet_run_*.out

# Check process
ps aux | grep mallet

# Monitor system resources
htop
```

**On HPC:**
```bash
# Check job status
squeue -u $USER

# View output
tail -f mallet_run_JOBID.out

# Check node resources
scontrol show job JOBID
```

### Analyzing Results

After training, you can analyze the results using various tools:

**Python example:**
```python
import pandas as pd

# Load document-topic distributions
topics = pd.read_csv('results/topics.txt',
                     sep='\t',
                     skiprows=0,
                     header=None)

# Parse topic proportions
# (Custom parsing needed based on format)
```

**R example:**
```r
# Load topic keys
keys <- read.table('results/keys.txt',
                   sep='\t',
                   header=FALSE)

# Examine top words for each topic
head(keys)
```

### Batch Processing Multiple Corpora

To process multiple datasets:

```bash
#!/bin/bash

# Process multiple corpora
for corpus in corpus1 corpus2 corpus3; do
    echo "Processing $corpus..."
    ./final_mallet_2025.sh \
        --input-dir ./data/$corpus \
        --output-dir ./results/$corpus
done
```

---

## Testing

### Running Tests Without MALLET

The project includes a comprehensive test suite that works **without requiring MALLET installation**:

```bash
cd test/
./run_tests.sh
```

**What gets tested:**
- ✅ Configuration file loading
- ✅ CLI argument parsing
- ✅ Precedence (config vs CLI)
- ✅ Input/output validation
- ✅ Error handling
- ✅ Output file creation
- ✅ Inference script
- ✅ Model parameter immutability
- ✅ Dry-run mode
- ✅ Help text completeness

**Test results:**
```
Total tests run:    12
Tests passed:       32 assertions
Tests failed:       0
✓ ALL TESTS PASSED
```

The test suite uses a mock MALLET implementation, making it perfect for:
- Development and debugging
- Continuous Integration (CI/CD)
- Verifying script functionality
- Testing without large datasets

See `test/README_TESTING.md` for detailed testing documentation.

---

## Support

For issues or questions:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Ensure MALLET is properly installed: `mallet --help`
3. Try `--dry-run` to preview commands: `./final_mallet_2025.sh ... --dry-run`
4. Review the script's help: `./final_mallet_2025.sh --help`
5. Check MALLET documentation: http://mallet.cs.umass.edu/

---

## File Structure

```
.
├── final_mallet_2025.sh       Main topic modeling script
├── mallet_inference.sh        Apply model to new documents
├── config.template.sh         Configuration template (commit this)
├── config.sh                  Your configuration (gitignored)
├── default_stoplist.txt       Default stopword list (template)
├── .gitignore                 Git ignore rules
├── README.md                  This documentation
└── test/                      Testing suite (no MALLET required)
    ├── mock_mallet.sh         Mock MALLET for testing
    ├── run_tests.sh           Comprehensive test suite
    └── README_TESTING.md      Testing documentation
```

**Files to commit to git:**
- `final_mallet_2025.sh`, `mallet_inference.sh` (scripts)
- `config.template.sh` (template, NOT `config.sh`)
- `default_stoplist.txt` (or your custom stoplist)
- `README.md`, `.gitignore` (documentation)
- `test/` directory (all test files)

**Files ignored by git:**
- `config.sh` (personal settings)
- `*.mallet` (binary output files)
- `results/`, `*_output/` (output directories)
- `*.out` (SLURM output files)
- `test/test_workspace/` (test artifacts)

---

## References

- **MALLET Documentation:** http://mallet.cs.umass.edu/
- **Topic Modeling Tutorial:** http://mallet.cs.umass.edu/topics.php
- **MALLET Download:** http://mallet.cs.umass.edu/download.php

---

## Version History

- **v2.0** (2025-10-25): Complete refactor for plug-and-play usage
  - Command-line argument interface
  - Comprehensive validation and error handling
  - Self-documenting help system
  - Support for both local and HPC environments
  - Separate inference script

- **v1.0**: Original HPC-specific script

---

## License

[To be determined]

---

## Acknowledgments

This analysis uses MALLET (MAchine Learning for LanguagE Toolkit) developed by Andrew McCallum.

**Citation for MALLET:**
> McCallum, Andrew Kachites. "MALLET: A Machine Learning for Language Toolkit."
> http://mallet.cs.umass.edu. 2002.
