# Server Deployment Guide

This guide walks you through deploying the MALLET replication scripts on your HPC server.

---

## What's in This Package

```
mallet_replication/
├── mallet_LDA.sh              Main topic modeling script
├── mallet_inference.sh        Inference on new documents
├── config.template.sh         Configuration template
├── default_stoplist.txt       Default stopword list (placeholder)
├── .gitignore                 Git ignore rules
├── README.md                  Complete documentation
├── DEPLOY.md                  This deployment guide
└── QUICKSTART.md              Quick reference card
```

---

## Prerequisites

### On Your Server:

1. **MALLET installed** and in PATH
   ```bash
   mallet --help  # Should work
   ```

2. **Java 1.8+** installed
   ```bash
   java -version  # Should show 1.8 or higher
   ```

3. **SLURM** (if using HPC batch system)
   ```bash
   sbatch --version  # Should work
   ```

4. **Your data** ready in a directory
   - One text file per document
   - Plain text format

---

## Step-by-Step Deployment

### 1. Upload to Server

```bash
# On your local machine
scp mallet_replication.zip username@server.edu:~

# SSH to server
ssh username@server.edu

# Unzip
cd ~
unzip mallet_replication.zip
cd mallet_replication
```

### 2. Make Scripts Executable

```bash
chmod +x mallet_LDA.sh
chmod +x mallet_inference.sh
```

### 3. Verify MALLET Works

```bash
# Check MALLET is available
which mallet
mallet --help

# If MALLET not found, load module:
module avail mallet  # Or java/jdk
module load jdk/1.8.0
```

### 4. Configure for Your Setup

#### A. Create Your Config File

```bash
cp config.template.sh config.sh
```

#### B. Edit Config with Your Paths

```bash
vim config.sh  # or nano, emacs, etc.
```

**Required settings:**
```bash
# YOUR INPUT DATA
INPUT_DIR="/path/to/your/documents"

# WHERE YOU WANT OUTPUT
OUTPUT_DIR="/path/to/your/results/run_$(date +%Y%m%d)"

# YOUR STOPLIST (or leave empty for default)
STOPLIST_FILE="/path/to/your/words_to_delete.txt"

# CPU THREADS (or leave empty for auto-detect)
NUM_THREADS="24"
```

**Example for your original setup:**
```bash
INPUT_DIR="/pl/active/econlab/Cleaned_Nov2024"
OUTPUT_DIR="/pl/active/econlab/test_new_framework_$(date +%Y%m%d)"
STOPLIST_FILE="/pl/active/econlab/scripts/words_to_delete.txt"
NUM_THREADS="24"
```

#### C. Edit SLURM Headers (HPC Users)

```bash
vim mallet_LDA.sh
```

Edit lines 12-20:
```bash
#SBATCH --account=YOUR_ACCOUNT         # Line 20: YOUR allocation
#SBATCH --partition=YOUR_PARTITION     # Line 14: YOUR partition
#SBATCH --qos=YOUR_QOS                 # Line 13: YOUR QOS
#SBATCH --mem=500000                   # Adjust as needed
#SBATCH --time=40:00:00                # Adjust as needed
```

**Example for your original setup:**
```bash
#SBATCH --account=ucb593_asc1
#SBATCH --partition=amem
#SBATCH --qos=mem
#SBATCH --mem=500000
#SBATCH --time=40:00:00
```

### 5. Test the Configuration

Use dry-run to preview commands without executing:

```bash
./mallet_LDA.sh --dry-run
```

Review the output carefully:
- Are the paths correct?
- Do the MALLET commands look right?
- Are parameters what you expect?

### 6. Test on Small Dataset (Recommended)

Create a small subset of your data:

```bash
# Create test subset directory
mkdir -p ~/mallet_test_subset

# Copy first 100 documents (adjust path as needed)
cp /pl/active/econlab/Cleaned_Nov2024/doc{001..100}.txt ~/mallet_test_subset/

# Edit config for test
vim config.sh
# Temporarily set:
#   INPUT_DIR="$HOME/mallet_test_subset"
#   OUTPUT_DIR="$HOME/mallet_test_output"

# Run test
./mallet_LDA.sh

# Or submit to SLURM
sbatch mallet_LDA.sh
```

**Verify test results:**
```bash
ls -lh ~/mallet_test_output/
cat ~/mallet_test_output/keys.txt | head -10
```

If successful, you're ready for the full run!

### 7. Run Full Analysis

#### A. Update Config for Full Run

```bash
vim config.sh
```

Restore full paths:
```bash
INPUT_DIR="/pl/active/econlab/Cleaned_Nov2024"
OUTPUT_DIR="/pl/active/econlab/production_run_$(date +%Y%m%d)"
STOPLIST_FILE="/pl/active/econlab/scripts/words_to_delete.txt"
NUM_THREADS="48"
```

#### B. Submit Job

```bash
# Submit to SLURM
sbatch mallet_LDA.sh

# Note the job ID
# Output: Submitted batch job 12345678
```

#### C. Monitor Job

```bash
# Check status
squeue -u $USER

# Watch output file
tail -f mallet_run_12345678.out

# Check detailed status
scontrol show job 12345678
```

---

## Troubleshooting Common Issues

### Issue: "mallet: command not found"

**Solution 1:** Load module
```bash
module avail java
module load jdk/1.8.0
```

