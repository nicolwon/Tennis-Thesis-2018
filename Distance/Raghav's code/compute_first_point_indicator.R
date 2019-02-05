compute_first_point_indicator = function(match)
{
  P1Score = match$P1Score
  P2Score = match$P2Score
  indZero1 = P1Score == "0"
  indZero2 = P2Score == "0"
  d_firstPointIndicator = as.numeric(indZero1 & indZero2)
  d_firstPointIndicator[is.na(d_firstPointIndicator)] = 1
  return(d_firstPointIndicator)
}