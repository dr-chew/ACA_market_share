library(tidyverse)
library(ggplot2)

plot_OH_state <- function(){
data %>% 
  filter(state == "OH") %>%
  filter(carrier %in% c("Ambetter", "Anthem", "Molina", "Medica")) %>%
  ggplot(., aes(price_pos_Silver, mkt_share)) +
  geom_point(aes(price_pos_Silver, mkt_share, color = carrier)) +
  ylab("Market share") +
  xlab("Silver price position (positive is an advantage)") +
  theme(legend.position = "left") + 
  theme(legend.title = element_blank()) + 
  theme_minimal() +
    ggtitle("Market share of major carriers in Ohio by county from 2014-2020")
}

plot_FL_state <- function(){
  data %>% 
    filter(state == "FL") %>%
    filter(carrier %in% c("Ambetter", "Blue", "Molina", "Oscar")) %>%
    ggplot(., aes(price_pos_Silver, mkt_share)) +
    geom_point(aes(price_pos_Silver, mkt_share, color = carrier)) +
    ylab("Market share") +
    xlab("Silver price position (positive is an advantage)") +
    theme(legend.position = "left") + 
    theme(legend.title = element_blank()) + 
    theme_minimal() +
    ggtitle("Market share of major carriers in Florida by county from 2014-2020")
}

plot_OH_amb <- function(){
data %>% 
  filter(state == "OH") %>%
  filter(carrier == "Ambetter") %>%
    ggplot(., aes(price_pos_Silver, mkt_share)) +
    geom_point(aes(price_pos_Silver, mkt_share, color = county), size = 2) +
  ylab("Market share") +
  xlab("Silver price position (positive is an advantage)") +
  theme(legend.position = "left") + 
  theme(legend.title = element_blank()) + 
  theme_minimal() +
  ggtitle("Market share of Ambetter in Ohio by county, 2014-2020")
}

plot_FL_amb <- function(){
  data %>% 
    filter(state == "FL") %>%
    filter(carrier == "Ambetter") %>%
    ggplot(., aes(price_pos_Silver, mkt_share)) +
    geom_point(aes(price_pos_Silver, mkt_share, color = county), size = 2) +
    ylab("Market share") +
    xlab("Silver price position (positive is an advantage)") +
    theme(legend.position = "left") + 
    theme(legend.title = element_blank()) + 
    theme_minimal() +
    ggtitle("Market share of Ambetter in Florida by county, 2014-2020")
}

plot_illustrative <- function(){
  
  ggplot(viz_dat, aes(price_pos_Silver, Prediction)) +
    geom_point(aes(price_pos_Silver, Prediction, color = Carrier)) +
    scale_color_manual(values=c("#CC00CC", "#0000FF", "#FF3300", "#006600")) + 
    ylab("Market share") +
    xlab("Silver price position (positive is an advantage)") +
    theme(legend.position = "left") + 
    theme(legend.title = element_blank()) + 
    theme_minimal() +
    ggtitle("Predicted market share of major carriers in Florida by county across silver prices")
  
}
