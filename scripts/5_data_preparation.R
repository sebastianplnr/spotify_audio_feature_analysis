library("tidyverse")
library("lubridate")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/"
setwd(file_path)

library("here") # set working directory PRIOR to loading "here".

my_data = read.csv(here("data", "4_charts_audio_features.csv"))

my_data = my_data %>%
  select(-c("X", "X1", "type", "uri"))

my_data = my_data %>% filter(!is.na(valence))

my_data$Week = isoweek(ymd(my_data$Date))

my_data$Date = as.Date(my_data$Date)
my_data$Country = as.factor(my_data$Country)
my_data$Week = as.factor(my_data$Week)


# reducing data to essential variables such that it is smaller and therefore easier to handle
reduced_weighted_data = my_data %>%
  select(Country, Date, Week, valence, danceability, energy, tempo, Rank, Song.ID) %>%
  mutate(reversed_rank = 201 - Rank,
         weighted_valence = valence * reversed_rank,
         weighted_danceability= danceability * reversed_rank,
         weighted_energy = energy * reversed_rank,
         weighted_tempo = tempo * reversed_rank
         ) %>%
  filter(Country != "russian_federation", Country != "ukraine", Country != "andorra",
         Week != "53") # not consistent in the data across all 4 years

write.csv(reduced_weighted_data, here("data", "5_reduced_weighted_data.csv"))

