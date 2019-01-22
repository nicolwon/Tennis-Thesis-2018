# EXAMPLE 1: SIMPLE LINEAR REGRESSION
# In this example, we fit a simple linear regression model of the form y = beta * x + noise.
# We assume the noise to follow a normal distribution with mean 0 and standard deviation sigma, i.e., N(0, sigma).
# Accordingly, given beta, y ~ N(beta * x, sigma). (You can check this fact using the concepts from MIE236.)

# clear workspace and screen
rm(list=ls())
cat("\f")

# set working directory (you should change it appropriately)
base_dir = "/Users/nicolewongsoo/Documents/Fourth\ Year\ Uni/Thesis/workspace/"
setwd(base_dir)

# load libraries and set rstan's parallel computing options
library("rstan")
library("ggplot2")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# set random seed
set.seed(1)

# true values of beta and sigma
beta = 10
sigma = 5

# input data
n = 10
x = seq(from = 0, to = 5, length.out = n)

# generate simulated output data
y = rnorm(n, mean = beta * x, sd = sigma)

# plot the simulated data
plot(x, y, pch = 20)

# compile the model present in the stan file (this might take a minute or two)
# FYI: you can open the stan file in RStudio to see the underlying code
model_bayesian = stan_model(file = "ex1_priorFlat.stan")

# prepare data for stan
data_stan = list(n, sigma, x, y)

# fit the model (we usually use 4 chains and 1000 iterations for technical reasons; remind me to give you some intuition)
fit_bayesian = sampling(model_bayesian, data = data_stan, chains = 4, iter = 1000)

# print the summary of the fit (remind me to walk over this when we chat next)
print(fit_bayesian, digits = 2, pars = c("beta"))

# plot the posterior distribution of beta
plot(fit_bayesian, pars = c("beta"), show_density = TRUE)

# posterior "samples" of beta
fit_extract = extract(fit_bayesian, permuted = TRUE)
beta_samples = fit_extract$beta # when we chat, remind me to tell you why beta_samples is of length 2000

# mean and sd of beta_samples (compare this with the summary output we printed a few lines above)
mean(beta_samples)
sd(beta_samples)

# histogram of beta_samples (compare this with the posterior distribution of beta we plotted a few lines above)
hist(beta_samples)


# PRACTICE QUESTIONS -----------------------------------------------------------------------------
# 1. How does the posterior of beta change as we increase n from 10 to 100? Why?

# 2. How does the posterior of beta change when we use a "weak" prior (file "ex1_priorWeak.stan")? (Try n = 10 and 100.)

# 3. Write a new stan file (name it "ex1_priorStrong.stan") in which the prior is "strong", say normal(0, 1). 
# (a) How does the posterior look when n = 10? Why?
# (b) How does it change when we increase n from 10 to 100? Why? 

# 4. Write a new stan file (name it "ex1_priorTruncated.stan") in which the prior is "truncated", say uniform(0, 10). 
# Set n = 100. How does the posterior look when we use this truncated prior? Why? 

# 5. Can you intuitively visualize the effect of (1) n and (2) prior on the posterior distribution?

# 6. In the model above, we assumed sigma to be a known parameter and hence, provided it as "data" to the stan model. 
# (a) Can you write a new stan file in which both beta and sigma are unknown parameters and we estimate them using data? 
# (b) Can you fit that model and show the summary statistics of the posteriors of both beta and sigma?

# 7. In this exercise, we will explore the beta-bernoulli model (as opposed to the simple linear regression model).
# However, we will work on this exercise after you feel comfortable with the questions above :-)

