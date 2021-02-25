library("tidyverse")
library("stringr")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis"
setwd(file_path)

library("here") # set working directory PRIOR to loading "here".

# import chart data and merge to one big dataset
file_names = dir(path = here("data", "1_charts_per_country"), pattern = "*.csv")
my_data = sapply(here("data", "1_charts_per_country", file_names), read.csv, simplify = FALSE) # file name as row name

combined_data = data.frame(do.call(rbind, my_data)) # create one data set
combined_data = rownames_to_column(combined_data, "Country") # convert row names to column


# get data in order
## extract country name from file name which includes the file path and capitalise first letter
file_path = here("data", "1_charts_per_country", "")
combined_data$Country = gsub(file_path, "", combined_data$Country, fixed = TRUE) # delete file path
combined_data$Country = gsub(".csv.([0-9]+)", "", combined_data$Country) # delete file extension
combined_data$Country = str_to_title(combined_data$Country) # overwrite old column values with clean country names
combined_data$Country = gsub("Viet_nam", "Vietnam", combined_data$Country) # fix weird spelling


## extract song ids from URL
song_id = gsub("https://open.spotify.com/track/", "", combined_data$Song.ID) # delete URL part
combined_data$Song.ID = song_id # overwrite old column values with clean song ids


# save merged and cleaned data set
write.csv(combined_data, here("data", "1_charts.csv"))


# get unique song ids and save as csv
unique_songids = unique(combined_data$Song.ID)
write.csv(unique_songids, here("data", "2_songids.csv"))


# split into chunks for more efficient querying
chunks = split(unique_songids, ceiling(seq_along(unique_songids)/100)) # 100 is the max number of song ids Spotify allows per request
chunks = lapply(chunks, glue::glue_collapse, ",", last = ",")
chunks = unlist(chunks, use.names = FALSE)
write.csv(chunks, here("data", "2_songids_chunks.csv"))
