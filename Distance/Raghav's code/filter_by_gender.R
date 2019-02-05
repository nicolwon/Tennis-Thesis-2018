filter_by_gender = function(matchesdata, men) {
  
  # create filter
  n = nrow(matchesdata)
  ind_keep = rep(0, n)
  match_id = matchesdata$match_id
  for (i in 1:n) {
    id_i = match_id[i]
    idsplit = strsplit(id_i, '-')
    code = idsplit[[1]][3]
    isMen = code < 2000
    isWomen = code >= 2000
    if (isMen & men > 0.5) {
      ind_keep[i] = 1
    } else if (isWomen & men < 0.5) {
      ind_keep[i] = 1
    }
  }
  
  # filter
  matchesdata = matchesdata[ind_keep > 0.5, ]
  
}