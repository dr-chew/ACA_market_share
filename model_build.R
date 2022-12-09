library(tidyverse)
library(lme4)
library(stats)
library(caret)

build_model <- function(){
  
mod_data <- data


glm.mod <- glm(mkt_share ~ price_pos_Silver * car_state,
                data = mod_data,
                family = binomial)


return(glm.mod)

}



prep_predictions <- function(){
  
  mod_data$Pred_glm <- predict(glm.mod, type = "response")
  
  return(mod_data)
  
}



prep_lines <- function(){
  
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
  
  return(viz_dat)
  rm(viz_dat1, viz_dat2, viz_dat3, viz_dat4)
  
}
