library(tidyverse)
library(brms)

# Load and standardize data
bounce_data <- bounce_data <- read_csv("../../data/bounce_rates_sim.csv", 
                                       col_types = cols() )  %>% 
  mutate(county = as.factor(county)) %>% 
  mutate(std_age = scale(age))

# Allocate CDF value mean vector for each iteration
cdf_vals <- rep(0,613)
pdraw <- matrix(0, 613, 3000)

# Fit first LOO model (i.e. without 1st value)
tmp_data <- bounce_data[-1,]

bayes_rintercept <- brm(bounce_time ~ std_age + (1|county),
                        data = tmp_data,
                        prior = c(prior(normal(200, 1), class = Intercept), # intercept prior
                                  prior(normal(4, 1), class = b), # fixed effects prior
                                  prior(normal(0, 100), class = sigma), # population variance
                                  prior(normal(0, 10), class = sd)), # i.e. tau, group variance
                        warmup = 500, # burn-in
                        iter = 2000, # number of iterations
                        chains = 2,  # number of MCMC chains
                        control = list(adapt_delta = 0.95)) 


pdraw[1,] <- posterior_predict(bayes_rintercept, 
                           newdata = bounce_data[1,])

cdf_vals[1] <- mean(pdraw[i,] <= bounce_data$bounce_time[1])



for (i in 2:613){
  tmp_data <- bounce_data[-i,]
  
  bayes_rintercept <- update(bayes_rintercept, newdata = tmp_data)
  
  
  pdraw[i,] <- posterior_predict(bayes_rintercept, 
                             newdata = bounce_data[i,])
  
  cdf_vals[i] <- mean(pdraw[i,] <= bounce_data$bounce_time[i])  
  
}


