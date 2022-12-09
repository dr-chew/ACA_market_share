library(tidyverse)
require(readxl)

enrollment_munging = function(){
  
  # Load and initial cleanup of total enrollment by metal by county, across all carriers
  # Luckily CMS took the time to make each file beautifully unique!
  
  
  # Note that CMS protects enrollees' privacy by suppressing enrollment counts when
  # there are fewer than ~10 enrollees in a category.  This is represented by a "*".
  # Here, we convert the enrollment to numeric to force *'s into NA's and later replace
  # all NA's with zeroes.
  
  # This process creates a lot of warnings, which we will temporarily suppress.
  defaultW <- getOption("warn")
  options(warn = -1)
  
  mkt_2022 <- read_excel("enrollment/2022_enrollment.xlsx", sheet = 7, col_names = TRUE) %>%
    mutate(year = 2022) %>%
    rename(state = State,
           fips = 'County FIPS Code',
           mkt_total = 'Number of Consumers with a Marketplace Plan Selection') %>%
    select(year, state, fips, mkt_total) %>%
    mutate(mkt_total = as.numeric(gsub(",", "", mkt_total)))
  
  
  mkt_2021 <- read.csv("enrollment/2021_enrollment.csv", header = TRUE) %>%
    mutate(year = 2021) %>%
    rename(state = State_Abrvtn,
         fips = County_FIPS_Cd,
         mkt_total = Cnsmr) %>%
    select(year, state, fips, mkt_total)  %>%
    mutate(mkt_total = as.numeric(gsub(",", "", mkt_total)))
  
  mkt_2020 <- read.csv("enrollment/2020_enrollment.csv", header = TRUE) %>%
    mutate(year = 2020) %>%
    rename(state = State_Abrvtn,
           fips = Cnty_FIPS_Cd,
           mkt_total = Cnsmr) %>%
    select(year, state, fips, mkt_total) %>%
    mutate(mkt_total = as.numeric(gsub(",", "", mkt_total)))
  
  mkt_2019 <- read_excel("enrollment/2019_enrollment.xlsx", sheet = 8, col_names = TRUE) %>%
    mutate(year = 2019) %>%
    rename(state = State,
           fips = 'County FIPS Code',
           mkt_total = 'Total Number of Consumers Who Have Selected an Exchange Plan') %>%
    select(year, state, fips, mkt_total) %>%
    mutate(mkt_total = as.numeric(mkt_total))
  
  mkt_2018 <- read_excel("enrollment/2018_enrollment.xlsx", sheet = 8, col_names = TRUE) %>%
    mutate(year = 2018) %>%
    rename(state = State,
           fips = 'County FIPS Code',
           mkt_total = 'Total Number of Consumers Who Have Selected an Exchange Plan') %>%
    select(year, state, fips, mkt_total) %>%
    mutate(mkt_total = as.numeric(mkt_total))
  
  mkt_2017 <- read_excel("enrollment/2017_enrollment.xlsx", sheet = 8, col_names = TRUE) %>%
    mutate(year = 2017) %>%
    rename(state = State,
           fips = 'County FIPS Code',
           mkt_total = 'Total Number of Consumers Who Have Selected a Marketplace Plan') %>%
    select(year, state, fips, mkt_total) %>%
    mutate(mkt_total = as.numeric(mkt_total))
  
  mkt_2016 <- read_excel("enrollment/2016_enrollment.xlsx", sheet = 8, col_names = TRUE) %>%
    mutate(year = 2016) %>%
    rename(state = State,
           fips = 'County FIPS Code',
           mkt_total = 'Total Number of Consumers Who Have Selected a Marketplace Plan') %>%
    select(year, state, fips, mkt_total) %>%
    mutate(mkt_total = as.numeric(mkt_total))
  
  mkt_2015 <- read_excel("enrollment/2015_enrollment.xlsx", sheet = 8, col_names = TRUE) %>%
    mutate(year = 2015) %>%
    rename(state = State,
           fips = 'County FIPS Code',
           mkt_total = 'Total Number of Consumers Who Have Selected a Marketplace Plan') %>%
    select(year, state, fips, mkt_total) %>%
    mutate(mkt_total = as.numeric(mkt_total))
  
  # reset warnings to default
  options(warn = defaultW)
  
  # bind all years' data together
  mkt <- bind_rows(mkt_2015, mkt_2016, mkt_2017, mkt_2018, mkt_2019, mkt_2020, mkt_2021, mkt_2022) %>%
    # Filter out some summary rows from the original datasets
    filter(!grepl("represents", state)) %>%
    filter(!grepl("Total", state)) %>%
    filter(!grepl("XX", state)) %>%
    filter(!is.na(state))
  
  # replace aforementioned NA's with zeroes.
  mkt$mkt_total[is.na(mkt$mkt_total)] <- 0
  
  # save(mkt, file = "mkt.RDS")
  
  #cleanup the workspace
  rm(list = setdiff(ls(), "mkt"))

  # load("enrollment/mkt.RDS")
  
return(mkt)
}
