import os
import sys
import unicodedata
import pycountry
import pandas as pd
from tqdm import tqdm
import multiprocessing as mp
from pathlib import Path
import logging
from htrc_features import FeatureReader
import nltk
from nltk.stem import WordNetLemmatizer, SnowballStemmer
from nltk.corpus import names, stopwords
from nltk.corpus import words as nltk_words


UK4_PATH = Path(r"E:\Documents\UKFinal\Rsync_Deduplicated")
CLEANED_PATH = Path(r"E:\Documents\UKFinal\Cleaned_Nov2024")

lemmatizer = WordNetLemmatizer()
stemmer = SnowballStemmer('english')
idx = pd.IndexSlice
pos_tags = ('NE', 'NN', 'NNP', 'NNPS', 'JJ', 'JJS', 'JJR', 'IN', 'DT', 'VB', 'VBP', 'VBZ', 'VBD', 'VBN', 'VBG', 'RB', 'RBR', 'RBS', 'RP', 'CC')
errorlog_cv = r"D:\Users\Ali\Documents\UK2 by Century\error_cleanvolume.txt" 
# Punctuation = '.,():-—;"!?•$%@“”#<>+=/[]*^\'{}_■~\\|«»©&~`£·º'
greek = 'ºªſ'
delchars = ''.join(c for c in map(chr, range(256)) if not c.isalpha())
# delchars = delchars.replace('-','')
greekcorrection = str.maketrans('ºªſβ', 'oasb')
alleraser = str.maketrans('', '', delchars)
errorlog2 = r"D:\Users\Ali\Documents\UK2 by Century\error_2.txt"

# Configure logging
logging.basicConfig(
    level=logging.ERROR,
    format='%(asctime)s - %(levelname)s - %(message)s',
    stream=sys.stderr
)

corr = pd.read_csv(r'E:\Documents\UKFinal\Dict Corrections 20241026\Master_Corrections.csv')
corr = corr.rename(columns={'lemma':'orig','correct_spelling':'stand'}).set_index('orig')
corr_set = set(corr.index)

madict = pd.read_csv(r'E:\Documents\UKFinal\Dict Corrections 20241026\MA_Dict_Final.csv')
madict = madict.set_index('orig')
madict_set = set(madict.index)  # Create a set of index values for fast membership testing

cities = pd.read_csv(r"E:\Documents\UKFinal\world_cities.csv")
cities = set(city.lower() for city in cities['name'])
                                        
countries = set([country.name.lower() for country in pycountry.countries])

continents = set(['africa', 'asia', 'europe', 'america', 'australia', 'antartica'])
                                        
# nltk.download('names')
people_names = set([name.lower() for name in names.words()])

# nltk.download('stopwords')
english_stopwords = set(stopwords.words('english'))

modern_words = set([word.lower() for word in nltk_words.words()])
                                        

stems = set([stemmer.stem(word) for word in modern_words])

