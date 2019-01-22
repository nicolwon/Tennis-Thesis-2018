data
{
  int<lower=0> n; // number of data points
  vector[n] x;
  // int x[n]; // data x
}

parameters // parameters to be estimated
{
  real mu;
  real sigma;
}

model 
{
  // p ~ beta(1, 1);
  x ~ normal(mu * x, sigma);
}
