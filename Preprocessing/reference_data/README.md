# Reference Data Files

These files are **required** for reproducible preprocessing of HTRC Extracted Features data. They are part of the replication package and must not be modified.

---

## Files Included

### 1. Master_Corrections.csv

**Purpose:** Spelling corrections for OCR errors commonly found in historical texts

**Format:**
```csv
lemma,correct_spelling
recieve,receive
teh,the
connexion,connection
```

**Columns:**
- `lemma` (orig): Original word form (possibly misspelled)
- `correct_spelling` (stand): Standardized/corrected form

**Size:** ~19 KB

**Usage:** Applied after initial punctuation cleaning and before lemmatization. Corrects common OCR errors and spelling variations in historical texts.

**When applied:** Step 3 of processing pipeline

---

### 2. MA_Dict_Final.csv

**Purpose:** Modern/Archaic word mappings for standardizing historical language

**Format:**
```csv
orig,stand
whilst,while
hath,has
unto,to
```

**Columns:**
- `orig`: Archaic word form
- `stand`: Modern equivalent

**Size:** ~73 KB

**Usage:** Applied after lemmatization to map archaic language forms to their modern equivalents, ensuring consistency across historical and contemporary texts.

**When applied:** Step 3 of processing pipeline (after general corrections)

---

### 3. world_cities.csv

**Purpose:** Comprehensive list of world cities for geographic stopword filtering

**Format:**
```csv
name,country,subcountry,geonameid
London,United Kingdom,England,2643743
Paris,France,Île-de-France,2988507
New York,United States,New York,5128581
```

**Columns:**
- `name`: City name
- `country`: Country name
- `subcountry`: State/province/region
- `geonameid`: GeoNames database identifier
- Additional columns with geographic data

**Size:** ~993 KB

**Usage:** City names are extracted and used as stopwords. Geographic entities typically don't contribute meaningful information to topic modeling about ideas and concepts, so they are filtered out.

**When applied:** Step 5 of processing pipeline (stopword filtering)

---

## Provenance

These reference files were curated specifically for preprocessing historical texts from the HathiTrust Digital Library for topic modeling analysis.

- **Master_Corrections.csv**: Compiled from observed OCR errors in 18th-19th century texts
- **MA_Dict_Final.csv**: Curated list of archaic-to-modern word mappings for Early Modern and Modern English
- **world_cities.csv**: Derived from public geographic databases

---

## Licensing

These files are provided as part of the QJE replication package and may be freely used for academic research and replication purposes.

**Copyright:** Ali Almelhem, Murat Iyigun, Austin Kennedy, and Jared Rubin

**License:** MIT License (same as parent repository)

---

## Reproducibility Guarantee

**DO NOT MODIFY** these files unless you are running exploratory analysis (not replication).

- Same dictionary files + same input = same preprocessing results
- These files define the "methodology" of text cleaning
- Any changes break exact replication

**Checksum verification:**

```bash
# Verify files haven't been modified
md5sum *.csv
```

Expected checksums will be documented upon initial commit.

---

## Usage in Pipeline

These files are automatically loaded by `preprocess_htrc.py` when you specify their paths in `config.sh`:

```bash
DICT_CORRECTIONS="./reference_data/Master_Corrections.csv"
DICT_MA="./reference_data/MA_Dict_Final.csv"
WORLD_CITIES="./reference_data/world_cities.csv"
```

The preprocessing script validates that all three files exist before processing begins.

---

## Questions?

For questions about these reference files, see the main preprocessing documentation:
- `../README.md` - Full preprocessing documentation
- `../QUICKSTART.md` - Quick start guide

For questions about the overall replication package, see:
- `../../README.md` - Main repository documentation
