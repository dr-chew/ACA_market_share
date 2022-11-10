library(tidyverse)
require(readxl)

signup_munging <- function(){

# Load and initial cleanup of carrier-level enrollment by metal by county
# Miraculously, CMS has been consistent with formatting of these files!

# This type of data is typically released on a two-year lag, and is therefore
# not as current as pricing or market-level enrollment

# Note that CMS protects enrollees' privacy by suppressing enrollment counts when
# there are fewer than ~10 enrollees in a category.  This is represented by a "*".
# Here, we convert the enrollment to numeric to force *'s into NA's and later replace
# all NA's with zeroes.

# This process creates a lot of warnings, which we will temporarily suppress.
defaultW <- getOption("warn")
options(warn = -1)

#function to rename columns, and get rid of pesky *'s
cleanup <- function(x){
  x <- x %>%
    rename(state = State,
           fips = 'County FIPS Code',
           hios = 'Issuer HIOS ID',
           signups = 'Ever Enrolled') %>%
    select(year, state, fips, hios, signups) %>%
    mutate(signups = as.numeric(signups),
           signups = ifelse(is.na(signups), 0, signups),
           hios = as.numeric(hios))
}

signups_2020 <- read_excel("C:/Program Files/R/test/ACA/signups/signups_2020.xlsx", skip = 1, col_names = TRUE, sheet = 2) %>%
  mutate(year = 2020) %>%
  cleanup()


signups_2019 <- read_excel("C:/Program Files/R/test/ACA/signups/signups_2019.xlsx", skip = 1, col_names = TRUE, sheet = 2) %>%
  mutate(year = 2019) %>%
  cleanup()

signups_2018 <- read_excel("C:/Program Files/R/test/ACA/signups/signups_2018.xlsx", skip = 1, col_names = TRUE, sheet = 2) %>%
  mutate(year = 2018) %>%
  cleanup()

signups_2017 <- read_excel("C:/Program Files/R/test/ACA/signups/signups_2018.xlsx", skip = 1, col_names = TRUE, sheet = 2) %>%
  mutate(year = 2017) %>%
  cleanup()

signups_2016 <- read_excel("C:/Program Files/R/test/ACA/signups/signups_2018.xlsx", skip = 1, col_names = TRUE, sheet = 2) %>%
  mutate(year = 2016) %>%
  cleanup()

signups_2015 <- read_excel("C:/Program Files/R/test/ACA/signups/signups_2018.xlsx", skip = 1, col_names = TRUE, sheet = 2) %>%
  mutate(year = 2015) %>%
  cleanup()


# reset warnings to default
options(warn = defaultW)

# bind all years' data together
signups <- bind_rows(signups_2015, signups_2016, signups_2017, signups_2018, signups_2019, signups_2020)

# save(signups, file = "signups.RDS")

rm(list = setdiff(ls(), "signups"))

  
# load("signups/signups.RDS")

return(signups)

  }