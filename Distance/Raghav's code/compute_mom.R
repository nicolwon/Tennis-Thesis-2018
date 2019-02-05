compute_mom = function(p_winner, p_ind_bad, p) {
  
  # initialize
  p_mom = rep(0, length(p_winner))
  
  # fill
  for (i in 2:length(p_mom)) {
    if (p_ind_bad[i]) {
      p_mom[i] = 0
    } else {
      prevPointWinner = p_winner[i-1]
      if (abs(prevPointWinner - p) < 0.1) {
        p_mom[i] = 1
      } else {
        p_mom[i] = -1
      }
    }
  }
  return(p_mom)
}