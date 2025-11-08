# Archive Instructions

This document describes what should be archived (not committed to git) before pushing the clean version of this project.

## Archive Structure

Create the following archive structure:

```
F:\Claude\mallet-replication\Archive\
└── Validation_Nov2025\
    ├── PT_test\                    # All validation tests
    ├── Full_Deployment_Output\     # Deployment outputs (if exists)
    └── validation_summary.md       # Summary of validation results
```

## Files to Archive (Not Commit)

### 1. Test and Validation Folders

**PT_test/**
- All validation test outputs
- Agent task files
- Verification results
- Comparison scripts
- Hourly validation reports
- Signal files (.txt)
- Progress tracking files

**Move to**: `Archive/Validation_Nov2025/PT_test/`

### 2. Deployment Output

**Full_Deployment_Output/** (if exists)
- 263,750+ processed .txt files
- Deployment logs

**Note**: This folder contains large output data and should NOT be committed.
**Action**: Keep on local machine, document location in README

### 3. Reference Data (External)

These are external to the repository:
- `E:\Documents\UKFinal\Cleaned_Nov2024\` - Reference ground truth data
- `E:\Documents\UKFinal\Rsync_Deduplicated\` - Original HTRC corpus
- `F:\Get Unique Volumes\rsync_2026\` - Deduplicated input corpus

**Note**: Already external, not in repo. Document in README.

### 4. Temporary and Generated Files

- `nul` - Remove
- `*.log` files
- `deployment_pid.txt`
- `deployment_start_time.txt`
- `*_files.txt` (temporary file lists)

**Action**: Delete these files

## Files to Keep in Repository

### Core Components

1. **Get Unique Volumes/** (Stage 1)
   - `README.md`
   - `Get Unique Volumes for Rsync.ipynb` (production notebook)
   - `Get Unique Volumes.ipynb` (reference notebook)
   - `requirements.txt`
   - **Exclude**: Input/output data files

2. **Preprocessing/** (Stage 2)
   - `README.md`
   - `preprocess_htrc.py` (production script)
   - `requirements.txt`
   - **Exclude**: Output data, logs

3. **LDA/** (Stage 3)
   - `README.md`
   - All scripts and documentation
   - **Exclude**: Output .mallet files, results

4. **Root Files**
   - `README.md` (main project documentation)
   - `.gitignore`
   - `LICENSE` (if exists)

## Manual Archive Steps

Since `PT_test/` folder may have permission issues, manually:

1. **Create archive folder**:
   ```bash
   mkdir -p "F:\Claude\mallet-replication\Archive\Validation_Nov2025"
   ```

2. **Copy (don't move) PT_test** to archive:
   ```bash
   # Use Windows Explorer to copy PT_test folder
   # Source: F:\Claude\mallet-replication\PT_test
   # Destination: F:\Claude\mallet-replication\Archive\Validation_Nov2025\PT_test
   ```

3. **After successful copy, verify** .gitignore excludes it:
   ```bash
   cd F:\Claude\mallet-replication
   git status
   # PT_test/ should NOT appear in untracked files
   ```

## Validation Summary to Preserve

Create `Archive/Validation_Nov2025/validation_summary.md` with:

- All 5 validation missions completed
- 500-file validation: 100% semantic match
- Regression investigation: No bugs found
- Full deployment: 75% complete, 100% quality
- Final recommendation: Scripts validated and approved

## After Archiving

Run these checks:

```bash
cd F:\Claude\mallet-replication
git status

# Should show only:
# - Modified: Preprocessing/preprocess_htrc.py (if changes made)
# - Modified: .gitignore (with new exclusions)
# - Untracked: ARCHIVE_INSTRUCTIONS.md (this file)
# - Untracked: README.md (if updated)

# Should NOT show:
# - PT_test/
# - Full_Deployment_Output/
# - Any .log files
# - Any test data
```

## Commit Preparation

After archiving:

1. Review changes to `Preprocessing/preprocess_htrc.py`
2. Update main `README.md` with comprehensive documentation
3. Stage only clean files for commit
4. Commit with message describing the complete three-stage pipeline
5. Push to remote

---

**Created**: November 7, 2025
**Purpose**: Clean repository for public release
**Validation**: All tests passed, scripts approved for production
