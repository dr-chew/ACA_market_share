library(tidyverse)
require(readxl)
library(ggplot2)
library(lme4)

# Prep market enrollment --------------------------------------------------

# Here we're collecting data describing the number of people enrolled across
# all carriers in each county for each year.  This will serve as the denominator
# for our market share calculations
source("enrollment_munging.R")
mkt <- enrollment_munging()
glimpse(mkt)


# Prep carrier-level enrollment -------------------------------------------

# This section collects carrier-specific enrollment for each county from 2014-
# 2020.  This will serve as our numerator for the market share calculations.
source("signup_munging.R")
signups <- signup_munging()
glimpse(signups)

# Prep price position data ------------------------------------------------

# Next we need pricing data.  Because the enrollment data is so course, we'll
# need to aggregate to relative price positions for each carrier's metal tier
# at the county level for each year in the dataset.
source("price_munging.R")
prices <- price_munging()
glimpse(prices)


# Combine data sets and prep for modeling ---------------------------------

# We're almost there!
source("data_prep.R")
data <- data_prep()
glimpse(data)

# Now that we have the data prepped, let's look at some visuals.
# Checking out data from Ohio, we can see that market shares tend to cluster
# along different silver price position slopes for each carrier.
plot_OH_state()

# In Florida, it's easy to see that the Blues can sustain higher membership with
# a less competitive price position
plot_FL_state()

# This next step builds a logistic GLM using silver price position, bronze price
# position, and carrier x state dummy variables
source("model_build.R")
glm.mod <- build_model()
summary(glm.mod)

# We can now build illustrative plots that show, when controlling for price
# position, the implicit differences in the competitiveness of each carrier
plot_illustrative()

# However, it's worth noting that this model isn't great in its current state.
# If we look at county-level plots of a single carrier, Ambetter, it's obvious
# that there is a lot of county-level variation that this model can't account for.

plot_OH_amb()
plot_FL_amb()

# The best way to deal with this is to build a model that incorporates county-
# level variation without over-fitting.  This could be through a non-linear mixed-
# effect model, or a carefully constructed tree-based model.

# Ultimately, however, much better models can be constructed with first-party
# data, which not only allows for metal-tier-level projections, but also
# delineation into separate models which project retention of existing members
# and acquisition of new members.