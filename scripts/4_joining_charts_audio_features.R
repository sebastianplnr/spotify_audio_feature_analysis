library("tidyverse")
library("data.table")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis"
setwd(file_path)

library("here") # set working directory PRIOR to loading "here".

# import charts and audio feature data
charts_data = data.frame(fread(here("data", "1_charts.csv")))

audio_features = data.frame(fread(here("data", "3_audio_features.csv")))


# rename column such that data sets can be joined by an identifier variable
audio_features = audio_features %>% 
  rename("Song.ID" = "id")


# join chart data with audio feature data and select relevant variables
joined_data = left_join(charts_data, audio_features, by = "Song.ID")
selected_data = joined_data %>% select("Country":"tempo")


# summary reveals there are some NAs in the data set
summary(selected_data)


# extract song ids of NAs data such that they can be retrieved separately
na_data = charts_audio_features %>% filter(is.na(valence))
na_songids = na_data %>% select(Song.ID)

write.csv(na_songids, here("data", "4_na_songids"), row.names = FALSE)


# after retrieving missing audio features import, clean, select and filter them
additional_data = data.frame(fread(here("data", "4_missing_audio_features.csv")))

additional_data = additional_data %>% 
  rename("Index" = "X1") %>%
  select(-c("error", "audio_features")) %>%
  filter(!is.na(valence)) # 8 cases are dropped


# merge with original audio feature data set
audio_features = rbind(audio_features, substitute_data)


# merge audio feature data (now including the previously missing data and the charts data)
final_data = left_join(charts_data, audio_features, by = "Song.ID")


# remove the 9 cases that still have NA values (no apparent pattern in the missing data)
final_data = final_data %>% filter(!is.na(valence))


# export full data set
write.csv(final_data, here("data", "4_charts_audio_features.csv"), row.names = FALSE)
