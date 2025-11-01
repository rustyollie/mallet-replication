# Changelog

All notable changes to the HTRC Text Preprocessing pipeline will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2.1] - 2025-11-01

### Changed - Code Refactoring for Readability

**Major refactoring of variable and function names for improved code clarity while maintaining 100% output fidelity.**

This refactoring does NOT change any processing logic, output, or results. All changes are purely cosmetic to improve code readability and maintainability.

#### Critical Variable Renamings (Eliminates Confusion):

| Old Name | New Name | Reason |
|----------|----------|--------|
| `stopwords_ne_ss` | `stem_validation_dict` | **Misleading:** Old name implied filtering, but this is actually a reference dictionary (~500k terms) used to validate stems, not filter output |
| `stopwords_numer` | `filtered_stopwords` | **Unclear:** Old name was cryptic. New name clarifies these are the ~680 words actually removed from output |
| `correct_words()` | `process_volume_pipeline()` | **Misleading:** Old name suggested only spelling correction, but function runs entire 8-step pipeline |
| `clean_ss` | `words_without_archaic` | **Cryptic:** "ss" was meaningless abbreviation |
| `clean_ma` | `words_with_archaic` | **Cryptic:** "ma" was unclear abbreviation |
| `clean_ss_ma` | `combined_processed_words` | **Cryptic:** Concatenation of above two datasets |

#### Function Renamings (Better Clarity):

| Old Name | New Name | Improvement |
|----------|----------|-------------|
| `stem_lem()` | `lemmatize_or_stem()` | Clarifies "or" logic: tries lemmatization first, then stemming as fallback |
| `corr_search()` | `spell_correction_lookup()` | More descriptive and self-documenting |
| `trans()` | `normalize_and_clean_word()` | Clarifies purpose: removes punctuation, fixes Greek chars, expands ligatures, applies NFKC |
| `get_EF_htids()` | `scan_htrc_files()` | Removes jargon ("EF" = Extracted Features, "htids" = HathiTrust IDs) |
| `ma_search()` | Kept as-is | Acceptable in context (Modern/Archaic search) |

#### Dictionary and Variable Renamings:

| Old Name | New Name | Type |
|----------|----------|------|
| `corr` | `spelling_corrections` | Dictionary |
| `corr_set` | `spelling_corrections_index` | Set |
| `madict` | `archaic_to_modern_dict` | Dictionary |
| `madict_set` | `archaic_words_index` | Set |
| `clean_tl` | `filtered_tokens` | DataFrame |
| `tl` | `token_list` | DataFrame |
| `vol` | `volume` | Parameter |
| `fr` | `corpus` | FeatureReader object |
| `EF_ids` | `htrc_files` | DataFrame |
| `alleraser` | `non_alpha_translator` | str.maketrans table |
| `delchars` | `non_alpha_chars` | String |

### Verification & Testing

**Output Verification (SHA256 Hash Comparison):**
- ✅ All 7 output files have byte-for-byte identical SHA256 hashes before and after refactoring
- ✅ Original code determinism verified: multiple runs produce identical results
- ✅ Refactored code determinism verified: multiple runs produce identical results

**Unit Tests:**
- ✅ All 20 unit tests passing before refactoring
- ✅ All 20 unit tests passing after refactoring

**Files Tested:**
- `udel.31741109470890.txt` - Hash: `8474f5086edc8046ccb010f1fe89a0904f033aa2ab5a1d9dfc94fc11831a4b60`
- `udel.31741112279734.txt` - Hash: `9ea06c62be824eb1664f37264c704b527d8cc36c05f3f0442d19cbe65d5db850`
- `udel.31741113286852.txt` - Hash: `b1013d466973853c872fe377638cdf59de8de50347b090ed4ddc2f004ea17c18`
- `udel.31741113288544.txt` - Hash: `9b4d4b6de7671cfa74b0549302489c07bd3bffec8393260372dd4c642fa84685`
- `udel.31741113407037.txt` - Hash: `5e6fb378867b4dfd55013fb962ea6138d0251389e82f6feb2a1c2fec11880236`
- `udel.31741113413506.txt` - Hash: `e56ffe783d8abee34d6d966eaefaa6c001815132dc30201aac00215f031a7801`
- `ufl1.ark+=13960=t8md0711j.txt` - Hash: `d935dea90e39c21d79c74ce46548f9faa2cc30b1fcd11b800f4fdc65cf8154f0`

### Documentation Updates

**Files Updated:**
- `README.md`: Updated line number references (578, 581, 586) and variable names in code examples
- `preprocess_htrc.py`: Version bumped to 2.1, updated date, improved inline comments
- `CHANGELOG.md`: Created this file

**No Changes Needed:**
- `PT_Nov2024.py` - Historical reference, preserved as-is
- `test/test_preprocessing.py` - No variable name dependencies
- `QUICKSTART.md` - No variable name references
- `config.template.sh` - No variable name references

### Bug Fixes

