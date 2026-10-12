# Simulate the sampling distribution of the sample mean.
#   generator: a function that takes n and returns n random values
#   n: sample size within each experiment
#   B: number of Monte Carlo repetitions
simulate_means <- function(generator, n, B = 10000) {
  replicate(B, mean(generator(n)))
}


# Skewness: 0 for a normal distribution
skew <- function(x) {
  mean((x - mean(x))^3) / mean((x - mean(x))^2)^(3/2)
}

# Excess kurtosis: 0 for a normal distribution
kurt <- function(x) {
  mean((x - mean(x))^4) / mean((x - mean(x))^2)^2 - 3
}

# Q-Q correlation: 1 means a perfectly straight Q-Q plot
qq_cor <- function(x) {
  qq <- qqnorm(x, plot.it = FALSE)
  cor(qq$x, qq$y)
}

# Apply my "normal enough" rule to a vector of sample means
check_normal <- function(x, skew_max = 0.2, kurt_max = 0.5, qq_min = 0.998) {
  s <- skew(x)
  k <- kurt(x)
  q <- qq_cor(x)
  data.frame(
    skewness        = round(s, 3),
    excess_kurtosis = round(k, 3),
    qq_cor          = round(q, 4),
    passes          = abs(s) < skew_max & abs(k) < kurt_max & q > qq_min
  )
}
