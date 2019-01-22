# clear workspace and screen
rm(list=ls())
cat("\f")

# set working directory (you should change it appropriately)
base_dir = "/Users/singal/Desktop/Columbia/year3/summer/iid/code/2018_11_15_nicole/"
setwd(base_dir)

#load all the functions in the working directory except main
pathnames <- list.files(pattern="[.]R$", path=getwd(), full.names=TRUE);
mainFileIndex = grepl("playerNormalized.R", pathnames) | grepl("playerNormalized_RS.R", pathnames)
pathnames = pathnames[!mainFileIndex]
if (length(pathnames) > 0)
{
  for (i in 1:length(pathnames))
  {
    source(pathnames[i])
  }
}

# load libraries and set rstan's parallel computing options
library(data.table)

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

# men (1) or women (0)?
men = 0
matchesdata = filter_by_gender(matchesdata, men)
if (men > 0.5) {
  nPtsThreshold = 90
} else {
  nPtsThreshold = 60
}

# initialize 
difference = numeric(0)
p_pos = numeric(0)
p_neg = numeric(0)

# iterate through all matches and compute
matches = matchesdata$match_id
for (matchID in matches) {
  
  # extract match of interest
  match = subset(pointsdata, match_id == matchID)
  
  # extract columns of interest
  d_winner = match$PointWinner[-1]
  d_server = match$PointServer[-1]
  goodMatch = sum(is.na(d_winner)) < 0.5 & sum(is.na(d_server)) < 0.5 & length(d_winner) > nPtsThreshold
  
  if (goodMatch) {
    # discard first points, tie-break points, etc
    d_firstPointIndicator = compute_first_point_indicator(match)
    d_tbPointIndicator = compute_tb_point_indicator(match)
    d_ind_bad = d_firstPointIndicator + d_tbPointIndicator > 0.5
    
    # compute quantities of interest for players 1 and 2
    for (p in c(1,2)) {
      
      # data for this player
      p_ind = abs(d_server - p) < 0.1
      p_winner = d_winner[p_ind]
      p_ind_bad = d_ind_bad[p_ind]
      p_ind_bad[is.na(p_ind_bad)] = FALSE
      p_mom = compute_mom(p_winner, p_ind_bad, p)
      
      # points with positive momentum
      ind_pos_mom = p_mom > 0.5
      p_winner_pos_mom = p_winner[ind_pos_mom]
      n_win_pos_mom = sum(abs(p_winner_pos_mom - p) < 0.1)
      n_lose_pos_mom = sum(abs(p_winner_pos_mom - p) > 0.1)
      p_win_pos = n_win_pos_mom / (n_win_pos_mom + n_lose_pos_mom)
      
      # points with negative momentum
      ind_neg_mom = p_mom < -0.5
      p_winner_neg_mom = p_winner[ind_neg_mom]
      n_win_neg_mom = sum(abs(p_winner_neg_mom - p) < 0.1)
      n_lose_neg_mom = sum(abs(p_winner_neg_mom - p) > 0.1)
      p_win_neg = n_win_neg_mom / (n_win_neg_mom + n_lose_neg_mom)
      
      # difference
      diff = p_win_pos - p_win_neg
      
      # store
      difference = append(difference, diff)
      p_pos = append(p_pos, p_win_pos)
      p_neg = append(p_neg, p_win_neg)
      
      # msg
      if (is.na(diff)) {
        print(matchID)
      }
    }
  }
}

difference = difference[!is.na(difference)]
plot(density(difference))
mean(difference)
#plot(density(p_pos))
#plot(density(p_neg))