- Fixed temporary bug introduced during refactoring where DataFrame column name `'correct_spelling'` was accidentally changed to `'spelling_correctionsect_spelling'` by overly aggressive find/replace. Bug was caught during testing and fixed before final commit.

### Technical Notes

**Refactoring Methodology:**
1. Established baseline output with SHA256 hashes
2. Applied all 20 variable renamings systematically
3. Fixed accidental string literal replacements in non-code contexts
4. Re-ran processing on identical sample data
5. Compared SHA256 hashes (all matched)
6. Re-ran unit tests (all passed)

**Processing Logic Unchanged:**
- Same 8-step pipeline (POS filtering → cleaning → correction → lemmatization → archaic mapping → stopword filtering → stemming)
- Same POS tags (20 tags)
- Same minimum word length (2 characters)
- Same minimum frequency (2 per volume)
- Same stopword filtering (~680 terms: English stopwords + Roman numerals)
- Same reference dictionaries for stem validation (~500k terms)
- Same output format (space-separated tokens, frequency-weighted)

---

## [2.0] - 2025-10-30

### Added - Cross-Platform Modernization

**Major rewrite to support cross-platform replication (Windows, macOS, Linux).**

#### Infrastructure Changes

- **Command-line argument parsing** using argparse
- **Configuration file support** (shell format): `config.sh`
- **Environment validation** before processing
- **Dry-run mode** for previewing operations
- **Cross-platform paths** using pathlib.Path
- **Auto-detect CPU cores** for multiprocessing
- **Optional error logging** to file
- **Progress display** with tqdm

#### Configuration Precedence

Settings loaded in order: defaults → config file → CLI arguments

#### New Features

- `--config` flag for configuration files
- `--dry-run` flag to preview without executing
- `--verbose` flag for detailed logging
- Comprehensive help text and usage examples
- Input validation with clear error messages

#### Processing Logic Preserved

**IMPORTANT:** All processing parameters remain FIXED for replication:
- Same POS tags (20 tags: NE, NN, NNP, NNPS, JJ, JJS, JJR, IN, DT, VB, VBP, VBZ, VBD, VBN, VBG, RB, RBR, RBS, RP, CC)
- Same minimum word length (2 characters)
- Same minimum frequency (2 per volume)
- Same stopword filtering (English stopwords + Roman numerals)
- Same lemmatization/stemming logic
- Same character corrections (Greek, ligatures, NFKC normalization)
- Same dictionary corrections (Master_Corrections.csv, MA_Dict_Final.csv)

#### Files Added

- `preprocess_htrc.py` - Modernized cross-platform script (998 lines)
- `README.md` - Comprehensive documentation (~600 lines)
- `QUICKSTART.md` - Quick start guide
- `config.template.sh` - Template configuration file
- `test/test_preprocessing.py` - 20 unit tests
- `reference_data/README.md` - Dictionary documentation

#### Files Preserved

- `PT_Nov2024.py` - Original Windows-specific script (kept for reference)

#### Documentation

- Full README with processing pipeline explanation
- Step-by-step setup instructions
- Configuration examples
- Troubleshooting guide
- Performance benchmarks
- Reference data documentation

### Fixed

- **Multiprocessing issue**: Identified (but not yet fixed) issue where dictionaries loaded in `main()` don't transfer to worker processes
- **Path handling**: Replaced hardcoded Windows paths (E:\, D:\) with cross-platform Path objects
- **Test coverage**: Added comprehensive unit tests for reproducibility

### Technical Debt

- **Known Issue**: Multiprocessing currently non-functional due to global variable scoping. Dictionaries need to be passed as parameters or loaded at module import time.
- **Solution Proposed**: Use ThreadPool instead of ProcessPool, or refactor to load dictionaries at module-level import time

---

## [1.0] - 2024-11-03

### Initial Release

**Original PT_Nov2024.py script**

- Windows-specific paths (E:\, D:\ drives)
- Hardcoded file locations
- No command-line arguments
- Manual configuration editing
- Functional processing pipeline
- Validated output for QJE 2025 submission

#### Processing Pipeline (Original)

8-step pipeline for HTRC Extracted Features:
1. POS tag filtering (20 tags)
2. Punctuation cleaning
3. OCR error correction (Greek characters, ligatures)
4. Spelling correction (Master_Corrections.csv)
5. Lemmatization/stemming (WordNet + Snowball)
6. Archaic→modern mapping (MA_Dict_Final.csv)
7. Stopword filtering (English stopwords + Roman numerals)
8. Final stemming

#### Reference Data Files

- `Master_Corrections.csv` - 1,255 OCR spelling corrections (~19KB)
- `MA_Dict_Final.csv` - 3,721 archaic-to-modern mappings (~73KB)
- `world_cities.csv` - 24,997 city names for reference (~993KB)

---

## Version Numbering Scheme

- **Major version** (X.0.0): Breaking changes to processing logic or output format
- **Minor version** (x.Y.0): New features, refactoring, or improvements (backward compatible)
- **Patch version** (x.y.Z): Bug fixes only

**Current Version:** 2.1 (Refactoring for readability)
