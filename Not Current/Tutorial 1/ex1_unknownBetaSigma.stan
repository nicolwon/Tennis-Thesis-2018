data
{
  int n; // number of data points
  vector[n] x; // input data x
  vector[n] y; // output data y
}

parameters // parameters to be estimated
{
  real beta;
  real sigma; // standard deviation
}

model 
{
  y ~ normal(beta * x, sigma);

  // prior is normally distributed with mean 0 and a large (hence, "weak") standard deviation of 100
  beta ~ normal(0, 100);
  
}
