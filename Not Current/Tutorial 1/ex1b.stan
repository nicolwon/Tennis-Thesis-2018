data
{
  int n; // number of data points
  vector[n] x; // input data x
  vector[n] y; // output data y
}

parameters 
{
  real beta; // beta coefficient
  real<lower=0> sigma; // standard deviation with a lower bound of zero
}

model 
{
  y ~ normal(beta * x, sigma);

  // prior (not specifying a prior defaults to "flat" prior)
  
}
