# Spotify Audio Feature Analysis

The repository contains all necessary tools to understand and replicate the project. The scripts and data sets are numbered corresponding to the following steps and their outputs. Both R and Python were used as each of them possesses unique strengths and limitations. Each script and dataset has a number corresponding to the steps discribed below e.g. Step 1, scraping the charts, has a scripted and output dataset labled with a "1" followed by a descriptive name.

### Step 1 (in Python)
Scrape Spotify charts (here: all possible countries, top 200, weekly) and save data per country as csv. (Update 2021-05-23: unfortunately, Spotify seem to have revoked permission for querying the source code of their webpage or at least through the "requests" library)

### Step 2 (in R)
Import all countries data sets, merge them, identify unique song IDs, create chunks of 100 song IDs (to use server requests as efficiently as poosible) and save them as a csv.

### Steps 3 (in Python)
Query songs' audio features through Spotify API using song IDs and save them as a csv.

### Step 4 (in R)
Join the charts with the audio features.

### Step 5 (in R)
Preparing the data. That is excluding the NAs (only few), selecting the relevant columns and weighting the audio features accordingly to their charts reverse rank.

### Step 6 (in R)
Building a linear model based on the years 2017, 2018 and 2019 to predict the 2020 valence. These predictions serve as a baseline to compare the actual 2020 scores against.

### Step 7 (in R)
Visualising the relative difference between predicted and actual scores for valence.

### Step 8 (in R)
Writing the project report which is identical to the index page for the *GitHub Page*.


Extending the project by correlating the observed differences with e.g., number of Covid cases or (excess) deaths, or degree of restrictions or movement activity would be very interesting.
