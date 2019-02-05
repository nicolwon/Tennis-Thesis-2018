# clear workspace and screen
rm(list=ls())
cat("\f")

# set working directory (you should change it appropriately)
base_dir = "/Users/nicolewongsoo/Documents/Fourth\ Year\ Uni/Full\ Year/Thesis/Tennis-Thesis-2018"
setwd(base_dir)

# load libraries and set rstan's parallel computing options
library("rstan")
library("ggplot2")
library(data.table)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# if single file
# load data and sumamarize
# french_open_2011 = read.csv("2011-frenchopen-points.csv", header = TRUE)
# summary(french_open_2011)
# attributes(french_open_2011)
# #sample match
# matchID = "2011-frenchopen-1101"
# match = subset(french_open_2011, match_id == matchID)

# all files
# points data
pointsfilenames = list.files("Grand Slam Point Data", pattern="*points.csv", full.names=TRUE)
pointsdata = rbindlist(lapply(pointsfilenames,fread), fill=TRUE)
# matches data
matchesfilenames = list.files("KlassenMagnus/modifiedMatchData", pattern="*matches.csv", full.names=TRUE)
matchesdata = rbindlist(lapply(matchesfilenames,fread), fill=TRUE)
matches = matchesdata$match_id

pointWinDF = NULL

# iterate through all matches and compute
for (matchID in matches) {
  match = subset(pointsdata, match_id == matchID)
  data = match
  
  # data cleaning
  # remove incomplete match data
  idx = which(matches == matchID)
  matchdata = matchesdata[idx]
  if (matchdata$match_num < 2000) { # male match
    gender = "m"
    setMin = 3
  } else { # female match
    gender = "f"
    setMin = 2
  }
  
  setWinner = data$SetWinner
  setWinner = setWinner[setWinner != 0]
  
  # if both players' total num of set wins is less than the setMin, the data is incomplete
  if (all(table(setWinner) < setMin)) {
    print(paste(matchID , "INCOMPLETE"))
    pServeP1 <- NA
    pServeP2 <- NA
    pReceiveP1 <- NA
    pReceiveP2 <- NA
    
    pointWinDF = rbind(pointWinDF, data.frame(pServeP1, pReceiveP1, pServeP2, pReceiveP2))
    next
  }
  
  # data on who served the point
  server = data$PointServer
  
  # get indices of points where A/B served
  indicesServerA = which(server == 1)
  indicesServerB = which(server == 2)
  
  firstPointInGame = min(which(server != 0))

  # indicesServerA and indicesServerB now respectively represent buckets 1 and 2
  # note that player A is player 0 and player B is player 1 in the following code:
  
  # data on who won the point
  winner = data$PointWinner
  winner = replace(winner, winner==0, NA)
  
  # relabel data for point win probability
  winnerA = winner
  winnerA = replace(winnerA, winnerA == 2, 0) # winner == 2 is when A lost
  
  winnerB = winner
  winnerB = replace(winnerB, winnerB == 1, 0)
  winnerB = replace(winnerB, winnerB == 2, 1)
  
  # point win probability
  
  # point data for A's service
  pServeP1 = sum(winnerA[indicesServerA])/length(winnerA[indicesServerA])
  pServeP2 = sum(winnerB[indicesServerB])/length(winnerB[indicesServerB])
  
  pReceiveP1 = 1-pServeP2
  pReceiveP2 = 1-pServeP1
  
  if (any(is.na(pServeP1)) || any(is.na(pServeP2)) || any(is.na(pReceiveP1)) || any(is.na(pReceiveP2))) {
    print(paste(matchID, "MATCH CONTAINS ANOMALOUS POINTS"))
    pServeP1 <- NA
    pServeP2 <- NA
    pReceiveP1 <- NA
    pReceiveP2 <- NA
  }
  
  pointWinDF = rbind(pointWinDF, data.frame(pServeP1, pReceiveP1, pServeP2, pReceiveP2))
  
  # print which matches have been completed
  print(matchID)

}

final = cbind(matchesdata, pointWinDF)
write.csv(final, 'completeMatches.csv')