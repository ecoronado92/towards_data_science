#!/usr/bin/env python3
# coding: utf-8

## Author: Eduardo Coronado (Duke University)

import pandas as pd
import spacy
import re
import nltk

from gensim.utils import simple_preprocess
from gensim.models import Phrases
from gensim.models.phrases import Phraser

from nltk.corpus import stopwords


def run_preprocess(news, min_token_len=3, rm_accent=True, bigram_min_cnt=5, bigram_thresh=100,
                   extra_stops=['from','subject','re', 'edu','use'],
                   postags=['NOUN','VERB','ADV','ADJ']):

    '''Function wrapper to preprocess the 20Newsgroup dataset and generate ready to model results
    
    *** Inputs**
    news:obj -> 20Newsgroup object from sklearn (i.e. 20fetch...)
    min_token_len: int -> tokens less than this number are excluded during tokenization
    rm_accent : bool -> flag whether to remove deaccents
    bigram_min_cnt: int -> ignore all words and bigrams with total collected count lower than this value
    bigram_thresh: int -> threshold for building phrases, higher means fewer phrases
    extra_stops: list -> extra stopwords to ignore asidr from NLTK default
    postags:list -> words/bigrams to include based on POS (part-of-speech)
    
    ** Returns**
    df: Master df with 20newgroup data and labels
    word_list_lemmatized: list -> list of lists w/ lemmatized bigrams 
    '''
    
    ### Setting up stopwords and Spacy
    nltk.download('stopwords', quiet=True)
    st_words = stopwords.words('english')
    st_words.extend(extra_stops)
    
    # Build master dataframe
    df = pd.DataFrame([news.target, news.data]).T
    df = df.set_index(0)

    df = pd.concat([df, pd.Series(news.target_names)],axis=1, join="inner")
    df.reset_index(inplace=True)
    df.columns = ["topic_id", "content", "topic_name"]

    # Convert values to list
    doc_list = df.content.values.tolist()

    # Remove email signs, newlines, single quotes
    doc_list = [re.sub(r'\S*@\S*\s?', '', txt) for txt in doc_list]
    doc_list = [re.sub(r'\s+', ' ', txt) for txt in doc_list]
    doc_list = [re.sub(r"\'", "", txt) for txt in doc_list]

    # Tokenize based on min_token_len and deaccent flags
    print("Tokenizing...\n")
    word_list = [simple_preprocess(txt, deacc=rm_accent, min_len=min_token_len) for txt in doc_list]
     
    # Create bigram models
    bigram = Phrases(word_list, min_count=bigram_min_cnt, threshold=bigram_thresh) # use original wordlist to build model
    bigram_model = Phraser(bigram)
    
    # Remove stopwords
    print("Removing Stopwords...\n")
    word_list_nostops = [[word for word in txt if word not in st_words] for txt in word_list]
    
    # Implement bigram models
    print("Create bigrams...\n")
    word_bigrams = [bigram_model[w_vec] for w_vec in word_list_nostops] # implement it in the list w/ no stopwords
    
    # Lemmatize POS-tags to keep
    print("Lemmatizing, keeping " + ",".join(postags)+ " POS tags...\n")
    word_list_lemmatized = lemmatize(word_bigrams, ptags=postags)

    print("Done preprocessing " + str(df.shape[0]) + " documents")
    return df, word_list_lemmatized
    

# Helper function    
def lemmatize(word_list, ptags):
    '''Lemmatizes words based on allowed postags, input format is list of sublists 
       with strings'''
    spC = spacy.load('en_core_web_sm')
    lem_lists =[]
    for vec in word_list:
        sentence = spC(" ".join(vec))
        lem_lists.append([token.lemma_ for token in sentence if token.pos_ in ptags])
    
    return lem_lists