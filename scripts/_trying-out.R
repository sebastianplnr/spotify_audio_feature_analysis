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
data$year_week = make_date(year = data$year) + weeks(data$week)
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
combined_data = cbind(test_data, data.frame(valence_pred))

# creating a year/week variable for easier calculation 
combined_data$year_week = make_date(year = combined_data$year) + weeks(combined_data$week)

combined_data = combined_data %>%
  mutate(difference = round((valence_pred - avg_weighted_valence), digits = 2),
         proportion_of_deviation = round((difference/valence_pred), digits = 2))



valence_heatmap = combined_data %>%
  
  mutate(continent = as.factor(countrycode(country, "country.name", "continent", warn = FALSE, nomatch = NULL))) %>% 
  filter(continent == "Europe", country != "Cyprus") %>% 
  
  ggplot(aes(year_week, country, fill = proportion_of_deviation*100)) + geom_tile() +
  
  scale_fill_gradientn(colours = c("#971D2B", "#FDFDC3", "#2B653C"),
                       values = c(0, 0.5, 1),
                       limits = c(-27, 27)) +
  theme_classic() +
  theme(plot.title = element_text(size = 18, face = "bold")) +
  
  labs(title = "Happiness Difference by Country and Week in 2020 compared to previous Years",
       subtitle = "Average difference between 2020 predicted and actual happiness scores",
       caption = "")

valence_heatmap

valence_heatmap_html = ggplotly(valence_heatmap)
valence_heatmap_html




valence_line_plot = combined_data %>%
  filter(country == "United States" | country == "United Kingdom" | country == "Germany") %>% 
  
  ggplot(aes(year_week, proportion_of_deviation, colour = country)) + geom_line() +
  
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
  
  labs(title = "Valence during Covid-19 times",?
       subtitle = "Based on Spotify's weekly top 200 songs")

ggsave("figures/valence.png", test2, width = 10, height = 6)




models = combined_data %>%
  tidyr::nest(-country) %>%
  dplyr::mutate(
    # Perform loess calculation on each country
    m = purrr::map(data, loess,
                   formula = proportion_of_deviation ~ as.numeric(year_week), span = .5),
    # Retrieve the fitted values from each model
    fitted = purrr::map(m, `[[`, "fitted")
  )

# Apply fitted y's as a new column
results = models %>%
  dplyr::select(-m) %>%
  tidyr::unnest()

# Plot with loess line for each group
results %>%
  filter(country != "Cyprus") %>%
  ggplot(aes(x = year_week, y = proportion_of_deviation, group = country, colour = country)) +
  geom_line(aes(y = fitted))


results %>% ggplot(aes(year_week2, country, fill = fitted)) + geom_tile() +
  scale_fill_gradientn(colours = c("#971D2B", "#FDFDC3", "#2B653C"), values = c(0, 0.5, 1), limits = c(-.25, 0.25))












x = loess(valence_pred ~ as.numeric(year_week2), degree = 0, span = 0.1, data = data2)$fitted

ggplot(data2, aes(year_week2, x)) + geom_line()



test3 = data2 %>% 
  mutate(difference = valence_pred - avg_weighted_valence,
         deviation_in_percent = round((difference/valence_pred), digits = 2))


for (country in test3$country) {
  t1 = test3 %>% filter(country == as.character(country)) %>% 
    (loess(deviation_in_percent ~ as.numeric(year_week2), degree = 0, span = 0.1, data = test3)$fitted)
  answer = append(answer, t1)
}

%>% 
  (loess(deviation_in_percent ~ as.numeric(year_week2), degree = 0, span = 0.1, data = test3)$fitted)
answer = append(answer, t1)








lapply(as.factor(test3$country), loess, test3$deviation_in_percent ~ as.numeric(test2$year_week2), degree = 0, span = 0.1)



# smoothed heat map
x = loess(deviation_in_percent ~ as.numeric(year_week2), degree = 0, span = 0.1, data = test3)$fitted

test3 %>% ggplot(aes(year_week2, country, fill = x)) + geom_tile() +
  scale_fill_gradientn(colours = c("#971D2B", "#FDFDC3", "#2B653C"), values = c(0, 0.5, 1), limits = c(-0.16, 0.16))

