# EXAMPLE 1b: SIMPLE LINEAR REGRESSION WITH UNKNOWN STANDARD DEVIATION
# In this example, we fit a simple linear regression model of the form y = beta * x + noise.
# We assume the noise to follow a normal distribution with mean 0 and standard deviation sigma, i.e., N(0, sigma).
# Accordingly, given beta, y ~ N(beta * x, sigma). (You can check this fact using the concepts from MIE236.)

# clear workspace and screen
rm(list=ls())
cat("\f")

# set working directory (you should change it appropriately)
base_dir = "/Users/singal/Desktop/Columbia/year3/summer/iid/tutorials/2018_09_stanBasics/"
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
model_bayesian = stan_model(file = "ex1b.stan")

# prepare data for stan
data_stan = list(n, x, y)

# fit the model (we usually use 4 chains and 1000 iterations for technical reasons; remind me to give you some intuition)
fit_bayesian = sampling(model_bayesian, data = data_stan, chains = 4, iter = 1000)

# print the summary of the fit (remind me to walk over this when we chat next)
print(fit_bayesian, digits = 2, pars = c("beta", "sigma"))

# plot the posterior distribution of beta
plot(fit_bayesian, pars = c("beta", "sigma"), show_density = TRUE)

# posterior "samples" of beta
fit_extract = extract(fit_bayesian, permuted = TRUE)
beta_samples = fit_extract$beta # when we chat, remind me to tell you why beta_samples is of length 2000
sigma_samples = fit_extract$sigma

# mean and sd of beta_samples (compare this with the summary output we printed a few lines above)
mean(beta_samples)
sd(beta_samples)

# mean and sd of sigma_samples (compare this with the summary output we printed a few lines above)
mean(sigma_samples)
sd(sigma_samples)

# histogram (compare this with the posterior distribution of beta we plotted a few lines above)
hist(beta_samples)
hist(sigma_samples)
