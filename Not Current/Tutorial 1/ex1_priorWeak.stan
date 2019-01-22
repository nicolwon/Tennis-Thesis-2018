data
{
  int n; // number of data points
  real sigma; // standard deviation
  vector[n] x; // input data x
  vector[n] y; // output data y
}

parameters 
{
  real beta; // beta coefficient
}

model 
{
  y ~ normal(beta * x, sigma);

  // prior is normally distributed with mean 0 and a large (hence, "weak") standard deviation of 100
  beta ~ normal(0, 100);
  
}
