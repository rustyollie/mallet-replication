"""
Unified Sentiment Scoring Script

This script calculates sentiment scores for all volumes using various dictionaries.
It consolidates the logic from multiple Jupyter notebooks into a single, maintainable script.
"""

import pandas as pd
from tqdm import tqdm
import os
from nltk.stem.porter import PorterStemmer


def load_dictionaries():
    """
    Load all sentiment dictionaries and organize them into two structures:
    1. simple_dicts: For unweighted scoring (sum of pct values)
    2. weighted_dicts: For weighted scoring (count × weight / total_words)

    Returns:
        tuple: (simple_dicts, weighted_dicts)
            - simple_dicts: dict of DataFrames with word index only
            - weighted_dicts: dict of DataFrames with word index and 'count' column
    """
    stemmer = PorterStemmer()
    dict_path = r'./dictionaries'

    simple_dicts = {}
    weighted_dicts = {}

    print("\nLoading dictionaries...")

    # 1. Updated Progress List - 4 columns (progress, optimism, pessimism, regression)
    # Load with header=None to include header words in data (matching notebook behavior)
    print("  Loading: Updated Progress List")
    df_words = pd.read_csv(os.path.join(dict_path, 'Updated Progress List.csv'), header=None)
    for col_idx, col_name in [(0, 'Progress'), (1, 'Optimism'), (2, 'Pessimism'), (3, 'Regression')]:
        df = pd.DataFrame()
        df['word'] = [stemmer.stem(x) for x in df_words[col_idx].dropna()]
        df = df.set_index('word')
        simple_dicts[col_name] = df
        print(f"    - {col_name}: {len(df)} words")

    # 2. Updated Progress List May 2023 - 2 columns (Main, Secondary)
    # Load with header=None to include header words in data (matching notebook behavior)
    print("  Loading: Updated Progress List May 2023")
    df_words = pd.read_csv(os.path.join(dict_path, 'Updated Progress List May 2023.csv'), header=None)
    for col_idx, col_name in [(0, 'Main'), (1, 'Secondary')]:
        df = pd.DataFrame()
        df['word'] = [stemmer.stem(x) for x in df_words[col_idx].dropna()]  # Include all rows
        df = df.set_index('word')
        simple_dicts[col_name] = df
        print(f"    - {col_name}: {len(df)} words")

    # 3. ChatGPT Progress Dictionary - 1 column
    print("  Loading: ChatGPT Progress Dictionary")
    df_words = pd.read_csv(os.path.join(dict_path, 'ChatGPT Progress Dictionary.csv'))
    df = pd.DataFrame()
    df['word'] = [stemmer.stem(x) for x in df_words['ChatGPT_Porgress'].dropna()]
    df = df.set_index('word')
    simple_dicts['ChatGPT_Progress'] = df
    print(f"    - ChatGPT_Progress: {len(df)} words")

    # 4. Industrialization Dictionary (June 23) - 1 column, already stemmed
    print("  Loading: Industrialization Dictionary (June 23)")
    df_words = pd.read_csv(os.path.join(dict_path, 'Industrialization Dictionary (June 23).csv'))
    df = pd.DataFrame()
    df['word'] = df_words['word'].dropna()  # No stemming, already stemmed
    df = df.set_index('word')
    simple_dicts['Industrial_June23'] = df
    print(f"    - Industrial_June23: {len(df)} words")

    # 5. Industry and Optimism Dictionary (May 2025) - 2 columns
    print("  Loading: Industry and Optimism Dictionary (May 2025)")
    df_words = pd.read_csv(os.path.join(dict_path, 'Industry and Optimism Dictionary (May 2025).csv'))
    for col, dict_name in [('Industrialization Prior', 'Industrialization_Prior'),
                           ('Optimism Double Meaning', 'Optimism_Double_Meaning')]:
        df = pd.DataFrame()
        df['word'] = [stemmer.stem(x) for x in df_words[col].dropna()]
        df = df.set_index('word')
        simple_dicts[dict_name] = df
        print(f"    - {dict_name}: {len(df)} words")

    # 6. APPLEBY'S TOC (3-vote Threshold) - WEIGHTED, already stemmed
    print("  Loading: APPLEBY'S TOC (3-vote Threshold) [WEIGHTED]")
    df = pd.read_csv(os.path.join(dict_path, "APPLEBY'S TOC (3-vote Threshold).csv"))
    df = df.set_index('word')
    weighted_dicts['APPLEBY_3vote'] = df
    print(f"    - APPLEBY_3vote: {len(df)} words (weighted)")

    # 7. Industrialization Dictionary (May 24) - WEIGHTED, already stemmed
    print("  Loading: Industrialization Dictionary (May 24) [WEIGHTED]")
    df = pd.read_csv(os.path.join(dict_path, 'Industrialization Dictionary (May 24).csv'))
    df = df.set_index('word')
    weighted_dicts['Industrial_May24'] = df
    print(f"    - Industrial_May24: {len(df)} words (weighted)")

    print(f"\nLoaded {len(simple_dicts)} simple dictionaries and {len(weighted_dicts)} weighted dictionaries")

    return simple_dicts, weighted_dicts


