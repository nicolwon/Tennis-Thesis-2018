# clear workspace and screen
rm(list=ls())
cat("\f")

# set working directory (you should change it appropriately)
base_dir = "/Users/nicolewongsoo/Documents/Fourth\ Year\ Uni/Thesis/workspace/Main"
setwd(base_dir)

# load libraries and set rstan's parallel computing options
library("rstan")
library("ggplot2")
# install.packages("data.table") 
library(data.table)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# if single file
# load data and sumamarize
# french_open_2011 = read.csv("data/2011-frenchopen-points.csv", header = TRUE)
# summary(french_open_2011)
# attributes(french_open_2011)
# data = french_open_2011

# if all files
filenames = list.files("data", pattern="*points.csv", full.names=TRUE)
data = rbindlist(lapply(filenames,fread), fill=TRUE)

# if single match
# match = subset(french_open_2011, match_id == "2011-frenchopen-1101")
# data = match

# retrieve point data and summarize
winner = data$PointWinner
# winner = match_1101$PointWinner
summary(winner)

# if point is 0 or NA, this means there was no previous point/previous point was the last point of another match
# --> ignore this index because it was the last point in the match, and there's no next point
winner = replace(winner, winner==0, NA)

# let perspective be from winner 1
# therefore 1 means won (1), 2 means lost (0)
winner = replace(winner, winner==2, 0)

# winner won point
indices_points_won = which(winner == 1)
positive_momentum = winner[indices_points_won+1]
# remove NA if exists
positive_momentum = positive_momentum[!is.na(positive_momentum)]

# winner lost point
indices_points_lost = which(winner == 0)
negative_momentum = winner[indices_points_lost+1]
# remove NA values
negative_momentum = negative_momentum[!is.na(negative_momentum)]

# EDA
mean(positive_momentum)
mean(negative_momentum)

# load stan file
model_bayesian = stan_model(file = "beta.stan")

# prepare data for stan
positive_data_stan = list(n = length(positive_momentum), x = positive_momentum)
negative_data_stan = list(n = length(negative_momentum), x = negative_momentum)

# fit the model
positive_fit_bayesian = sampling(model_bayesian, data = positive_data_stan, chains = 4, iter = 1000)
negative_fit_bayesian = sampling(model_bayesian, data = negative_data_stan, chains = 4, iter = 1000)

# print summary of fit
print(positive_fit_bayesian, digits = 2, pars = c("p"))
print(negative_fit_bayesian, digits = 2, pars = c("p"))

# extract simulated p samples from stanfit objects
positive_p_samples = extract(positive_fit_bayesian, pars = "p")$p
negative_p_samples = extract(negative_fit_bayesian, pars = "p")$p

# plot the densities
#plot(positive_fit_bayesian, pars = c("p"), show_density = TRUE, col="red")
#plot(negative_fit_bayesian, pars = c("p"), show_density = TRUE, col="green")

plot(density(positive_p_samples))
plot(density(negative_p_samples))

# Kolmogorov Smirnov test
ks.test(positive_p_samples, negative_p_samples)

