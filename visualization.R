library(tidyverse)
library(ggplot2)
library(knitr)

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
    scale_color_manual(values=c("#CC00CC", "#0000FF", "#FF3300", "#006600")) + 
    ggtitle("Market share of major carriers in Florida by county from 2014-2020")
}

plot_OH_amb <- function(){
data %>% 
  filter(state == "OH") %>%
  filter(carrier == "Ambetter") %>%
    mutate(Predicted = predict(glm.mod, type = "response", newdata = .)) %>%
    ggplot(., aes(price_pos_Silver, mkt_share)) +
    geom_point(aes(price_pos_Silver, mkt_share, color = "Actual"), size = 2) +
    geom_point(aes(price_pos_Silver, Predicted, color = "Predicted"), size = 2) +
  ylab("Market share") +
  xlab("Silver price position (positive is an advantage)") +
  theme(legend.position = "left") + 
  theme(legend.title = element_blank()) + 
  theme_minimal() +
  ggtitle("Market share of Ambetter in Ohio by county, 2014-2020") +
  scale_color_discrete(name="")
}

plot_TX_amb <- function(){
  data %>% 
    filter(state == "TX") %>%
    filter(carrier == "Ambetter") %>%
    mutate(Predicted = predict(glm.mod, type = "response", newdata = .)) %>%
    ggplot(., aes(price_pos_Silver, mkt_share)) +
    geom_point(aes(price_pos_Silver, mkt_share, color = "Actual"), size = 2) +
    geom_point(aes(price_pos_Silver, Predicted, color = "Predicted"), size = 2) +
    ylab("Market share") +
    xlab("Silver price position (positive is an advantage)") +
    theme(legend.position = "left") + 
    theme(legend.title = element_blank()) + 
    theme_minimal() +
    ggtitle("Market share of Ambetter in Texas by county, 2014-2020") +
    scale_color_discrete(name="")
}

plot_illustrative <- function(){
  
  viz_dat1 <- data.frame(price_pos_Silver = seq(-100, 100, 1),
                         Carrier = "Ambetter",
                         car_state = "Ambetter_FL",
                         price_pos_Bronze = 50)
  
  viz_dat2 <- data.frame(price_pos_Silver = seq(-100, 100, 1),
                         Carrier = "Blue",
                         car_state = "Blue_FL",
                         price_pos_Bronze = 50)
  
  viz_dat3 <- data.frame(price_pos_Silver = seq(-100, 100, 1),
                         Carrier = "Oscar",
                         car_state = "Oscar_FL",
                         price_pos_Bronze = 50)
  
  viz_dat4 <- data.frame(price_pos_Silver = seq(-100, 100, 1),
                         Carrier = "Molina",
                         car_state = "Molina_FL",
                         price_pos_Bronze = 50)
  
  
  viz_dat <- rbind(viz_dat1, viz_dat2, viz_dat3, viz_dat4)
  viz_dat$Prediction <- predict(glm.mod, viz_dat, type = "response")
  
  rm(viz_dat1, viz_dat2, viz_dat3, viz_dat4)
  
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

table_illustrative <- function(){
  ill_dat <- data.frame(price_pos_Silver = 10,
                         Carrier = c("Ambetter", "Blue", "Oscar", "Molina"),
                         car_state = c("Ambetter_FL", "Blue_FL", "Oscar_FL", "Molina_FL"))
  
  ill_dat$share <- paste0(round(predict(glm.mod, ill_dat, type = "response")*100),"%")
  
  parity_table <- ill_dat %>%
    mutate(State = "Florida") %>%
    select(State, Carrier, price_pos_Silver, share) %>%
    rename(`Predicted Share` = share,
           `Silver Price Position` = price_pos_Silver)
  
  return(kable(parity_table))
}