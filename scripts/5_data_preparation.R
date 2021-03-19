library("tidyverse")
library("data.table")
library("lubridate")
library("aweek")
library("countrycode")


# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/"
setwd(file_path)


# set working directory PRIOR to loading "here".
library("here")


# import data
data = data.frame(fread(here("data", "4_charts_audio_features.csv")))


# select relevant columns, change to all lower case names
data = data %>%
  select(-c("X", "X1", "Index", "type":"time_signature")) %>% 
  rename("country" = "Country", "song" = "Song", "artist" = "Artist", "date" = "Date", "song_id" = "Song.ID", "streams" = "Streams", "rank" = "Rank")


# clean the country names 
data$country = countrycode(data$country, "country.name", "country.name", warn = FALSE, nomatch = NULL)
data$country = ifelse(data$country == "global", "Global", data$country)


# check na's. nine cases does seem to have randomly missing audio data which is, hence, excluded
data = data %>% filter(!is.na(valence))


# 674 songs have not songs and artist name, however, all other data points are seemingly perfectly fine and, hence, data is kept
filter(data, is.na(data))


# create year and week variable (with leading zeros for the single digit weeks)
data$year = isoyear(ymd(data$date))

data$week = date2week(data$date)
data$week = substr(data$week, 7, 8) # extract week number


# order columns
column_order = c("song", "artist", "country", "date", "year", "week", "streams", "rank", "danceability", "energy", "key", "loudness", "mode", "speechiness", "acousticness", "instrumentalness", "liveness", "valence", "tempo", "song_id")
data = data[, column_order]


# having to exclude some country due to a lack of data (spotify started collecting charts later some countries than others)
data = data %>% filter(country != "Andorra", country != "Russia", country != "Ukraine", country != "India",
                       country != "Egypt", country != "Morocco", country != "United Arab Emirates",
                       country != "Saudi Arabia")


# export cleaned data
write.csv(data, here("data", "5_clean_data.csv"), row.names = FALSE)


# reducing data to essential variables such that it is smaller and therefore easier to handle
reduced_weighted_data = data %>%
  select(country, date, week, rank, streams, valence, danceability, energy, tempo, song_id) %>%
  mutate(reversed_rank = 201 - rank,
         weighted_valence = valence * reversed_rank,
         weighted_danceability = danceability * reversed_rank,
         weighted_energy = energy * reversed_rank,
         weighted_tempo = tempo * reversed_rank)

write.csv(reduced_weighted_data, here("data", "5_reduced_weighted_data.csv"), row.names = FALSE)

