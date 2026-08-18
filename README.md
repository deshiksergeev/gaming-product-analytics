# Gaming Product Analytics — Secrets of Darkwood

SQL and Python analysis of premium-currency monetization and in-game purchasing behavior
in the MMORPG *Secrets of Darkwood*.

**Data:** 22,214 registered players, 1,307,678 purchase transactions (PostgreSQL).
**Stack:** PostgreSQL, DBeaver, Python (pandas, NumPy, SciPy, matplotlib, seaborn), Jupyter.

> **A note on units.** The game runs on a premium currency, *paradise petals*, which players
> either earn through quests or buy for real money. The `amount` field records spend **in
> petals, not in money** — so sums over it measure in-game turnover, not revenue. The only
> revenue-related field in the schema is the binary `payer` flag. Buyers and payers are
> distinct populations and are treated as such throughout.

---

## Key Findings

- **17.7% of registered players convert to real-money payers** (3,929 of 22,214). This is the
  single revenue-bearing metric available in the data.
- **No race effect on conversion is detectable, and the test is underpowered to settle the
  question.** Payer share ranges from 17.1% to 19.4% across races; a chi-squared test of
  independence returns $\chi^2 = 3.64$, df = 6, **p = 0.72**. The largest contrast, Demon
  against all other races pooled, gives p = 0.12 — a post-hoc comparison selected on the
  maximum, against a Bonferroni threshold of 0.007. But the gap observed (10.1% relative)
  sits below the 17.7% relative MDE this comparison supports, at which its power is **0.34**.
  This is an absence of evidence, not evidence of absence: the practical recommendation not to
  segment by race follows from the null result *plus* the cost of segmenting.
- **In-game spend is extremely heavy-tailed.** Excluding zero-cost events, mean purchase is
  526.06 against a median of 74.86, standard deviation 2,518 — a coefficient of variation of
  4.79 per transaction, 6.03 per buyer and 7.70 per registered player. The top 0.1% of
  transactions account for 9.6% of turnover. Any comparison of means on this metric is fragile.
- **Prices sit on a lattice.** Amounts are near-multiples of ~7.486 petals: across 43,575
  distinct values, the twenty most frequent cover 32.3% of all transactions. The median of
  74.86 is also the single most common price in the game (4.7% of purchases), so it describes
  the pricing grid as much as it describes a typical player.
- **Demand is concentrated in two items.** *Book of Legends* accounts for 76.9% of all paid
  transactions and was bought by 88.4% of buyers; *Bag of Holding* accounts for 20.8% and
  86.8%. The remaining 143 items form a negligible long tail.
- **Zero-cost transactions are structured, not random.** All 907 (0.069% of events) are the
  same item, and a single account produces 810 of them with no seller recorded, over a
  four-month window. The residual 97 rows come from 71 players at a steady rate across the
  full 16 months. Both are excluded downstream, for different reasons.
- **No race difference in purchase intensity is detectable, down to the resolution the sample
  allows.** Mean purchases per buyer span 55.9%, but the mean is not stable here: the largest
  account explains about a third of that spread and the heavy tail explains the rest. Medians
  sit at 29–30 (spread 3.4%), Kruskal-Wallis returns p = 0.95, and a bootstrap CI on the median
  ratio of each race against the pooled rest runs from 0.90 to 1.14 at its widest. Since median
  purchases are small integers the bootstrap resolution is one purchase in thirty, so the data
  can rule out a race needing roughly 5 more purchases over a player's lifetime and cannot rule
  out 2. Where the tolerance should sit is a design call, not a statistical one.
- **The default significance test fails on the spend metric.** Across 1,000 A/A simulations
  Welch's t-test on raw spend per registered player produced a **2.7%** false positive rate
  against a nominal 5% — a binomial 95% CI of [0.019, 0.039], which excludes 0.05 — with
  significantly non-uniform p-values (KS p < 0.001). It is *conservative*, not permissive:
  extreme accounts inflate the sample variance and the test stops rejecting. Winsorizing at P99
  brings the FPR back inside the nominal level and the MDE from 28.9% to 10.0%.

---

## Analysis

### 1. Real-money conversion

Overall payer share, and payer share by race, tested for significance rather than ranked by
eye. Group sizes range from 1,229 to 6,328, so Wilson intervals are reported alongside the
point estimates; every interval crosses the pooled 17.7%.

![](images/payer_share_by_race.png)

### 2. In-game purchasing

Descriptive statistics of purchase amounts, distribution shape, zero-cost transaction
profiling, and epic item popularity ranked by share of buyers rather than by transaction count
— an item can dominate transaction volume through repeat purchases by a narrow audience.

The log-scale histogram exposes the price lattice described above; the periodic spikes are
genuine clusters, not a binning artifact.

![](images/purchase_distribution.png)
![](images/top_epic_items.png)

### 3. Race balance (ad hoc)

Requested by the analytics team to test a **game design** hypothesis: that some races are
harder to play and therefore require more epic item purchases to progress. The design goal is
parity — no race should be markedly easier or harder than another.

Per race: registered players, buyers and buyer share, payer share among buyers, purchases per
buyer, pooled average transaction amount, and total spend per buyer.

![](images/race_activity.png)

Three things are worth reading carefully in that table:

- **Means and medians disagree by design.** Purchases per buyer differ by 55.9% on means and
  3.4% on medians. Two accounts drive the gap and are flagged as data quality candidates:
  `87-1832423` (Human, 88,304 purchases against a group median of 30) and `08-8623692`
  (Northman, average ticket 47,775 petals sustained over 596 purchases, 4.14% of all in-game
  turnover single-handedly). The second is also the largest single contributor to the variance
  that section 4 is built around.
