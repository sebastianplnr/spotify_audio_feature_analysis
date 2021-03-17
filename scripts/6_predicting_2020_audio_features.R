library("tidyverse")
library("countrycode")
library("lubridate")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/"
setwd(file_path)

library("here") # set working directory PRIOR to loading "here".

data = read.csv(here("data", "5_clean_data.csv"), colClasses = c("week" = "character")) # week as character such that the leading zero is not lost as it is important for further analysis and visualisation in particular

# converting variables to the right type
data$date = as.Date(data$date)
data$week = as.factor(data$week)
data$country = as.factor(data$country)


# reducing data to essential variables such that it is smaller and therefore easier to handle
reduced_weighted_data = data %>%
  select(country, date, year, week, rank, valence, danceability, energy, tempo) %>%
  mutate(reversed_rank = 201 - rank,
         weighted_valence = valence * reversed_rank,
         weighted_danceability = danceability * reversed_rank,
         weighted_energy = energy * reversed_rank,
         weighted_tempo = tempo * reversed_rank) %>% 
  group_by(country, year, week) %>% 
  summarise(avg_weighted_valence = mean(weighted_valence),
            avg_weighted_danceability = mean(weighted_danceability),
            avg_weighted_energy = mean(weighted_energy),
            avg_weighted_tempo = mean(weighted_tempo))


# train model to predict 2020 valence scores which will serve as baseline to compare the actual 2020 data against
lm1_formula = as.formula(avg_weighted_valence ~ year + week + country + year:country + week:country)

training_data = reduced_weighted_data %>% filter(year < 2020, week != 53)
test_data = reduced_weighted_data %>% filter(year >= 2020, week != 53)


# basic linear modelling
lm1 = lm(lm1_formula, data = training_data)
valence_pred = predict(lm1, newdata = test_data)


# merged actual and predicted data sets 
data2 = cbind(test_data, data.frame(valence_pred))

data2$year_week2 = make_date(year = data2$year) + weeks(data2$week)

