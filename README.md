# Spotify Audio Feature Analysis

### Step 1 (performed in Python)
Scrape spotify charts (here: all countires, top 200, weekly) and save data per country as csv.

### Step 2 (performed in R)
Import all countries data set, merge them, identify unique song IDs (to minimise server requests) and save them as a csv.

### Steps 3 (performed in Python)
Query songs' audio features through Spotify API and save them as a csv.

### Step 4 (performed in R)
Join the charts data with the audio features data.
