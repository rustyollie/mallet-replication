# AIKR
## Overview
The code in this replication package runs the analysis for the paper "Enlightenment Ideals and Beliefs in Progress in the Run-up to the Industrial Revolution: A Textual Analysis" by Ali Almelhem, Murat Iyigun, Austin Kennedy, and Jared Rubin. It produces 53 figures and 3 tables. The final analysis, which uses the output of the LDA model to produce the tables and figures, should be expected to take two or three hours to run.

## Final Analysis

The code stored in the `final_analysis` directory takes the output of the LDA model, performs data processing and transformation, runs the algorithm to get distinct "categories" of topics (e.g. Science, Religion, and Political Economy), runs regressions, and produces the final tables and figures.

This code was developed and run on Python 3.11.1. A `requirements.txt` file is provided listing dependencies and package versions. You can install it by navigating to the `final_analysis` directory in the command line and running:

```
pip install -r requirements.txt
```

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

Configuration files can be found under the `final_analysis/configs` directory.