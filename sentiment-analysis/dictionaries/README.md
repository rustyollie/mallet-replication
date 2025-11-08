# Sentiment Dictionaries

This folder contains all sentiment dictionaries used for scoring.

## Dictionary Files

### 1. **APPLEBY'S TOC (3-vote Threshold).csv**
- **Type:** Weighted industrialization dictionary
- **Columns:** word, count (weight/vote count)
- **Words:** 207 industrial terms
- **Scoring Method:** Weighted (count × weight / total_words)
- **Use:** Industrialization scores with vote-based weighting

### 2. **ChatGPT Progress Dictionary.csv**
- **Type:** Simple progress dictionary (ChatGPT-curated)
- **Columns:** ChatGPT_Porgress (single column)
- **Words:** 7 words (progress, betterment, improvment, refinement, decorum, urbanity, civility)
- **Scoring Method:** Simple (sum of pct)
- **Use:** ChatGPT Progress scores

### 3. **Industrialization Dictionary (June 23).csv**
- **Type:** Simple industrialization dictionary
- **Columns:** word (single column)
- **Words:** 161 industrial terms
- **Scoring Method:** Simple (sum of pct)
- **Use:** Industrial Scores (June 23)

### 4. **Industrialization Dictionary (May 24).csv**
- **Type:** Weighted industrialization dictionary
- **Columns:** word, count (weight/vote count)
- **Words:** 207 industrial terms
- **Scoring Method:** Weighted (count × weight / total_words)
- **Use:** Industrial Scores (May 24)

### 5. **Industry and Optimism Dictionary (May 2025).csv**
- **Type:** Multi-column simple dictionary
- **Columns:** Industrialization Prior, Optimism Double Meaning
- **Words:** ~25 words per column
- **Scoring Method:** Simple (sum of pct) for each column
- **Use:** Industrialization Prior & Optimism Double Meaning scores

### 6. **Industry and Optimism Dictionary (May 2025) - Copy.csv**
- **Type:** Duplicate of #5
- **Note:** Redundant copy, may not need to use

### 7. **Updated Progress List.csv**
- **Type:** Multi-column simple dictionary
- **Columns:** progress, optimism, pessimism, regression (4 columns)
- **Words:** ~9-33 words per column
- **Scoring Method:** Simple (sum of pct) for each column
- **Use:** Progress, Optimism, Pessimism, Regression scores

### 8. **Updated Progress List May 2023.csv**
- **Type:** Multi-column simple dictionary
- **Columns:** Progress (Main), Progress (Secondary) - 2 columns with header row
- **Words:** 6-7 words per column
- **Scoring Method:** Simple (sum of pct) for each column
- **Use:** Main Progress & Secondary Progress scores

## Dictionary Types

### Simple (Unweighted) Dictionaries
Score = Sum of word percentages (pct) for matching words
- ChatGPT Progress Dictionary
- Industrialization Dictionary (June 23)
- Industry and Optimism Dictionary (May 2025)
- Updated Progress List
- Updated Progress List May 2023

### Weighted Dictionaries
Score = Sum(count × weight) / total_words
- APPLEBY'S TOC (3-vote Threshold)
- Industrialization Dictionary (May 24)

## Stemming Requirements

Most dictionaries require Porter Stemming to be applied before matching, except:
- Industrialization dictionaries (already stemmed)
- APPLEBY'S TOC (already stemmed)
