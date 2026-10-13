# How Fast Does Normal Happen?

**Stress-Testing the Central Limit Theorem with Monte Carlo Simulation in R**

The Central Limit Theorem (CLT) says that sample means become approximately normal as the sample size grows, and a common rule of thumb says **n ≥ 30 is "large enough."** This project tests that rule. Using reproducible Monte Carlo simulations, I measured how large *n* must be before the sampling distribution of the mean is approximately normal for 11 different populations, including three that deliberately violate the CLT's assumptions.

## Key findings

- **There is no universal sample size.** Under one consistent standard, the required *n* ranged from **1** to **425**, and **no n was enough** for the Cauchy distribution.
- **The n = 30 rule failed for 6 of 11 populations.**
- **Skewness was the strongest predictor.** For skewness-limited populations, the required sample size closely followed **n ≈ 25γ²**, where γ is the population's skewness.
- **Discreteness is a separate obstacle.** A six-sided die needed 3× the sample size of a continuous uniform distribution with almost the same shape.
- **CLT assumptions matter unequally.** Infinite variance caused complete failure, non-identical observations had no measurable effect, and negative dependence made sample means *more precise* but *slower* to become normal.

## Results

| Population | Smallest *n* judged normal | Deciding check | Key observation |
|-----------------|--------------------:|-----------------|-----------------|
| Standard normal | 1 | — | Control experiment; normal at every *n* |
| Continuous uniform | 3 | Kurtosis | Symmetric but light-tailed |
| Binomial(20, 0.5) | 5 | Q-Q correlation | Already bell-shaped; only discreteness to overcome |
| Six-sided die | 9 | Q-Q correlation | Same shape as uniform, but discreteness triples *n* |
| Life/death mixture | 19 | Skewness | Bimodal; four humps at *n* = 3 merge into one bell |
| Poisson(1) | 35 | Q-Q correlation | Skewed and discrete |
| Binomial(5, 0.1) | 69 | Q-Q correlation | Very skewed with large steps; fuzzy cutoff |
| Exponential(1) | 110 | Skewness | Strong right skew; *n* = 30 clearly fails |
| Non-identical Bernoulli | 120 | Q-Q correlation | Same as identical control (*n* = 120) |
| Dependent machine failures | 425 | Skewness | More precise, but slower than independent control (*n* = 250) |
| Cauchy | **None** | All | Averages never settle; spread identical at *n* = 1 and 1,000 |

The full analysis, figures, and discussion are in [`12-summary.qmd`](12-summary.qmd).

## Methods

**Monte Carlo simulation.** For each population and sample size *n*, I generated *B* samples, computed each sample's mean, and analyzed the distribution of those means. I used *B* = 10,000 for wide sweeps and *B* = 50,000 to confirm results near each cutoff.

**Definition of "approximately normal."** One standard was applied to every population. A sampling distribution passed when it met all of:

| Criterion | Threshold | Detects |
|------------------------|------------------------|------------------------|
| Skewness | \|skewness\| \< 0.2 | Asymmetry |
| Excess kurtosis | \|excess kurtosis\| \< 0.5 | Tails too heavy or too light |
| Q-Q correlation | \> 0.998 | Any departure from a straight Q-Q line, including discreteness |
| Visual check | No clear pattern | Problems missed by summary statistics |

The thresholds are 8–10× larger than the Monte Carlo noise at *B* = 10,000, and the Q-Q cutoff was calibrated to agree with the skewness rule.

**Stability rule.** Near a threshold, random noise can flip the verdict between neighboring sample sizes. I reported the smallest tested *n* that passed **and** for which every larger tested *n* also passed.

**Controls.** Each assumption-violating population was paired with a control that differed only in the violated assumption, isolating its effect.

**Validation.** Simulated means and standard errors were checked against theory (μ and σ/√*n*), and simulated skewness and kurtosis against their theoretical rates (γ/√*n* and κ/*n*).

## Repository structure

```         
├── R/
│   └── clt_functions.R            Shared functions: simulation, diagnostics, normality rule, plots
├── n vs B.qmd                     Warm-up: n vs. B, and calibrating the Q-Q cutoff
├── 01-normal.qmd                  Standard normal (control)
├── 02-uniform.qmd                 Continuous uniform
├── 03-die.qmd                     Six-sided die
├── 04-exponential.qmd             Exponential(1)
├── 05-poisson.qmd                 Poisson(1)
├── 06-binomial-small.qmd          Binomial(5, 0.1)
├── 07-binomial-large.qmd          Binomial(20, 0.5)
├── 08-cauchy.qmd                  Cauchy — violates finite variance
├── 09-dependent.qmd               Dependent machine failures — violates independence
├── 10-nonidentical-bernoulli.qmd  Basketball fatigue — violates identical distribution
├── 11-life-death.qmd              Bimodal age-at-death mixture
├── 12-summary.qmd                 Cross-population summary and conclusions
└── ai-log.md                      Record of AI use and iteration
```

Each population file follows the same structure: the population, my prediction, the sample sizes tested, the chosen *n*, the evidence for that choice, and what surprised me.

## Reproducing the analysis

Requirements: [R](https://www.r-project.org/) and [Quarto](https://quarto.org/) (RStudio includes Quarto). No additional packages are needed; everything uses base R plus `knitr`.

``` bash
git clone https://github.com/vincentheqi/Distribution-project.git
cd Distribution-project
quarto render
```

Or open any `.qmd` file in RStudio and click **Render**. All simulations are seeded, so results are exactly reproducible. Note that `09-dependent.qmd` takes several minutes to render, because its dependent sequences are generated with loops.

## Tools

R · Quarto · Git/GitHub · Monte Carlo simulation · Base R graphics

## About

Developed for MATH 167R at San José State University by **Zhanxiang (Vincent) He**.
