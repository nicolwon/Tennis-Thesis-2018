data
{
  int<lower=0> n; // number of data points
  int x[n]; // data x
}

parameters // parameters to be estimated
{
  real<lower=0> p;
}

model 
{
  p ~ beta(1, 1);
  x ~ bernoulli(p);
}
