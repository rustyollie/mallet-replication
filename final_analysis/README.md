# Final Analysis - Replication Scripts

This repository contains scripts that take the output of the LDA model, run the categorization algorithm, and produce final figures and tables.

## Requirements

This code was developed and run on Python 3.11.1. A `requirements.txt` file is provided listing dependencies and package versions. You can install it by navigating to the `final_analysis` directory in the command line and running:

```
pip install -r requirements.txt
```

## Quick Start

The entirety of the final analysis can be run by running the `final_analysis/main.py` file in Python:

**For Windows Users**
```
python final_analysis/main.py
```

**For MacOS/Linux Users**
```
python3 final_analysis/main.py
```

Note that all necessary input data (i.e. the output of the LDA model and additional files) must be present in order for the code to properly run. The code will create all figures and tables and store them in the `final_analysis/data/paper_assets/` directory.

Configuration files can be found under the `final_analysis/configs` directory. Currently the configuration files point to a single directory for all input data, `data/input_all` with the assumption that all necessary input files (listed below) are present in this directory. All input files must be present for the code to run.

## Data

The following is a table of data files that must be present for the analysis to run:

| File | Description |
|------|-------------|
| `40_Coherence_keys.txt` | The topics and associated words outputted by the LDA model using the Coherence score (Section C). |
| `40_Coherence_topics.txt` | The volume-level weights associated with each topic, using the topics outputted by the LDA model using the Coherence score (Section C). |
| `estc_1500_to_1800.csv` | Data for the ESTC section (Section D). |
| `famous_books.csv` | The metadata for selected famous works in our corpus. |
| `industry_optimism_may_2025.csv` | The volume-level optimism scores, double meanings excluded, and industry scores, using the 1708 dictionary. |
| `industry_scores_full_dict.csv` | The volume-level industry scores, including words first used after 1643. |
| `industry_scores_jan2025.csv' | The volume-level industry scores, excluding words first used after 1643. |
| `LDA_01_keys.txt` | The topics and associated words outputted by the LDA model used in our main analysis. |
| `LDA_01_topics.txt` | The volume-level weights associated with each topic, using the topics outputted by the LDA model used in our main analysis. |
| `metadata_march25.csv` | The metadata for our corpus. |
| `progress_chatgpt_v2.csv` | The volume-level scores for the progress dictionary produced by ChatGPT. |
| `sentiment_results_march25.csv` | The sentiment scores used in our main analysis. |
| `translations.csv` | Contains flags for volumes that are translations. |
| `updated_progress_scores_march25.csv` | Scores for the "progress" dictonaries used in the main analysis, as well as the 1708 dictionary. |
