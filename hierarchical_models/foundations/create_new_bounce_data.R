library(tidyverse)
set.seed(2020)

# Load original data
bounce_data <- read_csv("../data/bounce_rates_original.csv", col_types = cols() )

# Compute mean and stdev for each gorup
suff_stats <- bounce_data %>% 
  group_by(county) %>% 
  summarise(mu_bounce=mean(bounce_time), sd_bounce = sd(bounce_time),
            mu_age = mean(age), sd_age = sd(age))

# Initialize df
sim_df <- tibble(bounce_time = double(),
                 age = integer(),
                 county = character())

# Randomize counties, set max group size, set group samp props in relation to max grp size
county_subset <- sample(unique(bounce_data$county))
grp_size=150
props <- c(0.05, 0.15, 0.25, 0.5, 0.6, 0.75, 0.8, 1)

# Generate simulated data
for (i in 1:nrow(suff_stats)){
  
  n = grp_size*props[i]
  
  sim_times <- rnorm(n, suff_stats$mu_bounce[i], 
                      suff_stats$sd_bounce[i])
  
  sim_ages <- rnorm(n, suff_stats$mu_age[i],
                    suff_stats$sd_age[i])
  

  tmp_county = tibble(bounce_time = sim_times,
                      age = round(sim_ages),
                      county = county_subset[i])
  
  sim_df <- bind_rows(sim_df, tmp_county)
    
}

# Save as csv
write_csv(sim_df, path="../data/bounce_rates_sim.csv")
