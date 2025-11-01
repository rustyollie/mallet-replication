# Quick Start - HTRC Preprocessing

**For experienced users who want to get running immediately.**

---

## 30-Second Setup

```bash
# 1. Navigate to Preprocessing directory
cd Preprocessing/

# 2. Configure
cp config.template.sh config.sh
vim config.sh  # Set INPUT_DIR and OUTPUT_DIR

# 3. Install dependencies (first time only)
pip install pandas numpy tqdm htrc-features nltk pycountry
python -m nltk.downloader words names stopwords wordnet

# 4. Run
python preprocess_htrc.py --config config.sh
```

Done! Cleaned text files will be in your OUTPUT_DIR.

---

## Essential Edits

### config.sh (Required)

```bash
# REQUIRED: Set these paths
INPUT_DIR="/path/to/htrc_extracted_features"
OUTPUT_DIR="/path/to/cleaned_output"

# Optional: Dictionary paths (defaults work if running from Preprocessing/)
DICT_CORRECTIONS="./reference_data/Master_Corrections.csv"
DICT_MA="./reference_data/MA_Dict_Final.csv"
WORLD_CITIES="./reference_data/world_cities.csv"

# Optional: CPU processes (leave empty for auto-detect)
NUM_PROCESSES=""
```

---

## Common Commands

```bash
# Preview what will happen
python preprocess_htrc.py --config config.sh --dry-run

# Run preprocessing
python preprocess_htrc.py --config config.sh

# Override output directory
python preprocess_htrc.py --config config.sh --output /different/path

# Specify CPU processes
python preprocess_htrc.py --config config.sh --num-processes 8

# Verbose output
python preprocess_htrc.py --config config.sh --verbose

# Get help
python preprocess_htrc.py --help
```

---

## Next Step: MALLET Topic Modeling

After preprocessing completes:

```bash
# Go to parent directory
cd ..

# Configure MALLET
cp config.template.sh config.sh
vim config.sh  # Set INPUT_DIR to Preprocessing output

# Run topic modeling
./final_mallet_2025.sh --input-dir ./Preprocessing/output --output-dir ./results
```

---

## Troubleshooting One-Liners

```bash
# Missing Python libraries
pip install pandas numpy tqdm htrc-features nltk pycountry

# Missing NLTK data
python -m nltk.downloader words names stopwords wordnet

# No .json.bz2 files found
find /path/to/input -name "*.json.bz2" | head

# Check dictionary files exist
ls -l reference_data/

# Monitor processing
watch "ls /path/to/output/*.txt | wc -l"

# Reduce processes if out of memory
python preprocess_htrc.py --config config.sh --num-processes 4
```

---

## What Gets Processed?

### Input
- HTRC Extracted Features files (`.json.bz2`)
- From HathiTrust Research Center

### Processing (All Fixed for Replication)
1. Extract tokens (20 POS tags)
2. Clean punctuation
3. Fix OCR errors (Greek chars, ligatures)
4. Apply spelling corrections
5. Lemmatize/stem words
6. Map archaic → modern words
7. Filter stopwords (English stopwords + Roman numerals only)
8. Filter by frequency (min 2 per volume)

### Output
- Clean text files (`.txt`)
- One file per input volume
- Space-separated tokens
- Words repeated by frequency
- Ready for MALLET

---

## Processing Parameters

**These are FIXED and cannot be changed** (for reproducibility):
- POS Tags: 20 specific tags
- Min Word Length: 2 characters
- Min Word Frequency: 2 per volume
- Stopword Categories: All 8 enabled

**These are CONFIGURABLE** (adapt to your system):
- Input/output paths
- CPU processes
- Dictionary file paths
- Error logging

---

## Expected Processing Time

Depends on:
- Number of volumes
- CPU cores
- Disk speed

**Rough estimates:**
- 1,000 volumes: 10-30 minutes
- 10,000 volumes: 2-5 hours
- 100,000 volumes: 20-50 hours

Progress bar shows current status.

---

## Output Files

File naming:
- Input: `mdp.39015011641792.json.bz2`
- Output: `mdp.39015011641792.txt`

File content:
```
progress progress enlightenment reason philosophy science nature virtue liberty
```

One .txt file per input volume, ready for MALLET.

---

## Need More Help?

- Full documentation: `README.md`
- Reference data: `reference_data/README.md`
- Built-in help: `python preprocess_htrc.py --help`
- MALLET docs: `../README.md`

---

## Verification Checklist

Before running on full corpus:

- [ ] All dependencies installed (`pip install ...`)
- [ ] NLTK data downloaded
- [ ] Dictionary files in `reference_data/`
- [ ] Input path points to `.json.bz2` files
- [ ] Output path is writable
- [ ] Dry-run looks correct
- [ ] Test run on small sample works

---

**Remember:** This script is for **replication**. Processing parameters are fixed and cannot be changed. Only paths and compute resources are configurable.
