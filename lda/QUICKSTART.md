# Quick Start Guide - Server Deployment

**For experienced users who want to get running immediately.**

---

## 30-Second Setup

```bash
# 1. Upload and extract
scp mallet_replication.zip user@server:~
ssh user@server
unzip mallet_replication.zip && cd mallet_replication

# 2. Configure
cp config.template.sh config.sh
vim config.sh  # Set INPUT_DIR and OUTPUT_DIR

# 3. Run
chmod +x *.sh test/*.sh
sbatch final_mallet_2025.sh
```

Done! Monitor with: `squeue -u $USER`

---

## Essential Edits

### config.sh (Required)

```bash
INPUT_DIR="/pl/active/econlab/Cleaned_Nov2024"
OUTPUT_DIR="/pl/active/econlab/results_$(date +%Y%m%d)"
STOPLIST_FILE="/pl/active/econlab/scripts/words_to_delete.txt"
NUM_THREADS="48"
```

### final_mallet_2025.sh Lines 12-20 (SLURM Users)

```bash
#SBATCH --account=ucb593_asc1          # Change to YOUR account
#SBATCH --partition=amem                # Change to YOUR partition
#SBATCH --qos=mem                      # Change to YOUR QOS
```

---

## Common Commands

```bash
# Test (no MALLET needed)
cd test/ && ./run_tests.sh

# Preview what will run
./final_mallet_2025.sh --dry-run

# Run locally (non-SLURM)
./final_mallet_2025.sh

# Submit to SLURM
sbatch final_mallet_2025.sh

# Monitor job
squeue -u $USER
tail -f mallet_run_*.out

# Run inference
./mallet_inference.sh \
    --inferencer results/inferencer.mallet \
    --input new_docs/ \
    --output inferred.txt
```

---

## Troubleshooting One-Liners

```bash
# MALLET not found
module load jdk/1.8.0 && mallet --help

# Permission denied
chmod +x *.sh test/*.sh

# Output exists (by design - use different name)
vim config.sh  # Change OUTPUT_DIR

# Check job failure
cat mallet_run_JOBID.out

# Verify paths
ls -la $(grep INPUT_DIR config.sh | cut -d'"' -f2)
```

---

## What's Different from Original Script

| Old | New |
|-----|-----|
| Edit script for each run | Edit config.sh once |
| Hardcoded paths | Flexible config |
| `/pl/active/econlab/20281_run_mallet_out/` | Any path you want |
| Manual validation | Built-in checks |
| No testing | Full test suite |

**Same results, better workflow.**

---

## Your Original Settings

Based on your old script:

**config.sh:**
```bash
INPUT_DIR="/pl/active/econlab/Cleaned_Nov2024"
OUTPUT_DIR="/pl/active/econlab/NEW_run_mallet_$(date +%Y%m%d)"
STOPLIST_FILE="/pl/active/econlab/scripts/words_to_delete.txt"
NUM_THREADS="24"
```

**SLURM (lines 12-20):**
```bash
#SBATCH --time=40:00:00
#SBATCH --qos=mem
#SBATCH --partition=amem
#SBATCH --ntasks=48
#SBATCH --mem=500000
#SBATCH --nodes=1
#SBATCH --account=ucb593_asc1
```

**Module (line 57):**
```bash
MODULE_JAVA="jdk/1.8.0"
```

---

## Validation Checklist

- [ ] Paths in config.sh correct
- [ ] SLURM account/partition correct
- [ ] `./final_mallet_2025.sh --dry-run` looks right
- [ ] Test job on small dataset works
- [ ] Using **different** output dir than original (safety)

---

## Output Files

After successful run, check:

```bash
ls -lh $OUTPUT_DIR/

# Expected files:
# input.mallet              - Preprocessed corpus
# keys.txt                  - Topic keywords ← Check this first
# topics.txt                - Document-topic distributions ← Main output
# model.mallet              - Trained model
# inferencer.mallet         - For inference on new docs
# topic_word_weights.txt    - Distributions
# word_topic_counts.txt     - Count matrices
# diagnostics.xml           - Training stats
```

---

## Help

- Full docs: `README.md`
- Deployment: `DEPLOY.md`
- Testing: `test/README_TESTING.md`
- Built-in: `./final_mallet_2025.sh --help`

---

**Remember:** Model parameters (60 topics, seed 1) are **hardcoded** for reproducibility. Only paths and compute resources are configurable.
