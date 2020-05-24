# Hierarchical Dirichlet Process Implementation 

Repo contains an example implementing an HDP Model on the 20 Newsgroup Dataset to infer topics using the `tomotopy` library.

This example covers basic preprocessing steps, model training, and model comparison and evaluation vs. the MALLET LDA model.

## Dependencies
Prior to diving into the Jupyter notebook you should install some dependencies. 

First, you can install PyPI ones by running the following line of code in a terminal window
```
pip3 install -r requirements.txt
```

We will also need to download the MALLET LDA binary with the following set of terminal commands
```
curl -O http://mallet.cs.umass.edu/dist/mallet-2.0.8.zip
unzip mallet-2.0.8.zip
rm mallet-2.0.8.zip
```

## Main Content

- **hdp_example.ipynb**: Main notebook with code related to article

- **scripts/**: Folder with main scripts used in above notebook

## Additional Content

- **models/**: Folder with pre-saved `tomotopy` models used in article to compare coherences

- **imgs/**: Folder with topic  wordclouds from the best HDP `tomotopy` model (it made it easier to check them vs the true labels)

- **objective_topic_labels.ipynb**: Additional notebook to play around with a `tomotopy` method that automatically labels topics

- **additional_data**: NIPS abstract data to test out