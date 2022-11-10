ACA Marketplace Market Share Modeling 
Aaron Olcerst, Ph.D.
aolcerst@gmail.com
11/10/2022

Scope

The purpose of this project is to create a model that uses pricing data to explain variations in market share among Affordable Care Act (ACA) marketplace health insurance carriers.  

Background

The ACA marketplace is a highly competitive environment.  Each year, carriers spend months developing prices and tweaking plan design for the upcoming year.  They’ll look to expand their service area, if they can sign network contracts in time, or perhaps pull out of a volatile market where they are priced inadequately and cannot recover.  Generally, prices are developed with little information about how other carriers plan to price. Later in the process, tidbits of information get released (depending on the state) leading up to the full release of information shortly before open enrollment begins, usually on November 1st.  By then it’s usually way too late to make changes.

Once open enrollment begins, carriers cross their fingers that their current members stick with them and hope that they attract enough new enrollees to hit their financial projections.  Because each year is something of a fresh start, membership can change dramatically year over year.  Once open enrollment has ended, however, enrollment is largely stable, with some members’ coverage lapsing each month and more joining because of a qualifying life event.  Discussion of those small monthly changes are outside of the scope of this project, which focuses on large-scale membership changes at open enrollment.

These models can be used to predict future market share of a carrier given expected pricing data for all carriers in a market, of course, but there are other interesting applications as well.  Each carrier’s brand strength, value prop, and network (among other variables, all of which are difficult to explicitly represent in a model) contribute to differences in price elasticity, i.e. how quickly market share changes with prices, and we can get a better sense of that metric once we build the model.  Lastly, we can also inform strategic decisions regarding markets worth targeting for membership with investment in the form of price decreases, and where we might be able to shore up risk with price increases without losing too many members.

Data

This project uses publicly available data from CMS.  Most state’s marketplaces are handled through the federal exchange, Healthcare.gov, but several states have opted to create their own marketplaces.  These are known as state-based exchanges (SBEs).  SBE’s data is usually not included in data released from CMS.  It’s usually out there somewhere, but it’s hard to find and isn’t included in this exercise for that reason.

Pricing data for the upcoming plan year is released shortly before each open enrollment period, usually in October.  Pricing data is highly granular, and is represented at the carrier x county x plan level.  When you actually choose an insurance plan on the exchange, the price usually increases or decreases based on your age and whether you’re a smoker.  Because we’re looking at market-level effects, we’re going to stick with the standardized rates for a 40 year old, which is already included in the data.
Source of data: https://www.healthcare.gov/health-and-dental-plan-datasets-for-researchers-and-issuers/

Unfortunately, carrier-level enrollment data is not nearly as granular in the public data releases.  Although it would be fun and enlightening to have plan-level enrollment for each carrier, all we get is total enrollment at the end of open enrollment by carrier by county.  We don’t know what plans people choose, and we don’t know how many of those enrollees are renewing their coverage with that carrier from the prior year as opposed to choosing their coverage anew.
Source of data: https://www.cms.gov/CCIIO/Resources/Data-Resources/issuer-level-enrollment-data

Approach

Our response variable will be each carrier’s total market share in each county, because that’s as granular as we can get with public data.

Because of the limited enrollment data, we’re going to have to aggregate pricing data.  Plans are categorized into five tiers - catastrophic, bronze, silver, gold, and platinum.  Carriers are usually only required to offer silver plans, which are middle-of-the-road plans that offer both premium subsidies and cost sharing subsidies for low-income members.  Because of these subsidies, enrollment is heavily concentrated into low-cost silver plans at the national level, although some counties have larger bronze markets.

We’re therefore going to use the lowest bronze and silver price for each carrier in each county to calculate price positions.  We can also use a carrier by state dummy variable to allow our model to capture the intangibles like brand and network, which will allow us more clearly demonstrate the differences in price elasticity for each carrier. 

Now that we have our variables chosen, it’s important to realize that this will need to be a non-linear model.  The reason for this is pretty simple.  If a carrier’s prices are neck-and-neck with a competitor’s prices, then each dollar improvement is likely to have a meaningful impact on market share.  On the other hand, if a carrier is already far cheaper than all competitors, then changing the price by a few dollars won’t have much of an impact.  The demand curve, then, is going to be sigmoid and can be represented by a logistic model.

For this exercise, we’re going to use a simple logistic GLM.  Our response variable will be market share at the carrier x county x year level.  We’ll use bronze and silver price positions, each interacted with our carrier-state dummy variable, as our independent variables.

Organization

The script is organized into modules.  Each stage of data prep has its own module, and then there’s an additional module (data_prep) that combines the prior stages.  Modeling and visualization are given their own modules as well.  Finally, there’s a “main script” that calls all the modules, or an RMarkdown that performs the same function, but looks spiffier.