days = set(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
months = set([
    "jan",
    "feb",
    "mar",
    "apr",
    "may",
    "jun",
    "jul",
    "aug",
    "sep",
    "oct",
    "nov",
    "dec"
])

def int_to_roman_lowercase(num):
    if num == 0:
        return "n"  # Special case for zero (nulla)
    
    val = [
        1000, 900, 500, 400,
        100, 90, 50, 40,
        10, 9, 5, 4,
        1
    ]
    syms = [
        "m", "cm", "d", "cd",
        "c", "xc", "l", "xl",
        "x", "ix", "v", "iv",
        "i"
    ]
    roman_num = ''
    i = 0
    while num > 0:
        for _ in range(num // val[i]):
            roman_num += syms[i]
            num -= val[i]
        i += 1
    return roman_num

# Generate list of lowercase Roman numerals from 0 to 500
roman_numerals = set([int_to_roman_lowercase(i) for i in range(501)])

stopwords_ne_ss = cities.union(countries, people_names, english_stopwords, modern_words, continents,
                               stems, days, months, roman_numerals)
stopwords_numer = english_stopwords.union(roman_numerals)


def get_EF_htids() -> pd.DataFrame:
    """
    Generate a DataFrame of HTRC Extracted Features files.

    Returns:
        pd.DataFrame: A DataFrame with columns 'HTID', 'Filename', and 'Path', indexed by 'HTID'.
    """
    def generate_files():
        total_files = sum(len(files) for _, _, files in os.walk(UK4_PATH))
        print(UK4_PATH)
        with tqdm(total=total_files, desc="Scanning files", unit=" files") as pbar:
            for r, d, f in os.walk(UK4_PATH):
                for file in f:
                    if '.json.bz2' in file:
                        htid = file.replace(".json.bz2","").replace("+",":").replace(",",".").replace("=", "/")
                        yield [htid, file, r]
                    pbar.update(1)
    
    UK_files = pd.DataFrame(generate_files(), columns=["HTID", "Filename", "Path"]).set_index('HTID')
    print(f"Found {len(UK_files)} HTRC Extracted Features files.")
    return UK_files


def getFeatureReader(final_ids):
    fr = FeatureReader(list(final_ids['Path'] + '\\' + final_ids['Filename'].replace(".bz2","")))
    return fr


def stem_lem(cleaned):
    if cleaned[1].startswith('N'):
        lemmatized = lemmatizer.lemmatize(cleaned[0], 'n')
    elif cleaned[1].startswith('V'):
        lemmatized = lemmatizer.lemmatize(cleaned[0], 'v')
    elif cleaned[1].startswith('J'):
        lemmatized = lemmatizer.lemmatize(cleaned[0], 'a')
    elif cleaned[1].startswith('R'):
        lemmatized = lemmatizer.lemmatize(cleaned[0], 'r')
    else:
        lemmatized = lemmatizer.lemmatize(cleaned[0])
    if lemmatized == cleaned[0]:
        lemmatized = lemmatizer.lemmatize(cleaned[0]) # if pos does not help lemmatizing, then try without pos
    if lemmatized == cleaned[0]:
        stem = stemmer.stem(cleaned[0])# if lemmatizing without POS is still not helping, try stemming
        if stem in stopwords_ne_ss: # if stem is in dictionary, return stem
            return stem
    return lemmatized

def trans(row):
    string = row.name[0]
    string = string.translate(alleraser)
    string = string.translate(greekcorrection)
    string = string.replace('ﬁ', 'fi')
    string = string.replace('ﬂ', 'fl')
    string = string.replace('ﬅ', 'ft')
    string = string.replace('ﬃ', 'ffi')
    string = string.replace('ﬀ', 'ff')
    string = string.replace('ﬄ', 'ffl')
    string = unicodedata.normalize('NFKC', string)
    return pd.Series({'corrected': string})

def clean_punctuation(words):
    words_copy = words.copy()
    words_copy[['corrected']] = words_copy.apply(trans, axis=1)
    words_copy = words_copy.reset_index().drop(columns='lowercase')
    return words_copy[words_copy['corrected'].map(len) > 2].sort_values('count', ascending=False)

def ma_search(row):
    try:
        if row in madict_set:
            correction = madict.loc[row]
            return correction.stand
        else:
            return row
    except Exception as e:    
        print(e)
        return 'error'

def stem(row):
    return stemmer.stem(row)

    
def corr_search(row):
    try:
        if row in corr_set:
            correction = corr.loc[row]
            return correction.stand
        else:
            return row
    except Exception as e:    
        print(e)
        return 'error'
        
def correct_words(vol):
    tl = vol.tokenlist(pages=False, case=False, section='body')
    tl.index = tl.index.droplevel(0)
    clean_tl = tl.loc[idx[:, pos_tags],]
    clean_tl = clean_punctuation(clean_tl)
    # clean_tl.loc[:, 'corrected'] = clean_tl.corrected.map(corr_search)
    clean_tl = clean_tl.assign(corrected=clean_tl.corrected.map(corr_search))
    clean_tl = clean_tl.groupby(['corrected','pos']).sum()
    clean_tl = clean_tl[clean_tl['count'] >= 2]
    clean_tl = clean_tl.loc[~clean_tl.index.get_level_values('corrected').isin(stopwords_numer)]
    # clean_tl.loc[:, 'lemma'] = clean_tl.index.map(stem_lem)
    clean_tl = clean_tl.assign(lemma=clean_tl.index.map(stem_lem))
    clean_tl = clean_tl.groupby('lemma').sum()
    clean_tl = clean_tl.loc[~clean_tl.index.get_level_values('lemma').isin(stopwords_numer)]
    clean_ss = clean_tl.loc[~clean_tl.index.get_level_values('lemma').isin(madict_set)]
    clean_ma = clean_tl.loc[clean_tl.index.get_level_values('lemma').isin(madict_set)]
    # clean_ma.loc[:, 'corrected_ma'] = clean_ma.index.get_level_values('lemma').map(ma_search)
    clean_ma = clean_ma.assign(corrected_ma=clean_ma.index.get_level_values('lemma').map(ma_search))
    clean_ma = clean_ma.groupby('corrected_ma').sum()
    clean_ma = clean_ma.loc[~clean_ma.index.get_level_values('corrected_ma').isin(stopwords_numer)]
    clean_ss_ma = pd.concat([clean_ss, clean_ma])
    # clean_ss_ma.loc[:,'stem'] = clean_ss_ma.index.map(stem)
    clean_ss_ma = clean_ss_ma.assign(stem=clean_ss_ma.index.map(stem))
    clean_ss_ma = clean_ss_ma.groupby('stem').sum()
    return clean_ss_ma

def process_volume(vol):
    save_path = CLEANED_PATH / f"{vol.id.replace(':','+').replace('/','=')}.txt"
    try:
        clean_df = correct_words(vol)
        if clean_df is None:
            logging.warning(f"No clean data for volume {vol.id}")
            return None
        clean_df = clean_df.sort_values('count', ascending=False)
        with open(save_path, 'w', encoding='utf8') as output:
           for item, value in clean_df.iterrows():
               to_print = [(item + ' ') * int(value[0])]
               output.write(str(to_print[0]))
        return clean_df
    except Exception as e:
        logging.error(f"Error processing volume {vol.id}: {e}")
        return None

def process_volume_wrapper(vol):
    return process_volume(vol)

def CleanAndWrite(fr):
    total_volumes = len(fr)
    with mp.Pool(processes=mp.cpu_count()) as pool:
        results = list(tqdm(
            pool.imap(process_volume_wrapper, fr.volumes()),
            total=total_volumes,
            desc="Processing volumes"
        ))
    
    
def main():
    print("Starting HTRC Extracted Features processing...")
    EF_ids = get_EF_htids()
    print("Sample of EF_ids:")
    print(EF_ids.head())
    
    print("\nInitializing FeatureReader...")
    corpus = getFeatureReader(EF_ids)
    print(f"FeatureReader initialized with {len(corpus)} volumes.")
    
    print("\nCleaning and writing volumes...")
    CleanAndWrite(corpus)
    

if __name__ == "__main__":
    mp.freeze_support()  # This is necessary for Windows
    main()


