# EXAMPLE 2: Beta-Bernoulli Model
# In this example, we fit a simple linear regression model of the form y = beta * x + noise.
# We assume the noise to follow a normal distribution with mean 0 and standard deviation sigma, i.e., N(0, sigma).
# Accordingly, given beta, y ~ N(beta * x, sigma). (You can check this fact using the concepts from MIE236.)

# In this example, we fit a simple linear regression model of the form y = bernoulli(p) + noise
# We assume the noise to follow a normal distribution with mean 0 and standard deviation sigma, i.e., N(0, sigma).
# Accordingly, given beta, y ~ N(beta * x, sigma). (You can check this fact using the concepts from MIE236.)

# clear workspace and screen
rm(list=ls())
cat("\f")

# set working directory (you should change it appropriately)
base_dir = "/Users/nicolewongsoo/Documents/Fourth\ Year\ Uni/Thesis/workspace/Tutorial\ 2"
setwd(base_dir)

# load libraries and set rstan's parallel computing options
library("rstan")
library("ggplot2")
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# set random seed
set.seed(1)

# true values of beta and sigma
# ex. 100 trials --> 70 are success (1), 30 are failures
#
p = 0.7

# input data
n = 100

# generate simulated output data
x = rbinom(n, 1, p)
mean(x)
 
# plot the simulated data
plot(x, pch = 20)

# compile the model present in the stan file (this might take a minute or two)
# FYI: you can open the stan file in RStudio to see the underlying code
model_bayesian = stan_model(file = "ex2_beta11.stan")

# prepare data for stan
data_stan = list(n, x)

# fit the model (we usually use 4 chains and 1000 iterations for technical reasons; remind me to give you some intuition)
fit_bayesian = sampling(model_bayesian, data = data_stan, chains = 4, iter = 1000)

# print the summary of the fit (remind me to walk over this when we chat next)
print(fit_bayesian, digits = 2, pars = c("p"))

# plot the posterior distribution of beta
plot(fit_bayesian, pars = c("p"), show_density = TRUE)

# posterior "samples" of p
fit_extract = extract(fit_bayesian, permuted = TRUE)
p_samples = fit_extract$p # when we chat, remind me to tell you why beta_samples is of length 2000

# mean and sd of beta_samples (compare this with the summary output we printed a few lines above)
mean(p_samples)
sd(p_samples)

# histogram of beta_samples (compare this with the posterior distribution of beta we plotted a few lines above)
hist(p_samples)


# PRACTICE QUESTIONS -----------------------------------------------------------------------------
# (a) From what we know about the beta-bernoulli model from Chapter 2 of the BDA textbook, what can we say about the posterior distribution of p? Can you verify it empirically?
# posterior variance smaller than prior variance
# posterior distribution is the same distribution type as the prior distribution --> dunno how to verify that empirically
# how to verify: given prior is beta(1,1) and likelihood is bernoulli is 68 heads and 32 tails 
# --> posterior is beta(68+a, 32+b) where a and b are the prior
  
# once nice way to verify --> match the moments (mean is the first, standard deviation the second)
# other way --> take samples from the histogram --> use rbinom --> and see if they are similar

# (b) Change the prior in the stan code from beta(1, 1) to flat. How does the posterior look now?
# The same
# beta(1,1) identical to uniform from 0-1
# as a and b increase beta(1, 1) vs beta(100,100) has the same expected value, but you have more information
# as a and b go to infinity but are of equal magnitude, p will converge to 0.5
# note: a and b are strictly positive
  
# (c) Change the prior to beta(1, 100000). How does the posterior look now? Why?
  
# (d) Can you give an intuitive description of what the beta(a, b) prior means in this context where a and b are some fixed constants (say a = b = 1)? 
# Hint: Think about the expression for the posterior distribution and see how a and b influence the posterior.