- **The pooled average transaction amount is not a per-player statistic.** It is total spend
  divided by total purchases, spanning 403 to 762 across races — an 88.9% spread, wider than
  anything else in the table, and dominated by the same two accounts. At the player grain the
  median ticket spans 375–410 (9.4%) with Kruskal-Wallis p = 0.32.
- **Buyer share shows no detectable variation** across races (60.0–62.9%; chi-squared test of
  independence, p = 0.68), and payer share among buyers is 17.72% with a 95% Wilson CI of [17.09%, 18.37%] — an interval
  comfortably containing the 17.69% base rate. Spending petals in-game and paying real money
  for them are independent to within roughly ±0.7 pp.

*Caveat carried into the conclusions:* race is chosen by the player, not assigned at random.
Had a difference appeared, it could have reflected self-selection by player type rather than
any property of the race itself; a causal claim about game difficulty would require randomized
assignment, which is not available here.

### 4. Metric validation and experiment design

Sections 1–3 describe what the product currently does. This section asks a different question:
**which effects are detectable on this audience at all**, and therefore which of the marketing
team's proposed changes are worth testing.

No experiment was run in the game. Historical data is used as a testbed — players are split at
random with no treatment applied (A/A simulation, 1,000 iterations), so a correctly calibrated
test must reject in ~5% of runs with uniformly distributed p-values. MDE is then derived
analytically and power estimated by injecting a synthetic effect.

**Metric grain matters here.** The continuous metric is spend per *registered* player, with the
8,422 non-buyers entering as zeros. Spend per *buyer* conditions on a post-randomisation
outcome: if the treatment moves the purchase decision itself, that comparison is
selection-biased and is not an ITT estimand. The buyer-grain figures in section 3 are
descriptive and unaffected.

| Specification | FPR | KS p | CV | MDE |
|---|---|---|---|---|
| Spend per player, raw (Welch) | **0.027** | < 0.001 | 7.70 | 28.9% |
| Spend per player, winsorized P99 | 0.063 | 0.14 | 2.67 | 10.0% |
| Spend per player, winsorized P95 | 0.061 | 0.10 | 1.77 | 6.7% |
| Spend per player, Mann-Whitney | 0.050 | 0.82 | — | — |
| Real-money conversion (binary) | — | — | — | **1.43 pp = 8.1% rel.** |

Contrary to the usual expectation that the CLT rescues heavy-tailed metrics at $n \approx 10^4$,
Welch's t-test **failed** here. Spend per registered player has skewness 81 and excess kurtosis
9,239; the largest value exceeds the mean by a factor of 920. A practitioner running this test
unchecked would have concluded, wrongly, that a true effect was absent.

The repair works but is not lavish: the winsorized FPR sits at the upper edge of its interval
and the uniformity test is no longer comfortable, so P99 is close to the weakest cap that does
the job. The analytic MDE is also optimistic — it assumes the cap is fixed independently of
treatment, whereas re-estimating it on the pooled post-treatment sample clips part of the lift.
Simulated power reaches 0.77 at a 12.5% effect and 0.89 at 15%, putting the effective 80%
threshold near **13%**. The raw metric needs roughly **33%** for the same power, so variance
reduction is worth a factor of about 2.5 in detectable effect size.

![](images/aa_pvalue_distribution.png)
![](images/power_curve.png)

**Practical implication.** The marketing team's stated goal — driving real-money conversion
through advertising — is testable: an 8% relative lift is detectable on the full player base,
on a binary metric with no distributional assumption to violate. In-game spend is testable only
after variance reduction. Testing at the level of a single race is not viable: the smallest
race supports an MDE of 17.7% relative on conversion, against an observed gap of 10.1%.

---

## Recommendations

| Finding | Action | Metric |
|---|---|---|
| No race effect detected, but power is 0.34 at the observed gap | Do not segment monetization campaigns by race — the evidence does not support it, and detecting an effect this size would need a much larger sample | — |
| 82.3% of players never pay | Focus acquisition-to-payment funnel work on the whole base; conversion is the bottleneck | Payer share |
| Two items dominate demand | Test bundling long-tail items with the two dominant ones rather than discounting them standalone | Items per buyer |
| Spend is heavy-tailed at every grain (CV 4.8 / 6.0 / 7.7) | Report median and P90 alongside the mean; never test on raw mean spend — winsorize or use a rank-based test | — |
| Conversion MDE = 1.43 pp | Run advertising experiments on the full base, on conversion, not on in-game spend | Payer share |
| Two accounts distort every mean they enter | Review `87-1832423` and `08-8623692` before these aggregates are used in production | — |

---

## Repository Structure

```text
gaming-product-analytics/
├── README.md
├── analysis/
│   ├── gaming_product_analysis.ipynb
│   ├── overall_monetization.csv
│   ├── monetization_by_race.csv
│   ├── purchase_statistics.csv
│   ├── purchase_amounts.csv
│   ├── zero_cost_transactions.csv
│   ├── zero_cost_events.csv
│   ├── popular_items.csv
│   ├── race_activity.csv
│   └── player_spend.csv
├── images/
│   ├── payer_share_by_race.png
│   ├── purchase_distribution.png
│   ├── top_epic_items.png
│   ├── race_activity.png
│   ├── aa_pvalue_distribution.png
│   └── power_curve.png
└── sql/
    ├── 01_monetization_analysis.sql
    ├── 02_in_game_purchases.sql
    ├── 03_race_activity_analysis.sql
    └── 04_player_level_spend.sql
```

Full analysis and interpretation: `analysis/gaming_product_analysis.ipynb`

Source tables: `fantasy.users`, `fantasy.events`, `fantasy.items`, `fantasy.race`