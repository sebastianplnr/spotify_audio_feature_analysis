library("tidyverse")

# temporarily set new working dir to import data
old_dir = getwd()
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/data"
setwd(file_path)


# import audio feature data
audio_features = read_csv("audio_features.csv")
audio_features = data.frame(audio_features)


# rename column such that data sets can be joined by an identifier variable
colnames(audio_features)[13] = "Song.ID"


# join chart data with audio feature data and select relevant variables
joined_data = left_join(combined_data, audio_features, by = "Song.ID")
selected_data = joined_data %>% select("Country":"tempo")


# export full data set
write.csv(selected_data, "selected_data.csv")


# back to old working dir
setwd(old_dir)