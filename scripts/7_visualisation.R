library("tidyverse")
library("plotly")

# set new working directory
file_path = "/Users/sebastian/Documents/Uni/Sheffield (MSc)/2. Semester/Data Analysis and Viz/spotify_audio_feature_analysis/"
setwd(file_path)

library("here") # set working directory PRIOR to loading "here".


reduced_data = read.csv(here("data", "5_reduced_weighted_data.csv"))
reduced_data = reduced_data %>% filter(Date >= as.Date("2020-01-01"))
reduced_data$Country = str_to_title(reduced_data$Country) # capitalise countries' first letters


weighted_audio_features_pred = read.csv(here("data", "6_weighted_audio_features_pred.csv"))
weighted_audio_features_pred = weighted_audio_features_pred %>% select(-X) # exclude the index prior to merging
combined_data = cbind(reduced_data, weighted_audio_features_pred)


# valence graph
valence_heatmap = 
  combined_data %>%
    mutate(delta = weighted_valence - weighted_valence_pred) %>%
    group_by(Country, Week) %>%
    summarise(difference = round(mean(delta), digits = 2)) %>% 
    ggplot(aes(Week, Country, fill = difference)) + geom_tile() +
    scale_fill_gradientn(colours = c("#A51516", "white", "#006D2C"),
                         values = c(0, 0.5, 1),
                         limits = c(-25, 25)) +
    theme_classic() +
    labs(title = "Happiness Difference by Country and Week in 2020 compared to previous Years",
         subtitle = "Average difference between 2020 predicted and actual happiness scores",
         caption = "") +
    theme(plot.title = element_text(size = 18, face = "bold"))

valence_heatmap

valence_heatmap_html = ggplotly(valence_heatmap)
valence_heatmap_html

ggsave("figures/valence_heatmap.png", valence_heatmap, width = 15, height = 13)
# save interactive heat map manually through the export button in the plot previewer


# danceability graph
danceability_heatmap = 
  combined_data %>%
    mutate(delta = weighted_danceability - weighted_danceability_pred) %>%
    group_by(Country, Week) %>%
    summarise(difference = round(mean(delta), digits = 2)) %>% 
    ggplot(aes(Week, Country, fill = difference)) + geom_tile() +
    scale_fill_gradientn(colours = c("#A51516", "white", "#006D2C"),
                         values = c(0, 0.5, 1),
                         limits = c(-25, 25)) +
    theme_classic() +
    labs(title = "Danceability Difference by Country and Week in 2020 compared to previous Years",
         subtitle = "Average difference between 2020 predicted and actual danceability scores",
         caption = "") +
    theme(plot.title = element_text(size = 18, face = "bold")) 

danceability_heatmap

danceability_heatmap_html = ggplotly(danceability_heatmap)
danceability_heatmap_html

ggsave("figures/danceability_heatmap.png", danceability_heatmap, width = 15, height = 13)
# save interactive heat map manually through the export button in the plot previewer


# energy graph
energy_heatmap = 
  combined_data %>%
    mutate(delta = weighted_energy - weighted_energy_pred) %>%
    group_by(Country, Week) %>%
    summarise(difference = round(mean(delta), digits = 2)) %>% 
    ggplot(aes(Week, Country, fill = difference)) + geom_tile() +
    scale_fill_gradientn(colours = c("#A51516", "white", "#006D2C"),
                         values = c(0, 0.5, 1),
                         limits = c(-25, 25)) +
    theme_classic() +
    labs(title = "Energy Difference by Country and Week in 2020 compared to previous Years",
         subtitle = "Average difference between 2020 predicted and actual energy scores",
         caption = "") +
    theme(plot.title = element_text(size = 18, face = "bold"))

energy_heatmap

energy_heatmap_html = ggplotly(energy_heatmap)
energy_heatmap_html

ggsave("figures/energy_heatmap.png", energy_heatmap, width = 15, height = 13)
# save interactive heat map manually through the export button in the plot previewer


# tempo graph
tempo_heatmap = 
  combined_data %>%
    mutate(delta = weighted_tempo - weighted_tempo_pred) %>%
    group_by(Country, Week) %>%
    summarise(difference = round(mean(delta), digits = 2)) %>% 
    ggplot(aes(Week, Country, fill = difference)) + geom_tile() +
    scale_fill_gradientn(colours = c("#A51516", "white", "#006D2C"),
                         values = c(0, 0.5, 1),
                         limits = c(-3600, 3600)) +
    theme_classic() +
    labs(title = "Tempo Difference by Country and Week in 2020 compared to previous Years",
         subtitle = "Average difference between 2020 predicted and actual tempo scores",
         caption = "") +
    theme(plot.title = element_text(size = 18, face = "bold"))

tempo_heatmap

tempo_heatmap_html = ggplotly(tempo_heatmap)
tempo_heatmap_html

ggsave("figures/tempo_heatmap.png", tempo_heatmap, width = 15, height = 13)
# save interactive heat map manually through the export button in the plot previewer

