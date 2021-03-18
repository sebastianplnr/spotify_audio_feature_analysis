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
  select(country, date, year, week, rank, valence) %>%
  mutate(reversed_rank = 201 - rank, weighted_valence = valence * reversed_rank) %>% 
  group_by(country, year, week) %>% 
  summarise(avg_weighted_valence = mean(weighted_valence))


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


valence_line_plot = combined_data %>%
  filter(country == "United States" | country == "United Kingdom" | country == "Germany") %>% 
  
  ggplot(aes(year_week, proportion_of_deviation, colour = country)) + geom_line() +
  
  theme_classic() +
  theme(panel.grid.major = element_line(size = 0.1, colour = "gray"),
        plot.title = element_text(size = 18, face = "bold")) +
  
  scale_x_date(name = "", date_breaks = "2 month", date_labels = "%b %Y") +
  scale_y_continuous(name = "Deviation from expected valence",
                     labels = scales::percent_format(accuracy = 1L),
                     limits = c(-0.25, 0.25)) +
  scale_colour_discrete(name = "Country") +
  
  labs(title = "Valence during Covid-19 times",?
       subtitle = "Based on Spotify's weekly top 200 songs")

ggsave("figures/valence.png", test2, width = 10, height = 6)


# smoothing the proportion of deviation
models = combined_data %>%
  tidyr::nest(-country) %>%
  dplyr::mutate(
    # Perform loess calculation on each country
    m = purrr::map(data, loess,
                   formula = proportion_of_deviation ~ as.numeric(year_week), span = 0.2),
    # Retrieve the fitted values from each model
    fitted = purrr::map(m, `[[`, "fitted")
  )

# Apply fitted y's as a new column
results = models %>%
  dplyr::select(-m) %>%
  tidyr::unnest()


# heat map for smoothed data
# valence_heatmap = 
results %>%
  filter(country != "Cyprus", year_week < "2021-02-05") %>%
  ggplot(aes(year_week, country, fill = fitted)) +
  geom_tile(color="white") +
  
  scale_fill_gradientn(colours = c("#971D2B", "#FDFDC3", "#2B653C"),
                       values = c(0, 0.5, 1),
                       limits = c(-0.26, 0.26),
                       labels = scales::percent_format(accuracy = 1L),
                       name = "Deviation from\nexpected valence") +
  
  scale_x_date(name = "",
               date_breaks = "2 month",
               date_labels = "%b %Y",
               expand = c(0,0),
               sec.axis = dup_axis()) +
  
  labs(title = "Happiness Difference by Country and Week in 2020 compared to previous Years",
       subtitle = "Average difference between 2020 predicted and actual happiness scores",
       caption = "", x = "", y = "") +
  
  theme_classic() +
  
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank())

valence_heatmap
ggsave("figures/valence_heatmap.png", valence_heatmap, width = 15, height = 13)

valence_heatmap_html = ggplotly(valence_heatmap)
valence_heatmap_html



# smoothed heat map
x = loess(deviation_in_percent ~ as.numeric(year_week2), degree = 0, span = 0.1, data = test3)$fitted

test3 %>% ggplot(aes(year_week2, country, fill = x)) + geom_tile() +
  scale_fill_gradientn(colours = c("#971D2B", "#FDFDC3", "#2B653C"), values = c(0, 0.5, 1), limits = c(-0.16, 0.16))
  

