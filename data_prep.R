data_prep <- function(){
  
  data <- prices %>%
    # filter out years for which there is no carrier-level enrollment available
    filter(year %in% signups$year) %>%
    left_join(mkt, by = c("year", "state", "fips")) %>%
    left_join(signups %>% mutate(hios = as.character(hios)), by = c("year", "state", "fips", "hios")) %>%
    # use carrier enrollment to impute missing market-level enrollment
    group_by(year,state,rating_area,fips,county) %>%
    mutate(carrier_tot = sum(signups, na.rm=TRUE)) %>%
    ungroup() %>%
    # often the sum of carrier enrollment exceeds market enrollment
    # we will use the greater of the two amounts
    mutate(mkt_total = ifelse(carrier_tot > mkt_total, carrier_tot, mkt_total),
           # fill in missing carrier enrollment with zeroes
           # enrollment is < 10 enrollees, so not likely to be impactful
           signups = ifelse(is.na(signups), 0, signups),
           # calculate market share
           mkt_share = signups / mkt_total,
           mkt_share = ifelse(signups == 0, 0, mkt_share))
    
  # Feature engineering to roll local issuers up to their national parent carriers
  data2 <- data %>%
    mutate(carrier = case_when(
      
      grepl("aetna", issuer, ignore.case = TRUE) ~ "Aetna",
      
      grepl("anthem", issuer, ignore.case = TRUE) ~ "Anthem",
      
      grepl("celtic", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("ambetter", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("Absolute Total Care, Inc", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("Sunflower State", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("health net", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("healthnet", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("SilverSummit", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("illinicare", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("Ambetter from Buckeye Health", issuer, ignore.case = TRUE) ~ "Ambetter",
      grepl("Buckeye Community Health", issuer, ignore.case = TRUE) ~ "Ambetter",
      
      grepl("alliant", issuer, ignore.case = TRUE) ~ "Alliant",
      
      grepl("blue", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("premera", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("Florida Health Care Plans", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("health first", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("Wellmark", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("HMO Louisiana", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("Highmark", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("bcbs", issuer, ignore.case = TRUE) ~ "Blue",
      grepl("Keystone Health", issuer, ignore.case = TRUE) ~ "Blue",
      
      grepl("bright", issuer, ignore.case = TRUE) ~ "Bright Health",
      
      grepl("caresource", issuer, ignore.case = TRUE) ~ "CareSource",
      
      grepl("cigna", issuer, ignore.case = TRUE) ~ "Cigna",
      
      grepl("Christus", issuer, ignore.case = TRUE) ~ "Christus",
      
      grepl("coventry", issuer, ignore.case = TRUE) ~ "Coventry",
      
      grepl("cox", issuer, ignore.case = TRUE) ~ "Cox",
      
      grepl("harvard", issuer, ignore.case = TRUE) ~ "Harvard",
      
      grepl("HMSA", issuer, ignore.case = TRUE) ~ "HMSA",
    
      grepl("Health Alliance", issuer, ignore.case = TRUE) ~ "Health_Alliance",
      
      grepl("humana", issuer, ignore.case = TRUE) ~ "Humana",
      
      grepl("geisinger", issuer, ignore.case = TRUE) ~ "Geisinger",
      
      grepl("kaiser", issuer, ignore.case = TRUE) ~ "Kaiser",
      
      grepl("mclaren", issuer, ignore.case = TRUE) ~ "McLaren",
      
      grepl("medica", issuer, ignore.case = TRUE) ~ "Medica",
      
      grepl("medmutual", issuer, ignore.case = TRUE) ~ "MedMutual",
      
      grepl("meridian", issuer, ignore.case = TRUE) ~ "Meridian",
      
      grepl("moda", issuer, ignore.case = TRUE) ~ "Moda",
      
      grepl("molina", issuer, ignore.case = TRUE) ~ "Molina",
      
      grepl("oscar", issuer, ignore.case = TRUE) ~ "Oscar",
      
      grepl("physicians", issuer, ignore.case = TRUE) ~ "PHP",
      
      grepl("Priority Health", issuer, ignore.case = TRUE) ~ "Spectrum",
      grepl("Total Health Care USA, Inc.", issuer, ignore.case = TRUE) ~ "Spectrum",
      
      grepl("qc", issuer, ignore.case = TRUE) ~ "QualChoice",
      grepl("qualchoice", issuer, ignore.case = TRUE) ~ "QualChoice",

      grepl("quartz", issuer, ignore.case = TRUE) ~ "Quartz",
      
      grepl("united", issuer, ignore.case = TRUE) ~ "United",
      grepl("All Savers", issuer, ignore.case = TRUE) ~ "United",
      
      grepl("Vantage Health", issuer, ignore.case = TRUE) ~ "Vantage",
      
      grepl("wellfirst", issuer, ignore.case = TRUE) ~ "WellFirst",
      
      TRUE ~ issuer),
      carrier = gsub(" ", "_", carrier),
      # Create a carrier-state dummy variable
      car_state = as.factor(paste0(carrier, "_", state))) %>%
      select(year:county, carrier, car_state, issuer:mkt_share) %>%
      # For simplicity's sake, we're going to exclude extremely small carriers
      group_by(car_state) %>%
      mutate(count = n()) %>%
      filter(count >= 10) %>%
      select(-count) %>%
      filter(mkt_share > 0) %>%
      filter(!is.na(price_pos_Silver)) %>%
      # Because carriers aren't required to offer bronze plans, we're going to
      # assign NA's an extremely unfavorable price position for modeling purposes.
      mutate(price_pos_Bronze = ifelse(is.na(price_pos_Bronze), -200, -1 * price_pos_Bronze),
             price_pos_Silver = -1 * price_pos_Silver)
  
  return(data2)
  
  rm(data)
  
}
