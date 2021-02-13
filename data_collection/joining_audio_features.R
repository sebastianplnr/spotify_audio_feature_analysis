library("tidyverse")

audio_features = read_csv("audio_features.csv")
audio_features = data.frame(audio_features)

colnames(audio_features)[13] = "Song.ID"

joined_data = left_join(combined_data, audio_features, by = "Song.ID")
selected_data = joined_data %>% select("Country":"tempo")

write.csv(selected_data, "selected_data.csv")