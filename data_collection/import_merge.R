library("tidyverse")

# temporarily set new working dir to import data
old_dir = getwd()
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/data"
setwd(file_path)


# import chart data and merge to one big dataset
file_names = dir(pattern = "*.csv")
my_data = sapply(file_names, read.csv, simplify = FALSE) # file name as row name

combined_data = data.frame(do.call(rbind, my_data)) # create one data set
combined_data = rownames_to_column(combined_data, "Country") # convert row names to column


# back to old working dir
setwd(old_dir)


# get data in order
## extract country name from file name
county_names = gsub(".csv.([0-9]+)", "", combined_data$Country) # delete file extension
combined_data$Country = county_names # overwrite old column values with clean country names

## extract song ids from url
song_id = gsub("https://open.spotify.com/track/", "", combined_data$Song.ID) # delete url part
combined_data$Song.ID = song_id # overwrite old column values with clean song ids


# get unique song ids and save as csv
unique_songids = unique(combined_data$Song.ID)
write.csv(unique_songids, "unique_songids.csv")
