# Simulate the sampling distribution of the sample mean.
#   generator: a function that takes n and returns n random values
#   n: sample size within each experiment
#   B: number of Monte Carlo repetitions
simulate_means <- function(generator, n, B = 10000) {
  replicate(B, mean(generator(n)))
}


