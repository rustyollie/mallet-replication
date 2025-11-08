# Dictionary to Output File Mapping

## Complete Mapping Table

| Dictionary File | Column(s) | Scoring Method | Output File | Output Column Name(s) | Notes |
|----------------|-----------|----------------|-------------|----------------------|-------|
| **Updated Progress List.csv** | progress | Simple | Sentiment Results (Jan 2025).csv | Regression, Pessimism, Optimism | Missing Progress column |
| **Updated Progress List.csv** | progress, optimism, pessimism, regression | Simple | Sentiment Results (March 2025).csv | Progress, Optimism, Pessimism, Regression | Full 4-column results |
| **Updated Progress List.csv** | progress | Simple | Progress Scores (Jan 2025).csv | Progress | Progress only |
| **Updated Progress List May 2023.csv** | Column 0 (Main), Column 1 (Secondary) | Simple | Sentiment Results (March 2025 - Main - Secondary).csv | Main, Progress | Secondary labeled as "Progress" |
| **ChatGPT Progress Dictionary.csv** | ChatGPT_Porgress | Simple | Sentiment Results (ChatGPT).csv | ChatGPT Progress | Earlier version |
| **ChatGPT Progress Dictionary.csv** | ChatGPT_Porgress | Simple | Sentiment Results (august2025).csv | ChatGPT Progress | Latest version (Aug 2025) |
| **Industry and Optimism Dictionary (May 2025).csv** | Industrialization Prior, Optimism Double Meaning | Simple | Industrialization and Optimism Results (May 2025).csv | Industrialization Prior, Optimism Double Meaning | 2 columns in one file |
| **Industrialization Dictionary (May 24).csv** | word, count | **Weighted** | Inudstrialization Scores (Jan 2025).csv | Industrial Scores (June 23) | **Mislabeled** as "June 23" |
| **Industrialization Dictionary (May 24).csv** | word, count | **Weighted** | Inudstrialization Scores (March 2025).csv | Industrial Scores (March 25) | Same dict, different month |
| **APPLEBY'S TOC (3-vote Threshold).csv** | word, count | **Weighted** | Inudstrialization Scores (All words - April 2025).csv | Industrial Scores (All words) | 207 words with weights |
| **Industrialization Dictionary (June 23).csv** | word | Simple | *(NOT USED)* | N/A | Simple word list, never scored in results |

---

## Detailed Breakdown by Output File

### 1. Sentiment Results (Jan 2025).csv
**Columns:** Regression, Pessimism, Optimism
**Dictionary:** Updated Progress List.csv (columns: regression, pessimism, optimism)
**Method:** Simple
**Note:** Missing "Progress" column

### 2. Sentiment Results (March 2025).csv
**Columns:** Regression, Pessimism, Optimism, Progress
**Dictionary:** Updated Progress List.csv (all 4 columns)
**Method:** Simple
**Note:** Complete 4-column sentiment results

### 3. Sentiment Results (March 2025 - Main - Secondary).csv
**Columns:** Main, Progress
**Dictionary:** Updated Progress List May 2023.csv
**Method:** Simple
**Note:** Secondary progress labeled as "Progress" in output

### 4. Sentiment Results (ChatGPT).csv
**Columns:** ChatGPT Progress
**Dictionary:** ChatGPT Progress Dictionary.csv
**Method:** Simple
**Note:** Earlier version

### 5. Sentiment Results (august2025).csv
**Columns:** ChatGPT Progress
**Dictionary:** ChatGPT Progress Dictionary.csv
**Method:** Simple
**Note:** Latest version (August 2025)

### 6. Progress Scores (Jan 2025).csv
**Columns:** Progress
**Dictionary:** Updated Progress List.csv (progress column only)
**Method:** Simple
**Note:** Progress sentiment only

### 7. Industrialization and Optimism Results (May 2025).csv
**Columns:** Optimism Double Meaning, Industrialization Prior
**Dictionary:** Industry and Optimism Dictionary (May 2025).csv
**Method:** Simple
**Note:** Two metrics in one file

### 8. Inudstrialization Scores (Jan 2025).csv
**Columns:** Industrial Scores (June 23)
**Dictionary:** Industrialization Dictionary (May 24).csv (WEIGHTED)
**Method:** Weighted (count × weight / total_words)
**Note:** ⚠️ **MISLABELED** - Uses May 24 dict, not June 23!

### 9. Inudstrialization Scores (March 2025).csv
**Columns:** Industrial Scores (March 25)
**Dictionary:** Industrialization Dictionary (May 24).csv (WEIGHTED)
**Method:** Weighted
**Note:** Same dict as Jan 2025, 160 words

### 10. Inudstrialization Scores (All words - April 2025).csv
**Columns:** Industrial Scores (All words)
**Dictionary:** APPLEBY'S TOC (3-vote Threshold).csv (WEIGHTED)
**Method:** Weighted
**Note:** 207 words with vote-based weights

---

## Key Findings

### ⚠️ Mislabeling Issue
The **"Industrial Scores (June 23)"** in Jan/March 2025 results were actually generated using:
- **Dictionary:** Industrialization Dictionary (May 24).csv
- **Method:** Weighted (160 words)
- **NOT** using Industrialization Dictionary (June 23).csv (which is a simple 160-word list)

### Unused Dictionary
**Industrialization Dictionary (June 23).csv** - This simple word list was never used to generate any of the result files.

### Dictionary Reuse
- **Updated Progress List.csv** → Used in 3 different output files
- **Industrialization Dictionary (May 24).csv** → Used in both Jan and March 2025 industrialization scores

---

## Scoring Methods Summary

**Simple (Unweighted):** 8 dictionaries
- Sum of word percentage values (pct) for matching words
- Formula: `score = Σ(pct for matched words)`

**Weighted:** 2 dictionaries
- Weight × count normalized by total words
- Formula: `score = Σ(weight × word_count) / total_words`
