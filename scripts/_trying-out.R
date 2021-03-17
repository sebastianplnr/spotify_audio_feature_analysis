library("tidyverse")
library("countrycode")
library("lubridate")
library("plotly")

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



valence_heatmap = data2 %>%
  mutate(continent = as.factor(countrycode(country, "country.name", "continent", warn = FALSE, nomatch = NULL))) %>% 
  filter(continent == "Europe", country != "Cyprus") %>% 
  mutate(difference = round((valence_pred - avg_weighted_valence), digits = 2),
         deviation_in_percent = round((difference/valence_pred)*100, digits = 2)) %>%
  ggplot(aes(year_week2, country, fill = deviation_in_percent)) +
  geom_tile() +
  scale_fill_gradientn(colours = c("#A51516", "white", "#006D2C"),
                       values = c(0, 0.5, 1),
                       limits = c(-27, 27)) +
  theme_classic() +
  labs(title = "Happiness Difference by Country and Week in 2020 compared to previous Years",
       subtitle = "Average difference between 2020 predicted and actual happiness scores",
       caption = "") +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.text.x = element_text(angle = 45, vjust = 0.5))

valence_heatmap

valence_heatmap_html = ggplotly(valence_heatmap)
valence_heatmap_html




test2 = data2 %>%
  filter(country == "United States" | country == "United Kingdom" | country == "Germany") %>% 
  mutate(difference = valence_pred - avg_weighted_valence,
         deviation_in_percent = round((difference/valence_pred), digits = 2)) %>%
  ggplot(aes(year_week2, deviation_in_percent, colour = country)) +
  geom_line() +
  theme_classic() +
  theme(panel.grid.major = element_line(size = 0.1, colour = "gray"),
        plot.title = element_text(size = 18, face = "bold")) +
  scale_x_date(name = "",
               date_breaks = "2 month",
               date_labels = "%b %Y") +
  scale_y_continuous(name = "Deviation from expected valence",
                     labels = scales::percent_format(accuracy = 1L),
                     limits = c(-0.25, 0.25)) +
  scale_colour_discrete(name = "Country") +
  labs(title = "Valence during Covid-19 times",
       subtitle = "Based on Spotify's weekly top 200 songs")

ggsave("figures/valence.png", test2, width = 10, height = 6)




x = loess(valence_pred ~ as.numeric(year_week2), degree = 0, span = 0.1, data = data2)$fitted

ggplot(data2, aes(year_week2, x)) + geom_line()