**Solution 2:** Add MALLET to PATH
```bash
export PATH=/path/to/mallet/bin:$PATH
# Add to ~/.bashrc for persistence
```

### Issue: "Input directory does not exist"

**Check:**
```bash
ls -la /pl/active/econlab/Cleaned_Nov2024/
```

**Fix:** Update INPUT_DIR in config.sh to correct path

### Issue: "Output directory already exists"

**This is by design!** The script prevents accidental overwrites.

**Solution:**
```bash
# Option 1: Remove old output
rm -rf /path/to/output

# Option 2: Use different output directory
vim config.sh  # Change OUTPUT_DIR to new path
```

### Issue: SLURM job fails to submit

**Check:**
```bash
# Verify account
sacctmgr show user $USER

# Verify partition
sinfo

# Test SLURM headers
sbatch --test-only mallet_LDA.sh
```

**Fix:** Edit SLURM headers in mallet_LDA.sh (lines 12-20)

### Issue: Job runs but produces no output

**Check SLURM output file:**
```bash
cat mallet_run_JOBID.out
```

**Common causes:**
- Wrong input path (no files found)
- Module loading failed
- Memory limit exceeded
- Time limit exceeded

### Issue: "Permission denied"

```bash
# Make scripts executable
chmod +x *.sh
chmod +x test/*.sh

# Check data access
ls -la /pl/active/econlab/Cleaned_Nov2024/
```

---

## Comparing with Original Script

### What's Different:

| Aspect | Original Script | New Framework |
|--------|----------------|---------------|
| Configuration | Hardcoded in script | config.sh file |
| Paths | Edit script each time | Edit config once |
| Output naming | Hardcoded date | Flexible naming |
| Testing | Need MALLET | Dry-run available |
| Documentation | Minimal | Comprehensive |
| Validation | None | Extensive checks |
| Error messages | Cryptic | Clear and helpful |

### What's the Same:

- ✅ Model parameters (60 topics, seed 1, optimize 500)
- ✅ MALLET commands (same structure)
- ✅ Output files (same format)
- ✅ SLURM submission (same process)
- ✅ Results (should be identical)

### Migration Checklist:

- [ ] Paths from old script transferred to config.sh
- [ ] SLURM settings match old script
- [ ] Stoplist file accessible
- [ ] Module loading works
- [ ] Dry-run looks correct
- [ ] Test on small dataset successful
- [ ] Old results preserved (using different output dir)

---

## Validation Workflow

### Compare Old vs New Results:

```bash
# If you have old results
OLD_OUTPUT="/pl/active/econlab/20281_run_mallet_out"
NEW_OUTPUT="/pl/active/econlab/test_new_framework_20250125"

# Compare key files
echo "Comparing keys.txt:"
diff <(head -20 $OLD_OUTPUT/keys.txt) <(head -20 $NEW_OUTPUT/keys.txt)

echo "Comparing file counts:"
ls $OLD_OUTPUT/*.txt | wc -l
ls $NEW_OUTPUT/*.txt | wc -l

echo "Comparing file sizes:"
ls -lh $OLD_OUTPUT/
ls -lh $NEW_OUTPUT/
```

**Expected:** Should be nearly identical (minor path differences OK)

---

## Post-Deployment

### For Future Runs:

```bash
# Just edit config and run
vim config.sh  # Update OUTPUT_DIR or other settings
sbatch mallet_LDA.sh
```

### For Inference on New Documents:

```bash
# Edit config.sh with inference settings
vim config.sh
# Set:
#   INFERENCER_FILE="/path/to/results/inferencer.mallet"
#   INFERENCE_INPUT="/path/to/new/documents"
#   INFERENCE_OUTPUT="/path/to/inferred_topics.txt"

# Run inference
./mallet_inference.sh

# Or submit to SLURM
sbatch mallet_inference.sh
```

### Keep Updated:

```bash
# Periodically check for updates
cd ~/mallet_replication
git pull  # If using git

# Re-run tests to verify everything still works
cd test/
./run_tests.sh
```

---

## Getting Help

1. **Check documentation:**
   - `README.md` - Complete documentation
   - `QUICKSTART.md` - Quick reference

2. **Run help:**
   ```bash
   ./mallet_LDA.sh --help
   ./mallet_inference.sh --help
   ```

3. **Check SLURM output:**
   ```bash
   cat mallet_run_JOBID.out
   ```

---

## Success Checklist

Before considering deployment complete:

- [ ] Dry-run looks correct (`./mallet_LDA.sh --dry-run`)
- [ ] Small dataset test successful
- [ ] Full run submitted successfully
- [ ] Output files created as expected
- [ ] Results validated (if comparing to old script)
- [ ] config.sh documented for future reference
- [ ] Old script archived (not deleted)

---

## Quick Reference

```bash
# Setup (once)
unzip mallet_replication.zip
cd mallet_replication
chmod +x *.sh
cp config.template.sh config.sh
vim config.sh  # Edit paths
vim mallet_LDA.sh  # Edit SLURM headers

# Test
./mallet_LDA.sh --dry-run

# Run
sbatch mallet_LDA.sh

# Monitor
squeue -u $USER
tail -f mallet_run_*.out

# Results
ls -lh /path/to/output/
```

---

**You're all set! The framework is designed to be safer, clearer, and more maintainable than the original script while producing identical results.**

For questions, check README.md or run `./mallet_LDA.sh --help`
