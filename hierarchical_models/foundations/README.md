# Foundations of Hierarchical / Multilevel / Mixed Effects Models 

Repo contains foundational materials and examples implementing Bayesian and Frequentist Hierarchical models on simulated bounce rate data and a toy dataset.

The toy dataset was implemented and analyzed in Python using two packages `statsmodels` and `pymer4`, while the bounce rate dataset was implemented and analyzed in R using the `lme4` (frequentist) and `brms` (bayesian) packages.

These materials are related to the following Towards Data Science article:

## Dependencies

The Rmarkdown contains all dependencies in `R` and should install any missing ones when compiled.

For the Jupyter notebook you'll need some Python and R dependencies to run the examples, **especially using `pymer4` which is a Python wrapper of the `R` `lme4` package** (you should make sure you have R installed and the `lme4` and `lmerTest` package downloaded to run this package)


## Main Content

- **lmm_toy_example.ipynb**: Notebook covering an intuitive high-level dive into Hierarchical models using a toy example data

- **bounce_rates_example...**: Rmarkdown notebook and rendered HTML covering an intuitive analysis of a simulated dataset containing website bounce rates. 

- **create_new_bounce_data.R**:  This script generates a set of simulated data based on the orignal Kaggle dataset [found here](https://www.kaggle.com/ojwatson/mixed-models/comments)