def score_volume_simple(volume_path, dict_df):
    """
    Calculate simple (unweighted) sentiment score for a volume.

    Methodology: Sum of pct (percentage) values for matching words

    Args:
        volume_path: Path to volume word distribution CSV
        dict_df: Dictionary DataFrame with word index only

    Returns:
        float: Sentiment score (sum of word percentages)
    """
    # Load volume word distribution
    df_vol = pd.read_csv(volume_path).set_index('word')

    # Join dictionary with volume (left join keeps only dictionary words)
    df_joined = dict_df.join(df_vol, how='left').fillna(0)

    # Sum the percentages
    score = df_joined['pct'].sum()

    return score


def score_volume_weighted(volume_path, dict_df):
    """
    Calculate weighted sentiment score for a volume.

    Methodology: (Sum of count × weight) / total_words

    Args:
        volume_path: Path to volume word distribution CSV
        dict_df: Dictionary DataFrame with word index and 'count' column (weights)

    Returns:
        float: Weighted sentiment score
    """
    # Load volume word distribution
    df_vol = pd.read_csv(volume_path).set_index('word')
    total_words = df_vol['total_words'].max()

    # Join dictionary with volume (left join, add suffix to volume columns)
    df_joined = dict_df.join(df_vol, rsuffix='_data', how='left').fillna(0)

    # Multiply weight × word count
    df_joined['count_x_weight'] = df_joined['count'].multiply(df_joined['count_data'])

    # Sum and normalize by total words
    score = df_joined['count_x_weight'].sum() / total_words

    return score


def score_all_volumes(DF_ids, simple_dicts, weighted_dicts):
    """
    Score all volumes using all dictionaries and generate results DataFrame.

    Args:
        DF_ids: DataFrame with volume file paths
        simple_dicts: Dictionary of simple (unweighted) dictionaries
        weighted_dicts: Dictionary of weighted dictionaries

    Returns:
        DataFrame: Results with filename as index and score columns
    """
    # Initialize results DataFrame with filenames as index
    filenames = DF_ids['Filename'].tolist()
    results = pd.DataFrame(index=filenames)
    results.index.name = 'Filename'

    print("\n" + "="*60)
    print("SCORING ALL VOLUMES")
    print("="*60)

    # Score all volumes for each simple dictionary
    print("\nProcessing simple (unweighted) dictionaries...")
    for dict_name, dict_df in simple_dicts.items():
        print(f"  Scoring: {dict_name}")
        scores = []

        for idx, row in tqdm(DF_ids.iterrows(), total=len(DF_ids), desc=f"  {dict_name}"):
            score = score_volume_simple(row['Path'], dict_df)
            scores.append(score)

        results[dict_name] = scores

    # Score all volumes for each weighted dictionary
    print("\nProcessing weighted dictionaries...")
    for dict_name, dict_df in weighted_dicts.items():
        print(f"  Scoring: {dict_name}")
        scores = []

        for idx, row in tqdm(DF_ids.iterrows(), total=len(DF_ids), desc=f"  {dict_name}"):
            score = score_volume_weighted(row['Path'], dict_df)
            scores.append(score)

        results[dict_name] = scores

    print(f"\nScoring complete! Generated {len(results)} rows × {len(results.columns)} columns")

    return results


