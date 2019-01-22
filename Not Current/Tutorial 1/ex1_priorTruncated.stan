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

  beta ~ uniform(0, 10);
  
}
