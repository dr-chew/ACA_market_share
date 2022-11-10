library(tidyverse)
require(readxl)

price_munging <- function(){

  # Read in pricing files found here: https://www.healthcare.gov/health-and-dental-plan-datasets-for-researchers-and-issuers/

  prices2022 <- read_excel("C:/Program Files/R/test/ACA/prices/2022_prices.xlsx", skip = 1, col_names = TRUE) %>%
    mutate(year = 2022) %>%
    select(year, 'State Code':'Rating Area', 'Premium Adult Individual Age 40')
  prices2021 <- read_excel("C:/Program Files/R/test/ACA/prices/2021_prices.xlsx", col_names = TRUE) %>%
    mutate(year = 2021) %>%
    select(year, 'State Code':'Rating Area', 'Premium Adult Individual Age 40')
  prices2020 <- read_excel("C:/Program Files/R/test/ACA/prices/2020_prices.xlsx", col_names = TRUE) %>%
    mutate(year = 2020) %>%
    select(year, 'State Code':'Rating Area', 'Premium Adult Individual Age 40')
  prices2019 <- read_excel("C:/Program Files/R/test/ACA/prices/2019_prices.xlsx", sheet = 2, skip = 1, col_names = TRUE) %>%
    mutate(year = 2019) %>%
    select(year, 'State Code':'Rating Area', 'Premium Adult Individual Age 40')
  prices2018 <- read_excel("C:/Program Files/R/test/ACA/prices/2018_prices.xlsx", col_names = TRUE) %>%
    mutate(year = 2018) %>%
    select(year, 'State Code':'Plan Type', 'Rating Area', 'Premium Adult Individual Age 40')
  prices2017 <- read_excel("C:/Program Files/R/test/ACA/prices/2017_prices.xlsx", col_names = TRUE) %>%
    mutate(year = 2017) %>%
    select(year, 'State Code':'Rating Area', 'Premium Adult Individual Age 40')
  prices2016 <- read_excel("C:/Program Files/R/test/ACA/prices/2016_prices.xlsx", col_names = TRUE) %>%
    mutate(year = 2016,
           'HIOS Issuer ID' = str_sub(`Plan ID (Standard Component)`, end = 5)) %>%
    select(year, 'State Code':'Rating Area','HIOS Issuer ID', 'Premium Adult Individual Age 40')
  prices2015 <- read_excel("C:/Program Files/R/test/ACA/prices/2015_prices.xlsx", col_names = TRUE) %>%
    mutate(year = 2015,
           'HIOS Issuer ID' = str_sub(`Plan ID (standard component)`, end = 5)) %>%
    select(year, State:'Rating Area', 'HIOS Issuer ID', 'Premium Adult Individual Age 40') %>%
    rename('State Code' = 'State',
           'County Name' = 'County',
           'Plan ID (Standard Component)' = 'Plan ID (standard component)')

  later_years <- bind_rows(prices2022, prices2021, prices2020, prices2019, prices2018, prices2017) %>%
    select(-`Standardized Plan Design`) %>%
    mutate(`HIOS Issuer ID` = as.character(`HIOS Issuer ID`))

  # Create a lookup that uses later years' pricing files to fill in missing FIPS codes in 2015/2016

  fips_to_county <- later_years %>%
    select('State Code', 'FIPS County Code', 'County Name') %>%
    unique()

  # Join the FIPS lookup using county names

  early_years <- bind_rows(prices2015, prices2016) %>%
    left_join(fips_to_county)

  # Test to make sure that all FIPS codes are accounted for, since county names can be unreliable

  # test <- filter(prices1516, is.na(`FIPS County Code`)) %>%
  #   select('State Code', 'County Name', 'FIPS County Code') %>%
  #   unique()

  prices <- bind_rows(later_years, early_years) %>%
    rename(state = 'State Code',
           fips = 'FIPS County Code',
           county = 'County Name',
           metal = 'Metal Level',
           issuer = 'Issuer Name',
           hios = 'HIOS Issuer ID',
           plan = 'Plan ID (Standard Component)',
           rating_area = "Rating Area",
           price = 'Premium Adult Individual Age 40') %>%
    select(year, state, rating_area, fips, county, issuer, hios, metal, price) %>%
    filter(!is.na(price)) # this step removes "child-only" plans that, for obvious reasons, don't have prices for a 40-year-old.

  rm(list = setdiff(ls(), "prices"))

  comp <- prices %>%
    # We can combine bronze and expanded bronze, because exp bronze is uncommon and similar to bronze
    mutate(metal = ifelse(metal == "Expanded Bronze", "Bronze", metal)) %>%
    # find the lowest price by metal for each carrier in each market
    group_by(year, state, rating_area, fips, county, issuer, metal) %>%
    filter(price == min(price)) %>%
    unique() %>%
    # rank competitors in each market x metal combination
    group_by(year, state, rating_area, fips, county, metal) %>%
    mutate(ranks = rank(price, ties.method = "first"))

  # find the lowest price in each metal/county
  # all non-lowest price competitors will be compared to this price

  lowest <- comp %>%
    filter(ranks == 1) %>%
    select(year:county, metal, price) %>%
    rename(l_price = price)

  # find the second lowest price in each metal/county
  # all lowest price competitors will be compared to this price
  second <- comp %>%
    filter(ranks == 2) %>%
    select(year:county, metal, price) %>%
    rename(sl_price = price)

  # join lowest and second lowest back on to the comp dataset
  price_pos <- comp %>%
    left_join(lowest) %>%
    left_join(second) %>%
    # filter out any county/metal combinations where there is only one carrier
    filter(!is.na(sl_price)) %>%

    # calculate price position:

    # lowest competitor gets a negative price position:
      # lowest - second lowest

    # non-lowest competitor gets a positive price position:
      # non-lowest - lowest
    mutate(price_pos = case_when(
      ranks == 1 ~ price - sl_price,
      ranks != 1 ~ price - l_price,
      TRUE ~ 9999
    )) %>%
    # clean up unneeded columns
    select(-l_price, -sl_price) %>%
    group_by(year, state, rating_area, fips, county, issuer, hios) %>%
    pivot_wider(names_from = metal, values_from = c(price, price_pos, ranks))

  # save(price_pos, file = "price_pos.RDS")

  rm(list = setdiff(ls(), "price_pos"))

  # load("prices/price_pos.RDS")

  return(price_pos)
  
}