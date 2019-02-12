# clear workspace and screen
rm(list=ls())
cat("\f")

# set working directory (you should change it appropriately)
base_dir = "/Users/nicolewongsoo/Documents/Fourth\ Year\ Uni/Full\ Year/Thesis/Tennis-Thesis-2018/"
setwd(base_dir)

# load libraries and set rstan's parallel computing options
library("rstan")
library("ggplot2")
library(data.table)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# load data
pointsdata = read.csv('Grand\ Slam\ Point\ Data/pointsWithImp.csv', header=TRUE)
matchdata = read.csv('Grand\ Slam\ Point\ Data/completeMatches.csv', header=TRUE)

# full table with player ranks for each point
fulldata = merge(pointsdata, matchdata[c("match_id", "player1_rank", "player2_rank")], all.x=TRUE)

# compile data
yat = fulldata$PointWinner
yat = replace(yat, yat==0, NA)
yat = replace(yat, yat==2, 0)

# dummy variable dat and dat_inverse (for multiplying with yat)
indicesDat = which(fulldata$PointNumber == 0 | fulldata$PointNumber == 1)
dat = integer(length(yat))
dat[indicesDat] = 1

dat_inverse = rep(1, length(yat))
dat_inverse[indicesDat] = 0

# yat with tilda
indices = 1:length(yat)
yat1 = yat[indices-1] 
yat1 = append(c(NA), yat1)
yat1 = yat1 * dat_inverse

# importance of point
imp = fulldata$impVector

# Ranks of player 1 and 2
p1Rank = 8 - log2(fulldata$player1_rank)
p2Rank = 8 - log2(fulldata$player2_rank)
rankDiff = p1Rank - p2Rank
rankSum = p1Rank + p2Rank

test = na.omit(data.frame(yat, rankDiff, rankSum, yat1, dat, imp))
test = test[test$imp != 0, ]
mean(test$rankDiff)
mean(test$rankSum)
test$rankDiff = test$rankDiff - mean(test$rankDiff)
test$rankSum = test$rankSum - mean(test$rankSum)
test = cbind(test, data.frame(test$rankDiff * test$yat1, test$rankSum * test$yat1,
                              test$rankDiff * test$dat, test$rankSum * test$dat,
                              test$rankDiff * test$imp, test$rankSum * test$imp))

model = lm(yat ~ . - yat, data = test)
summary(model)