def generate_word_distribution(raw_text_path, output_path):
    """
    Generate word distribution file from raw text.

    Matches the exact methodology from the original notebooks:
    1. Read raw text
    2. Split into words
    3. Count occurrences
    4. Filter words appearing more than once
    5. Calculate percentages

    Args:
        raw_text_path: Path to raw cleaned text file
        output_path: Path to save word distribution CSV

    Returns:
        DataFrame: Word distribution with columns: word (index), count, pct, total_words
    """
    # Read raw text file
    with open(raw_text_path, 'rb') as f:
        raw = f.read().decode('utf-8')

    # Split into words
    lines = raw.split()

    # Create DataFrame and count words
    df = pd.DataFrame(lines, columns=['word'])
    df['count'] = 1
    df = df.groupby('word').sum().sort_values('count', ascending=False)

    # Filter words that appear more than once (matching notebook logic)
    df = df[df['count'] > 1]

    # Calculate percentage
    df['pct'] = df['count'] / df['count'].sum()

    # Add total_words column
    df['total_words'] = df['count'].sum()

    # Save to CSV
    df.to_csv(output_path)

    return df


def generate_all_distributions(source_dir, output_dir, filenames):
    """
    Generate word distributions for multiple volumes.

    Args:
        source_dir: Directory containing raw cleaned text files
        output_dir: Directory to save word distribution files
        filenames: List of filenames to process

    Returns:
        int: Number of files successfully generated
    """
    os.makedirs(output_dir, exist_ok=True)

    successful = 0
    failed = []

    print("\n" + "="*60)
    print("GENERATING WORD DISTRIBUTIONS FROM RAW TEXT")
    print("="*60)
    print(f"Source: {source_dir}")
    print(f"Output: {output_dir}")
    print(f"Files to process: {len(filenames)}\n")

    for filename in tqdm(filenames, desc="Generating distributions"):
        source_path = os.path.join(source_dir, filename)
        output_path = os.path.join(output_dir, filename)

        try:
            if not os.path.exists(source_path):
                failed.append((filename, "Source file not found"))
                continue

            df = generate_word_distribution(source_path, output_path)
            successful += 1

        except Exception as e:
            failed.append((filename, str(e)))

    print(f"\n{'='*60}")
    print(f"Generation complete!")
    print(f"  Successful: {successful}/{len(filenames)}")
    if failed:
        print(f"  Failed: {len(failed)}")
        for fname, error in failed[:5]:
            print(f"    - {fname}: {error}")
        if len(failed) > 5:
            print(f"    ... and {len(failed) - 5} more")
    print("="*60)

    return successful


def get_prob_df():
    """
    Load index of all volume word distribution files.

    Returns:
        DataFrame with columns: HTID, Filename, Path (indexed by HTID)
    """
    path = r'./word_distributions'
    U = []
    # r=root, d=directories, f = files
    for r, d, f in tqdm(os.walk(path), desc = 'get_EF_htids'):
        for file in f:
            if '.txt' in file:
                htid = file.replace(".json.bz2","").replace("+",":").replace(",",".").replace("=", "/")
                filename = file
                U.append([htid, filename, r + '/' + filename])
    UK_files = pd.DataFrame(U, columns = ["HTID", "Filename", "Path"]).set_index('HTID')
    del U
    return UK_files


