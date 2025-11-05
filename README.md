# MALLET Topic Modeling - Replication Scripts

This repository contains scripts for exact replication of topic modeling analysis using MALLET (MAchine Learning for LanguagE Toolkit).

---

## ⚠️ Official Repository

**This is a development/backup repository. The official version is maintained as part of the complete QJE replication package:**

**Official Repository:** [austinkennedy/AIKR_QJE_Replication](https://github.com/austinkennedy/AIKR_QJE_Replication)

The official repository includes:
- **LDA Topic Modeling** (`lda/` directory) - This MALLET package
- **Final Analysis** (`final_analysis/` directory) - Python analysis producing 53 figures and 3 tables

For the complete replication package for the paper "Enlightenment Ideals and Beliefs in Progress in the Run-up to the Industrial Revolution: A Textual Analysis" by Ali Almelhem, Murat Iyigun, Austin Kennedy, and Jared Rubin, please use the official repository above.

---

## Complete Replication Pipeline

This repository provides the **complete three-stage pipeline** from initial HTRC workset to final topic model. For the complete analysis pipeline including figure generation, see the official repository.

### Pipeline Overview

```
HTRC Workset → [Get Unique Volumes] → Volume List → [Download] →
.json.bz2 Files → [Preprocessing] → Clean Text → [MALLET LDA] → Topic Model
```

### Three-Stage Process

**Stage 1: Get Unique Volumes** (Volume deduplication)
```bash
cd "Get Unique Volumes/"
jupyter notebook "Get Unique Volumes for Rsync.ipynb"
```

Deduplicates the initial HTRC workset (383K → 265K volumes), intelligently selecting complete serial sets. Outputs a list of unique volume IDs for download.

See [`Get Unique Volumes/README.md`](Get%20Unique%20Volumes/README.md) for detailed documentation.

**Stage 2: Text Preprocessing** (Clean HTRC data)
```bash
cd Preprocessing/
python preprocess_htrc.py --config config.sh
```

Converts HTRC Extracted Features files (`.json.bz2`) to cleaned text files (`.txt`). Applies 9-step pipeline including lemmatization, stopword removal, and modernization.

See [`Preprocessing/README.md`](Preprocessing/README.md) for detailed preprocessing documentation.

**Stage 3: Topic Modeling** (Train MALLET model)
```bash
cd LDA/
./mallet_LDA.sh --input-dir ./data --output-dir ./results
```

Trains MALLET LDA topic model (60 topics) on cleaned text. Produces document-topic distributions for analysis.

See [`LDA/README.md`](LDA/README.md) for detailed MALLET documentation.

### Starting Point

You can start from any stage depending on your data:
- **HTRC workset CSV** → Run all three stages (complete pipeline)
- **Downloaded .json.bz2 files** → Skip Stage 1, run Stages 2-3
- **Pre-cleaned text files** → Skip Stages 1-2, run Stage 3 only

---

## Purpose

These scripts are designed for **exact replication** of published research results. Model parameters are intentionally hardcoded to ensure identical results across different computing environments.

## What's Included

### Stage 1: Get Unique Volumes
- `Get Unique Volumes/` - Volume deduplication pipeline
  - `Get Unique Volumes for Rsync.ipynb` - Production deduplication notebook
  - `Get Unique Volumes.ipynb` - Original Jupyter notebook (reference)
  - See [`Get Unique Volumes/README.md`](Get%20Unique%20Volumes/README.md) for details

### Stage 2: Text Preprocessing
- `Preprocessing/` - HTRC text preprocessing pipeline
  - `preprocess_htrc.py` - Main preprocessing script
  - `reference_data/` - Required dictionary files
  - See [`Preprocessing/README.md`](Preprocessing/README.md) for details

### Stage 3: MALLET Topic Modeling
- `LDA/` - MALLET topic modeling
  - `mallet_LDA.sh` - Main topic modeling script
  - `mallet_inference.sh` - Apply trained model to new documents
  - `default_stoplist.txt` - Default stopword list (template)
  - See [`LDA/README.md`](LDA/README.md) for details

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
chmod +x mallet_LDA.sh mallet_inference.sh
```

### 4. Run the Script

**Using config file (recommended):**
```bash
./mallet_LDA.sh
```

**Or using command-line arguments:**
```bash
./mallet_LDA.sh \
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

Edit `mallet_LDA.sh` (lines 12-20) to match your HPC environment:

```bash
#SBATCH --account=YOUR_ACCOUNT         # Your allocation
#SBATCH --partition=YOUR_PARTITION     # Your partition
#SBATCH --mem=500000                   # Adjust memory as needed
#SBATCH --time=40:00:00                # Adjust time limit
```

### 3. Submit Job

**Using config file (recommended):**
```bash
sbatch mallet_LDA.sh
```

**Or override config with CLI arguments:**
```bash
sbatch mallet_LDA.sh \
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
./mallet_LDA.sh
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
./mallet_LDA.sh

# This overrides to use corpus2 instead
./mallet_LDA.sh --input-dir /data/corpus2
```

### Key Settings

**Main Script (`mallet_LDA.sh`):**
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
./mallet_LDA.sh --input-dir ./data --output-dir ./results
```

**Custom stoplist:**
```bash
./mallet_LDA.sh \
    --input-dir ./data \
    --output-dir ./results \
    --stoplist ./my_stoplist.txt
```

**Specify threads:**
```bash
./mallet_LDA.sh \
    --input-dir ./data \
    --output-dir ./results \
    --num-threads 32
```

**Preview without running:**
```bash
./mallet_LDA.sh \
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
./mallet_LDA.sh \
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


### Fixed Parameters

| Parameter | Value | Why Fixed? |
|-----------|-------|-----------|
| `num-topics` | 60 | Fundamental model structure |
| `random-seed` | 1 | Ensures identical initialization |
| `optimize-interval` | 500 | Affects convergence behavior |


### Configurable Parameters

| Parameter | Configurable? | Why? |
|-----------|---------------|------|
| Input/output paths | ✓ | System-dependent |
| CPU threads | ✓ | Hardware-dependent |
| Memory allocation | ✓ | System-dependent |
| SLURM settings | ✓ | Cluster-dependent |
| Stoplist path | ✓ | User preference |

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
./mallet_LDA.sh \
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
chmod +x mallet_LDA.sh
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
./mallet_LDA.sh --input-dir ./data --output-dir ./results
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
./mallet_LDA.sh --input-dir ./data --output-dir ./results
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

### Testing on Small Dataset

Use `--dry-run` to preview commands without executing:

```bash
./mallet_LDA.sh \
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

---

## Support

For issues or questions:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Ensure MALLET is properly installed: `mallet --help`
3. Try `--dry-run` to preview commands: `./mallet_LDA.sh ... --dry-run`
4. Review the script's help: `./mallet_LDA.sh --help`
5. Check MALLET documentation: http://mallet.cs.umass.edu/

---

## File Structure

```
.
├── mallet_LDA.sh              Main topic modeling script
├── mallet_inference.sh        Apply model to new documents
├── config.template.sh         Configuration template (commit this)
├── config.sh                  Your configuration (gitignored)
├── default_stoplist.txt       Default stopword list (template)
├── .gitignore                 Git ignore rules
└── README.md                  This documentation
```

**Files to commit to git:**
- `mallet_LDA.sh`, `mallet_inference.sh` (scripts)
- `config.template.sh` (template, NOT `config.sh`)
- `default_stoplist.txt` (or your custom stoplist)
- `README.md`, `.gitignore` (documentation)

**Files ignored by git:**
- `config.sh` (personal settings)
- `*.mallet` (binary output files)
- `results/`, `*_output/` (output directories)
- `*.out` (SLURM output files)

---

## References

- **MALLET Documentation:** http://mallet.cs.umass.edu/
- **Topic Modeling Tutorial:** http://mallet.cs.umass.edu/topics.php
- **MALLET Download:** http://mallet.cs.umass.edu/download.php

---

## License

[To be determined]

---

## Acknowledgments

This analysis uses MALLET (MAchine Learning for LanguagE Toolkit) developed by Andrew McCallum.

**Citation for MALLET:**
> McCallum, Andrew Kachites. "MALLET: A Machine Learning for Language Toolkit."
> http://mallet.cs.umass.edu. 2002.
