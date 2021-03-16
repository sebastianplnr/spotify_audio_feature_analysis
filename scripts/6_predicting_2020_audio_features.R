# install.packages("caret")
# install.packages("tidyverse")
# install.packages("lubridate")
# install.packages("here")

library("caret")
library("tidyverse")
library("lubridate")
library("countrycode")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/"
setwd(file_path)

library("here") # set working directory PRIOR to loading "here".

my_data = read.csv(here("data", "5_clean_data.csv"))

my_data$Date = as.Date(my_data$Date)
my_data$Country = as.factor(my_data$Country)
my_data$Week = as.factor(my_data$Week)

# reducing data to essential variables such that it is smaller and therefore easier to handle
reduced_weighted_data = my_data %>%
  select(country, date, week, rank, streams, valence, danceability, energy, tempo, song_id) %>%
  mutate(reversed_rank = 201 - rank,
         weighted_valence = valence * reversed_rank # ,
         # weighted_danceability = danceability * reversed_rank,
         # weighted_energy = energy * reversed_rank,
         # weighted_tempo = tempo * reversed_rank
         )

# train model to predict 2020 valence scores which will serve as baseline to compare the actual 2020 data against
my_formula = as.formula(valence ~ week + country + week:country)

training_data = reduced_weighted_data %>% filter(Date < as.Date("2020-01-01"))
test_data = reduced_weighted_data %>% filter(Date >= as.Date("2020-01-01"))

set.seed(1000) # for reproducibility
trainControl(method = "cv", number = 10, allowParallel = TRUE) # cross-validation
trained_model = train(my_formula, data = training_data, method = "rf", trControl = tc)

valence_predicted = predict(trained_model, newdata = test_data)

## save and load data such that the model does not need to be trained every time from scratch
write.csv(valence_predicted, here("data", "valence_predicted_rf.csv"))

# valence_predicted = read.csv(here("data", "valence_predicted_rf.csv"))


# my_data_2 = my_data_test %>% filter(Date >= as.Date("2020-01-01"))
# my_data_2$valence_100 = my_data_2$valence*100
# my_data_2$valence_predicted = as.vector(valence_predicted$x)