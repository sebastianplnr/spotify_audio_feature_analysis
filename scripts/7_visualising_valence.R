library("tidyverse")
library("data.table")
library("plotly")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/"
setwd(file_path)

# set working directory PRIOR to loading "here"
library("here")

# import data
data = data.frame(fread(here("data", "6_predicted_valence.csv")))

# converting variables to the right type
data$country = as.factor(data$country)
data$date = as.Date(data$date)


# smoothing the proportion of deviation
models = data %>%
  nest(-country) %>%
  mutate(m = map(data, loess, formula = proportion_of_deviation ~ as.numeric(date), span = 0.2), # loess per country
         fitted = map(m, `[[`, "fitted")) # retrieve fitted values from each model


# apply fitted y's as a new column
results = models %>%
  select(-m) %>%
  unnest()


# ordering countries loosely by proximity
level_ordered = c("Global", "New Zealand", "Australia", "Philippines", "Hong Kong SAR China", "Japan", "Singapore", "Malaysia", "Vietnam", "Thailand", "Taiwan", "Indonesia", "Israel", "Turkey", "Greece", "Cyprus", "Bulgaria", "Hungary", "Czechia", "Romania", "Poland", "Slovakia", "Austria","Luxembourg", "Switzerland", "Italy", "Germany", "Netherlands", "Belgium", "France", "Spain", "Portugal", "United Kingdom", "Ireland", "Denmark", "Norway", "Sweden", "Finland", "Latvia", "Lithuania", "Estonia", "South Africa", "Iceland", "United States", "Canada", "Mexico", "Dominican Republic", "Guatemala", "El Salvador", "Honduras", "Nicaragua", "Costa Rica", "Panama", "Colombia", "Ecuador", "Peru", "Bolivia", "Chile", "Brazil", "Paraguay", "Argentina", "Uruguay")
results$country = factor(results$country, levels = level_ordered)


# heat map for smoothed data
valence_heat_map = results %>%
  filter(country != "Cyprus", date < "2021-02-05") %>% # exclude cyprus due to skewing the results
  
  ggplot(aes(date, country, fill = fitted)) +
  geom_tile(color = "white") +
  
  scale_x_date(date_breaks = "1 month",
               date_labels = "%b %y",
               expand = c(0,0),
               sec.axis = dup_axis()) +
  
  scale_y_discrete(limits = rev) +
  
  scale_fill_gradientn(colours = c("#971D2B", "#FDFDC3", "#2B653C"),
                       values = c(0, 0.5, 1),
                       limits = c(-0.27, 0.27),
                       labels = scales::percent_format(accuracy = 1L),
                       name = "Deviation from\nexpected valence",
                       guide = guide_legend(title.position = "top",
                                            label.position = "bottom")) +
  
  labs(title = "Valence got low, low, low, low, low, low, low, low",
       subtitle = "Based on Spotify's weekly top 200 songs per country",
       caption = "Source: https://spotifycharts.com/regional, 12.02.2021",
       x = "", y = "") +
  
  theme_classic() +
  
  theme(plot.title = element_text(size = 18, face = "bold"),
        plot.margin = margin(t = 1, r = 1.5, l = 0.5, unit = "cm"),
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position = "top",
        legend.justification = "right",
        legend.direction = "horizontal",
        legend.title.align = 1,
        legend.key.width = unit(1, unit = "cm"),
        legend.key.height = unit(0.2, unit = "cm"),
        legend.spacing.x = unit(0, unit = "cm"),
        legend.margin = margin(t = -1.4, unit = "cm"),
        legend.box.margin = margin(b = -0.5, unit = "cm"))

valence_heat_map

ggsave(here("figures", "valence_heat_map.png"), valence_heat_map, width = 10, height = 11)

# valence_heat_map_html = ggplotly(valence_heat_map)
# valence_heat_map_html


# line plot
valence_line_plot = data %>%
  filter(country == "United States" | country == "United Kingdom" | country == "Germany") %>% 
  
  ggplot(aes(date, proportion_of_deviation, colour = country)) +
  geom_line() +
  
  scale_x_date(date_breaks = "2 month",
               date_labels = "%b %y") +
  
  scale_y_continuous(labels = scales::percent_format(accuracy = 1L),
                     limits = c(-0.25, 0.25)) +
  
  scale_colour_discrete(name = "") +
  
  labs(title = "",
       subtitle = "Based on Spotify's weekly top 200 songs per country",
       caption = "Source: https://spotifycharts.com/regional, 12.02.2021",
       x = "", y = "Deviation from expected valence") +
  
  theme_classic() +
  
  theme(plot.title = element_text(size = 18, face = "bold"),
        plot.margin = margin(t = 1, r = 1, b = 1, l = 1, unit = "cm"),
        panel.grid.major = element_line(size = 0.1, colour = "gray"),
        legend.position = "top",
        legend.justification = "right",
        legend.text = element_text(size = 11),
        legend.direction = "horizontal",
        legend.margin = margin(t = -0.7, b = 0, unit = "cm"),
        legend.box.margin = margin(b = -0.1, unit = "cm"))

valence_line_plot

ggsave(here("figures", "valence_line_plot.png"), valence_line_plot, width = 10, height = 6)