if __name__ == "__main__":
    print("="*60)
    print("SENTIMENT SCORER - TESTING MODE")
    print("="*60)

    # Load dictionaries
    simple_dicts, weighted_dicts = load_dictionaries()

    print("\n" + "="*60)
    print("Simple dictionaries loaded:")
    for name, df in simple_dicts.items():
        print(f"  {name}: {len(df)} words")

    print("\nWeighted dictionaries loaded:")
    for name, df in weighted_dicts.items():
        print(f"  {name}: {len(df)} words, columns: {list(df.columns)}")

    # Load volume distributions
    print("\n" + "="*60)
    print("Loading volume word distributions...")
    DF_ids = get_prob_df()

    print(f"\nLoaded {len(DF_ids)} volume files")
    print(f"\nFirst 5 entries:")
    print(DF_ids.head())

    print("\n" + "="*60)
    print("TESTING SCORING ON SINGLE VOLUME")
    print("="*60)

    # Test scoring on first volume
    test_vol = DF_ids.iloc[0]
    print(f"\nTesting on: {test_vol['Filename']}")
    print(f"Path: {test_vol['Path']}")

    print("\n--- Simple Scoring Test ---")
    test_score = score_volume_simple(test_vol['Path'], simple_dicts['Progress'])
    print(f"Progress score: {test_score}")

    print("\n--- Weighted Scoring Test ---")
    test_score_weighted = score_volume_weighted(test_vol['Path'], weighted_dicts['APPLEBY_3vote'])
    print(f"APPLEBY_3vote score: {test_score_weighted}")

    # Score all volumes
    results = score_all_volumes(DF_ids, simple_dicts, weighted_dicts)

    # Save results
    output_path = './generated_scores.csv'
    results.to_csv(output_path)
    print(f"\nResults saved to: {output_path}")

    # Display results
    print("\n" + "="*60)
    print("GENERATED SCORES (First 5 rows)")
    print("="*60)
    print(results.head())

    # Load ground truth for comparison
    print("\n" + "="*60)
    print("COMPARING TO GROUND TRUTH")
    print("="*60)

    ground_truth = pd.read_csv('./ground_truth_scores.csv', index_col='Filename')

    # Map our column names to ground truth column names
    # Note: Industrial_June23 label in ground truth was actually generated using May24 weighted dictionary
    column_mapping = {
        'Progress': 'March2025_Progress',
        'Optimism': 'March2025_Optimism',
        'Pessimism': 'March2025_Pessimism',
        'Regression': 'March2025_Regression',
        'Main': 'March2025_MainSec_Main',
        'Secondary': 'March2025_MainSec_Progress',
        'ChatGPT_Progress': 'Aug2025_ChatGPT Progress',
        'Industrial_June23': None,  # Not used - was mislabeled
        'Industrial_May24': 'Indus_Jan2025_Industrial Scores (June 23)',  # This is the correct mapping!
        'Industrialization_Prior': 'IndusOptim_May2025_Industrialization Prior',
        'Optimism_Double_Meaning': 'IndusOptim_May2025_Optimism Double Meaning',
        'APPLEBY_3vote': 'Indus_April2025_Industrial Scores (All words)'
    }

    print("\nValidating scores against ground truth:")
    print("-" * 60)

    max_diff_overall = 0
    all_passed = True

    for our_col, gt_col in column_mapping.items():
        if gt_col is None:
            print(f"\n{our_col}: SKIPPED (no ground truth available)")
            continue

        if gt_col not in ground_truth.columns:
            print(f"\n{our_col} → {gt_col}: MISSING in ground truth")
            continue

        # Calculate difference
        diff = (results[our_col] - ground_truth[gt_col]).abs()
        max_diff = diff.max()
        max_diff_overall = max(max_diff_overall, max_diff)

        # Check if passed (within floating point precision)
        passed = max_diff < 1e-10

        status = "PASS" if passed else "FAIL"
        print(f"\n{our_col} -> {gt_col}")
        print(f"  Max difference: {max_diff:.2e}")
        print(f"  Status: {status}")

        if not passed:
            all_passed = False
            # Show which rows differ
            diff_rows = diff[diff >= 1e-10]
            if len(diff_rows) > 0:
                print(f"  Differing rows ({len(diff_rows)}):")
                for idx, val in diff_rows.head(3).items():
                    print(f"    {idx}: diff = {val:.2e}")

    print("\n" + "="*60)
    if all_passed:
        print("ALL VALIDATION TESTS PASSED!")
    else:
        print(f"VALIDATION FAILED - Max difference: {max_diff_overall:.2e}")
    print("="*60)
