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

# all files
# points data
pointsfilenames = list.files("data", pattern="*points.csv", full.names=TRUE)
pointsdata = rbindlist(lapply(pointsfilenames,fread), fill=TRUE)
# matches data
matchesfilenames = list.files("data", pattern="*matches.csv", full.names=TRUE)
matchesdata = rbindlist(lapply(matchesfilenames,fread), fill=TRUE)
matches = matchesdata$match_id

# data cutting
# cut by grand slam type
slamType = "-usopen"
pointsdata = pointsdata[grep(slamType, pointsdata$match_id)]
matchesdata = matchesdata[grep(slamType, matchesdata$match_id)]
matches = matches[grep(slamType, matches)]

# cut by gender


# initialize vector of differences
difference = numeric(0)

# iterate through all matches and compute
for (matchID in matches) {
  match = subset(pointsdata, match_id == matchID)
  data = match
  
  # data cleaning
  # remove incomplete match data
  idx = which(matches == matchID)
  matchdata = matchesdata[idx]
  if (matchdata$match_num < 2000) { # male match
    setMin = 3
  } else { # female match
    setMin = 2
  }
  
  setWinner = data$SetWinner
  setWinner = setWinner[setWinner != 0]
  
  # if both players' total num of set wins is less than the setMin, the data is incomplete
  if (all(table(setWinner) < setMin)) next
  
  # data on who served the point
  server = data$PointServer
  
  # get indices of points where A/B served
  indicesServerA = which(server == 1)
  indicesServerB = which(server == 2)
  
  firstPointInGame = min(which(server != 0))
  
  # remove first point of game
  indicesServerA = indicesServerA[!indicesServerA == firstPointInGame]
  indicesServerB = indicesServerB[!indicesServerB == firstPointInGame]
  
  # NOTE: does momentum continue from game to game, when the server changes?
  # for simplicity's sake I will ignore the first point of every game, but this can be changed
  
  removeFirstPointInGame = FALSE
  
  # remove first point of every game and first point of match
  if (removeFirstPointInGame) {
    # get indices where the prev point was the end of a game
    indicesGameEnd = which(data$GameWinner != 0)
    
    # first point in game
    firstPointA = indicesServerB[indicesServerB %in% indicesGameEnd] + 1
    firstPointB = indicesServerA[indicesServerA %in% indicesGameEnd] + 1
    
    # remove first points in game
    indicesServerA = indicesServerA[!indicesServerA %in% firstPointA]
    indicesServerB = indicesServerB[!indicesServerB %in% firstPointB]
  }
  
  # indicesServerA and indicesServerB now respectively represent buckets 1 and 2
  # note that player A is player 0 and player B is player 1 in the following code:
  
  # data on who won the point
  winner = data$PointWinner
  winner = replace(winner, winner==0, NA)
  
  # points that A won [previous point]
  indicesWinnerA = which(winner == 1)
  # points that B won
  indicesWinnerB = which(winner == 2)
  
  # points where A won the previous point
  indicesPrevWinnerA = indicesWinnerA + 1
  # points where B won the previous point
  indicesPrevWinnerB = indicesWinnerB + 1
  
  # A served and won previous point 
  indicesPosMomentumA = intersect(indicesPrevWinnerA, indicesServerA)
  # A served and lost previous point
  indicesNegMomentumA = intersect(indicesPrevWinnerB, indicesServerA)
  
  # B served and won previous point 
  indicesPosMomentumB = intersect(indicesPrevWinnerB, indicesServerB)
  # B served and lost previous point
  indicesNegMomentumB = intersect(indicesPrevWinnerA, indicesServerB)
  
  # relabel data for point win probability
  winnerA = winner
  winnerA = replace(winnerA, winnerA == 2, 0) # winner == 2 is when A lost
  
  winnerB = winner
  winnerB = replace(winnerB, winnerB == 1, 0)
  winnerB = replace(winnerB, winnerB == 2, 1)
  
  # winner data
  positiveMomentumA = winnerA[indicesPosMomentumA]
  negativeMomentumA = winnerA[indicesNegMomentumA]
  positiveMomentumB = winnerB[indicesPosMomentumB]
  negativeMomentumB = winnerB[indicesNegMomentumB]
  
  # EDA
  # length(positiveMomentumA)
  # length(negativeMomentumA)
  # mean(positiveMomentumA)
  # mean(negativeMomentumA)
  # 
  # length(positiveMomentumB)
  # length(negativeMomentumB)
  # mean(positiveMomentumB)
  # mean(negativeMomentumB)
  
  # Calculate differences
  differenceA = mean(positiveMomentumA) - mean(negativeMomentumA)

  differenceB = mean(positiveMomentumB) - mean(negativeMomentumB)
  
  # Ignore difference if difference is NaN (because of poor tournament data)
  if (!is.nan(differenceA)) {
    difference = append(difference, differenceA)
  }
  if (!is.nan(differenceB)) {
    difference = append(difference, differenceB)
  }

  # print which matches have been completed
  print(matchID)
}

difference = na.omit(difference)
absDifference = abs(difference)

plot(density(difference))

# Anderson Darling Normality Test
# install.packages("nortest")
library("nortest")
ad.test(difference)

# Parameters
mean(difference)
sd(difference)
median(difference)

mean(absDifference)
sd(absDifference)
mean(absDifference)

# Distribution fitting
library(MASS)
library(fitdistrplus)
fitNormal = fitdistr(difference, "normal")

# Fitting the difference data to different types of distributions
# Outputs a Cullen Frey Graph (I don't know how to read this yet)
descdist(as.numeric(difference), discrete = FALSE)

# Fit to normal distribution
plotdist(as.numeric(difference),"norm",para=list(mean=fitNormal$estimate[1],sd=fitNormal$estimate[2]))

# ----- OLD (currently unused) BAYESIAN CODE ----- #

# positive momentum point win probability 
# negative momentum point win probability
# difference in point win probabiliy

# load stan file
model_bayesian = stan_model(file = "normal.stan")

# prepare data for stan
difference_data_stan = list(n = length(difference), x = difference)

# fit the model
difference_fit_bayesian = sampling(model_bayesian, data = difference_data_stan, chains = 4, iter = 1000)

# print summary of fit
print(difference_fit_bayesian, digits = 2, pars = c("p"))

# extract simulated p samples from stanfit objects
difference_samples = extract(difference_fit_bayesian, pars = "p")$p

# plot the densities
#plot(positive_fit_bayesian, pars = c("p"), show_density = TRUE, col="red")
#plot(negative_fit_bayesian, pars = c("p"), show_density = TRUE, col="green")

plot(density(difference_samples))

# Kolmogorov Smirnov test
# ks.test(positive_p_samples, negative_p_samples)

