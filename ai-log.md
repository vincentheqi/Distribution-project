# AI Interaction Log

**Project:** How Fast Does Normal Happen? Stress-Testing the Central Limit Theorem

**Tool used:** Claude (Anthropic)

## How I used AI

I used AI throughout this project as a tutor, coding assistant, and reviewer. I used it to understand the course material, write and debug R code, design experiments, interpret results. I made the key decisions myself: which normality standard to use, how to handle borderline results, and what n to report for each population. I validated AI-generated code by checking simulation results against known theory before trusting them.

The most useful pattern was **iteration**: running the AI's suggestion, looking at the actual output, noticing when something was wrong or unexpected, and asking a better follow-up question.

------------------------------------------------------------------------

## 1. Understanding n versus B

**First prompt:** I asked the AI to explain the project step by step and make sure I understood it.

**Response:** Instead of explaining n and B abstractly, it gave me a 2×2 grid of histograms to run (n = 5 and 50, B = 200 and 10,000) and asked me to describe what changed.

**What I noticed:** My first answers mixed the two ideas up. I said the n = 50, B = 10,000 plot was "more normal and more trustworthy" without separating which setting caused which effect. I also thought the center moved with n, because the n = 5 histogram's peak sat near 0.8.

**Follow-up:** The AI corrected this. The peak is the mode, which sits left of the mean under right skew; the mean stays at 1 for every n. It then asked a check question: "If your n = 15 histogram looks bumpy, would you increase n or B?"

**Result:** I answered correctly (increase B, because n is the question and B is how clearly you see the answer). That distinction shaped the rest of the project: wide sweeps at B = 10,000, then B = 50,000 near cutoffs.

------------------------------------------------------------------------

## 2. Choosing a normality standard

**First prompt:** I said I thought skewness was the important measure and asked the AI to explain the others.

**Response:** It explained kurtosis, Q-Q correlation, the Shapiro–Wilk test, and visual checks, and argued that skewness alone isn't enough.

**What I needed to see:** Rather than taking that on faith, I ran its comparison of a uniform distribution and a normal distribution at n = 1. The uniform had skewness ≈ 0 but excess kurtosis ≈ −1.2, and its Q-Q plot was clearly S-shaped. Skewness alone would have called a flat rectangle "normal."

**Follow-up:** I chose a moderate standard (\|skewness\| \< 0.2, \|excess kurtosis\| \< 0.5) and wanted to add the Q-Q correlation. My first justification was "it's the middle option." The AI pointed out that this wouldn't hold up when defending the project, and suggested two stronger reasons: the thresholds are 8–10× larger than the Monte Carlo noise, and mild skewness has little practical effect on confidence intervals.

**Further iteration:** Instead of guessing a Q-Q cutoff, we calibrated it to the skewness rule. Exponential means at n = 100 have theoretical skewness exactly 0.2, and I measured their Q-Q correlation at about 0.999, so I set the cutoff at 0.998 so the two criteria agree.

------------------------------------------------------------------------

## 3. Git push that silently failed

**Problem:** RStudio reported that my push worked, but nothing appeared on GitHub.

**Prompt:** I described what happened.

**Response:** The AI asked me to run `git status`, `git log`, `git branch`, and `git remote -v`.

**What the output showed:** "Your branch is ahead of 'origin/main' by 1 commit." The commit existed, but the push never went through. Running `git push` from the Terminal worked immediately. The AI also had me add `.DS_Store`, `*_files/`, and `*.html` to `.gitignore` to keep rendered output out of the repository.

**Later issues:** Twice I got "nothing to commit" because I hadn't saved my file, and once I typed `git commit-m` without a space. Reading the error messages carefully fixed each one.

------------------------------------------------------------------------

## 4. The exponential "coin flip" at n = 100

**What happened:** In my scratch exploration, exponential means at n = 100 *passed* with skewness 0.185. In my first sweep, n = 100 *failed* with skewness 0.214: same population, same n, opposite verdicts.

**Prompt:** I brought both results to the AI.

**Explanation:** The theoretical skewness at n = 100 is exactly 0.2, right on my threshold, so Monte Carlo noise decides which side it lands on. The two runs used different random numbers, because the sweep had already used up draws for smaller n.

**Iteration:** I reran n = 80 to 140 with B = 50,000. The verdict went FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE with no flip-flopping. This led to two rules I used for the rest of the project: increase B near any cutoff, and count n as passing only if every larger tested n also passes.

------------------------------------------------------------------------

## 5. Misleading histograms for the die

**Problem:** The die's sample-mean histograms showed tall, narrow spikes far above the normal curve. They looked extremely non-normal.

**Diagnosis:** The AI identified this as a binning artifact. With `breaks = 40`, each bin was much narrower than the gap between possible sample means (0.5 at n = 2), so all the probability for each value crammed into a skinny bin and its density shot up.

**Fix:** We changed `plot_means()` to accept custom breaks and centered one bin on each possible value: `seq(1 - 0.5/n, 6 + 0.5/n, by = 1/n)`. The histograms then matched the normal curve closely. This showed that the die's shape was nearly normal by n = 3, and only the discreteness staircase was holding it back. I reused this fix for every discrete population.

------------------------------------------------------------------------

## 6. Contradictory skewness for Poisson

**What happened:** At B = 10,000, Poisson skewness passed at n = 30 (0.150) but failed at n = 40 (0.228), even though theory says it should keep shrinking.

**Prompt:** I asked about the contradiction.

**Explanation:** The ±0.025 noise estimate I had been using assumes roughly normal data. For skewed, discrete data, the skewness estimate itself is noisier.

**Iteration:** Rerunning with B = 50,000 gave n = 40 a skewness of 0.158, exactly the theoretical value. The contradiction was noise. This made me more careful about trusting any single run near a threshold.

------------------------------------------------------------------------

## 7. Flip-flopping cutoffs and a rounding question

**What happened:** For Binomial(5, 0.1), even at B = 50,000, the verdict flipped back and forth: n = 64 passed, 65 failed, 67 passed, 68 failed. n = 68 also displayed a Q-Q correlation of 0.9980 but was marked FALSE.

**Explanation:** The Q-Q correlation was nearly flat (0.9978–0.9981) from n = 55 to 70, right at my 0.998 cutoff. And `check_normal()` rounds for display but tests the unrounded value, so 0.99798 displays as 0.9980 but fails.

**Result:** My stability rule gave n = 69, and I reported the cutoff as "about 70, with a gradual transition." I also learned to compare cases: Binomial(20, 0.5) had a steeply rising Q-Q correlation and a clean cutoff, while Binomial(5, 0.1) had a flat one and a fuzzy cutoff.

------------------------------------------------------------------------

## 9. Dependent machine failures: new code and a surprising result

**Challenge:** This population needed a loop to generate each dependent sequence, and there was no simple formula for its mean or standard error.

**What the AI provided:** A generator function based on the instructor's model, a one-million-step chain to estimate the long-run mean, SD, and lag-1 correlation, and an independent control made by sampling from that chain.

**How I validated it:** The control's standard deviation of means matched σ/√n almost exactly (1.137 vs. 1.139 at n = 5), confirming the control was set up correctly.

**Surprise:** I expected dependence to make everything worse. Instead, negative dependence made the sample means *more precise* (15–30% smaller SD) but *slower to become normal* (n = 425 vs. 250 for the control). The AI explained that the textbook warning about a smaller effective sample size applies to positive dependence.

**Debugging:** Twice I got "unexpected symbol" errors from a missing closing parenthesis. I learned to click next to an opening bracket to see its match in RStudio.
