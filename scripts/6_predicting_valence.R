library("tidyverse")
library("data.table")
library("countrycode")
library("lubridate")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/"
setwd(file_path)

library("here") # set working directory PRIOR to loading "here".

data = data.frame(fread(here("data", "5_clean_data.csv"), colClasses = c("week" = "character"))) # week as character such that the leading zero is not lost as it is important for further analysis and visualisation in particular

# converting variables to the right type
data$date = as.Date(data$date)
data$week = as.factor(data$week)
data$country = as.factor(data$country)


# reducing data to essential variables such that it is smaller and therefore easier to handle
reduced_weighted_data = data %>%
  select(country, date, year, week, rank, valence) %>%
  mutate(reversed_rank = 201 - rank, weighted_valence = valence * reversed_rank) %>% 
  group_by(country, year, week) %>% 
  summarise(weighted_valence = mean(weighted_valence))


# train model to predict 2020 valence scores which will serve as baseline to compare the actual 2020 data against
lm_valence_formula = as.formula(weighted_valence ~ year + week + country + year:country + week:country)

training_data = reduced_weighted_data %>% filter(year < 2020, week != 53)
test_data = reduced_weighted_data %>% filter(year >= 2020, week != 53)


# basic linear modelling and predicting
lm_valence = lm(lm_valence_formula, data = training_data)
weighted_valence_pred = predict(lm_valence, newdata = test_data)


# merged actual and predicted data sets 
combined_data = cbind(test_data, data.frame(weighted_valence_pred))


# (re-)calculate date variable such that a continuous x-axis can be plotted
combined_data$date = make_date(year = combined_data$year) + weeks(combined_data$week)


# calculate difference between baseline (i.e. predicted valence) and actual valence
combined_data = combined_data %>%
  mutate(difference = weighted_valence - weighted_valence_pred,
         proportion_of_deviation = difference/weighted_valence_pred) %>%
  select(country, date, weighted_valence, weighted_valence_pred, difference, proportion_of_deviation)
  

combined_data = data.frame(combined_data)


write.csv(combined_data, here("data", "6_predicted_valence.csv"), row.names = FALSE)
