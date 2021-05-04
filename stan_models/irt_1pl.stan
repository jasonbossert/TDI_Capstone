data {
  int<lower=1> J;              // number of students
  int<lower=1> K;              // number of questions
  int<lower=1> N;              // number of observations
  int<lower=1,upper=J> jj[N];  // student for observation n
  int<lower=1,upper=K> kk[N];  // question for observation n
  int<lower=0,upper=1> y[N];   // correctness for observation n
}

parameters {
  real delta;         // mean student ability
  vector[J] alpha;      // ability of student j - mean ability
  vector[K] beta;       // difficulty of question k
}

model {
  alpha ~ normal(0, 1);         // informative true prior
  beta ~ normal(0, 1);          // informative true prior
  delta ~ normal(0.75, 1);      // informative true prior
  y ~ bernoulli_logit(alpha[jj] - beta[kk] + delta);
}
