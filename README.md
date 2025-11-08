# AIKR
## Overview
The code in this replication package runs the analysis for the paper "Enlightenment Ideals and Beliefs in Progress in the Run-up to the Industrial Revolution: A Textual Analysis" by Ali Almelhem, Murat Iyigun, Austin Kennedy, and Jared Rubin. It produces 53 figures and 3 tables. The code in this replication package is split into two parts:

1. **LDA**
2. **Final Analysis**

The data for replication is available here: [Data For Replication](https://www.dropbox.com/scl/fo/2qg8lv11j41ytjp2ru3k7/AHfF5xuQUVdtFNYKjcwMBa0?rlkey=py6mt8kztk72g8ity4hqlpbqc&st=9d8zn45r&dl=0)

Detailed documentation on each part can be found within their respective directories.

## Data Availability and Provenance Statements

### Statement about Rights

I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript.

### Summary of Availability

All data are publicly available.

### Details on each Data Source


## Description of Programs/Code

### LDA

The code stored in the `lda` directory implements MALLET (MAchine Learning for LanguagE Toolkit) topic modeling to extract 60 topics from the historical corpus. This produces the LDA output files that are used as input for the Final Analysis pipeline.

The topic modeling framework uses fixed model parameters for exact reproducibility:
- **Number of topics:** 60 (hardcoded)
- **Random seed:** 1 (hardcoded)
- **Optimization interval:** 500 (hardcoded)

Infrastructure parameters (paths, compute resources) are fully configurable via `lda/config.sh` file.

**Requirements:**
- MALLET installed and in PATH
- Java 1.8 or higher
- Bash 4.0+
- SLURM (optional, for HPC environments)

**Quick Start:**

1. Navigate to the LDA directory:
   ```bash
   cd lda
   ```

2. Create configuration file:
   ```bash
   cp config.template.sh config.sh
   vim config.sh  # Edit INPUT_DIR, OUTPUT_DIR, STOPLIST_FILE
   ```

3. Run topic modeling:
   ```bash
   # Local execution
   ./final_mallet_2025.sh

   # Or submit to SLURM
   sbatch final_mallet_2025.sh
   ```

**Output Files:**

The LDA pipeline produces several output files in the specified output directory:
- `topics.txt` - Document-topic distributions (main output for Final Analysis)
- `keys.txt` - Topic keywords
- `model.mallet` - Trained topic model
- `inferencer.mallet` - For applying model to new documents
- `diagnostics.xml` - Training diagnostics

**Documentation:**

For detailed documentation, see:
- `lda/README.md` - Complete documentation with all options
- `lda/QUICKSTART.md` - 30-second quick reference
- `lda/DEPLOY.md` - Step-by-step HPC deployment guide
- `lda/test/README_TESTING.md` - Testing framework documentation

**Testing:**

A comprehensive test suite is included that validates the framework without requiring MALLET installation:
```bash
cd lda/test
./run_tests.sh
```

The test suite includes 12 test scenarios with 32 assertions covering configuration management, CLI arguments, validation, and error handling.

### Final Analysis

The code stored in the `final_analysis` directory takes the output of the LDA model, performs data processing and transformation, runs the algorithm to get distinct "categories" of topics (e.g. Science, Religion, and Political Economy), runs regressions, and produces the final tables and figures.

This code was developed and run on Python 3.11.1. A `requirements.txt` file is provided listing dependencies and package versions. You can install it by navigating to the `final_analysis` directory in the command line and running:

```
pip install -r requirements.txt
```

**Quick Start**

To run the final analysis, first download the `final_analysis_input` folder from the data repository included above. Place this folder under `final_analysis/data/` (or alternatively, change the `input_path` parameter in the config files under `final_analysis/configs`).

The entirety of the final analysis can then be run by running the `final_analysis/main.py` script in Python:

**For Windows Users**
```
python final_analysis/main.py
```

**For MacOS/Linux Users**
```
python3 final_analysis/main.py
```

Note that all necessary input data (i.e. the output of the LDA model and additional files) must be present in order for the code to properly run. The code will create all figures and tables and store them in the `final_analysis/data/paper_assets/` directory.

Configuration files can be found under the `final_analysis/configs` directory.

For more detailed documentation, see `final_analysis/README.md`.

### License for Code

This code is licensed under the MIT license. See the LICENSE file for details.
