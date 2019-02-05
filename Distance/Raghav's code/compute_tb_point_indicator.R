compute_tb_point_indicator = function(match)
{
  G1Score = as.numeric(match$P1GamesWon)
  G2Score = as.numeric(match$P2GamesWon)
  d_tbPointIndicator = as.numeric(abs(G1Score - 6) < 0.1 & abs(G2Score - 6) < 0.1)
  d_tbPointIndicator[is.na(d_tbPointIndicator)] = 1
  return(d_tbPointIndicator)
}