#!/usr/bin/env python3
# coding: utf-8

## Author: Eduardo Coronado (Duke University)

from wordcloud import WordCloud
import matplotlib.pyplot as plt

def hdp_topics_to_wordclouds(model, topic_dict, save=False):
    '''Wrapper function that generates wordclouds for ALL topics of a tomotopy model
    
    ** Inputs **
    model: obj -> tomotopy trained model
    topic_dic: dict -> per topic, an arrays with top words and associated frequencies
    save: bool -> If the user would like to save the images
    
    ** Returns **
    wordclouds as plots
    '''
    
    wcloud = WordCloud(background_color="white")
    fig, ax = plt.subplots(1, 3, figsize=(15,4))

    cnt=0
    for k, arr in topic_dict.items():
        
        create_wordcloud(model, k, fig, ax[cnt], save)
        ax[cnt].title.set_text("Topic # " + str(k))
        cnt+=1
        
        if cnt==3:
            cnt=0
            fig, ax = plt.subplots(1, 3, figsize=(15,4))
    
    
              

def create_wordcloud(model, topic_idx, fig, ax, save=False):
    '''Wrapper function that generates individual wordclouds from topics in a tomotopy model
    
    ** Inputs **
    model: obj -> tomotopy trained model
    topic_idx: int -> topic index
    fig, ax: obj -> pyplot objects from subplots method
    save: bool -> If the user would like to save the images
    
    ** Returns **
    wordclouds as plots'''
    wcloud = WordCloud(background_color='white')
    
    topic_freqs = dict(model.get_topic_words(topic_idx))
    
    img = wcloud.generate_from_frequencies(topic_freqs)
    
    ax.imshow(img, interpolation='bilinear')
    ax.axis('off')
    
    if save:
        extent = ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted())
        img_name = "wcloud_topic_" + str(topic_idx) +'.png'
        plt.savefig(''.join(['imgs/',img_name]), bbox_inches=extent.expanded(1.1, 1.2))
        
