# Spotify Audio Feature Analysis

In December, during a virtual discussion, Spotify and its potential of assessing mood through the music briefly came up. Following the meeting, I started reading up on the topic and came across an interesting article by The Economist and a Twitter thread of its author. He had analysed the charts of the last three years and calculated the average happiness (or "valence" in Spotify's terms) per month and country. It turns out that while there is considerable variation between the countries, on average February is the "gloomiest' month of the year and July the happiest. The article had been published in February of 2020 though, and a lot has happened since then.

In Covid times, case numbers dominate our everyday lives as they inform the lastest points of action of the government. It is often criticised that governments are relying too much on these numbers and seldom consider the people's psychological states. Part of this problem is that the case numbers are much more tangible than emotion or mood, particularly at scale. So what if there was a way to evaluate mood at scale without the cost and time-consuming surveying and interviewing? This is where music is entering the stage. Assuming the type of music is indeed partly determined by our state of mind, would it not be worthwhile trying to analyse the songs we listen to?

This project seeks to visualise the difference between the predicted 2020 mood (based on the past three non-covid years) and the actual 2020 mood. Spotify, being one of the biggest players in music streaming, publishes since January 2017 the top 200 songs per week for 70 countries. They have also developed an algorithm that assigns each song a "valence", "danceability", "energy", and "tempo" score based on the song's characteristics. These scores can be queried by registered Spotify developers.

The following will describe each step of the project such that interested parties can fully understand and replicate the project. The repository contains all the necessary tools for this. The scripts and data sets are numbered corresponding to the following steps and their outputs. Both R and Python were used as each of them possesses unique strengths and limitations. 

A final thought, this project by no means aims at making inferences about the causes for the observed differences, it is merely descriptive. Given the amount of factors in play it will hardly ever be possible to make causal inferences. That being said extending the project by correlating the observed differences with e.g., number of covid cases or (excess) deaths, or degree of restrictions or movement activity would be very interesting.


### Step 1 (in Python)
Scrape Spotify charts (here: all possible countries, top 200, weekly) and save data per country as CSV.

### Step 2 (in R)
Import all countries data sets, merge them, identify unique song IDs (to minimise server requests) and save them as a CSV.

### Steps 3 (in Python)
Query songs' audio features through Spotify API using song IDs and save them as a CSV.

### Step 4 (in R)
Join the charts with the audio features.

### Step 5 (in R)
Preparing the data. That is excluding the NAs (only few), selecting the relevant columns and weighting the audio features accordingly to their charts rank (or rather their reserve rank such that song higher up in the charts are more influential).

### Step 6 (in Python)
Building a linear model based on the years 2017 to (including) 2019 to predict the 2020 audio features scores (valence, danceability, energy, tempo). These predictions serve as a baseline to compare the actual 2020 scores. 

### Step 7 (in R)
Visualising the difference between predicted and actual scores for each feature (valence, danceability, energy, tempo).
