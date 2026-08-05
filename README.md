# Gaming Product Analytics

SQL-based product analytics project focused on analyzing player monetization, purchasing behavior, and in-game economic activity in the game **Secrets of Darkwood**.

The project combines SQL for analytical querying and Python for data visualization to investigate player payment behavior, purchase patterns, and differences in activity across character races.

---

## Project Overview

The project consists of three main analytical sections:

1. Player monetization analysis.
2. In-game purchase analysis.
3. Player activity analysis by character race.

The analysis explores player conversion, purchase behavior, premium item popularity, and spending patterns across different player segments.

The complete exploratory analysis, visualizations, and interpretation of the results are available in:

`analysis/gaming_product_analysis.ipynb`

The SQL scripts are organized by analytical task and can be executed independently.

---

## Dashboard Preview

### Player Monetization by Character Race

<p align="center">
<img src="images/payer_share_by_race.png" width="700">
</p>

### Purchase Amount Distribution

<p align="center">
<img src="images/purchase_distribution.png" width="700">
</p>

### Most Popular Epic Items

<p align="center">
<img src="images/top_epic_items.png" width="700">
</p>

---

## Data

The project uses a PostgreSQL database containing gameplay and monetization information, including:

- registered players;
- player races;
- in-game purchase events;
- premium game items;
- payment status.

The analysis is based on the following tables:

- `fantasy.users`
- `fantasy.events`
- `fantasy.items`
- `fantasy.race`

---

## Player Monetization Analysis

The first part of the project investigates player conversion into paying users.

The analysis calculates:

- overall payer share;
- payer share by character race.

These metrics help evaluate whether player monetization differs across races and identify segments with higher payment conversion.

---

## In-Game Purchase Analysis

The second part focuses on player purchasing behavior.

The analysis includes:

- descriptive statistics of purchase amounts;
- purchase amount distribution;
- detection of zero-cost transactions;
- popularity analysis of premium (epic) items.

The purchase distribution illustrates the highly skewed nature of player spending, while the premium item analysis identifies the products responsible for the majority of purchases.

---

## Player Activity by Character Race

The final analytical task compares purchasing behavior across character races.

For each race, the analysis calculates:

- number of registered players;
- number of purchasing players;
- buyer share;
- payer share among buyers;
- average number of purchases per buyer;
- average purchase value;
- average total spending per buyer.

This analysis highlights behavioral differences between player groups and provides insights into purchasing intensity across races.

---

## Key Analytical Findings

- Approximately **17.7%** of registered players became paying users.
- The payer share is relatively similar across races, with **Demons** showing the highest conversion rate.
- Purchase amounts exhibit a strongly right-skewed distribution, where a small number of expensive purchases substantially increase the average transaction value.
- Zero-cost purchases represent less than **0.1%** of all transactions and therefore have negligible influence on overall purchasing statistics.
- Premium item purchases are highly concentrated: **Book of Legends** and **Bag of Holding** dominate player demand, while the remaining items form a long-tail distribution.
- Character races demonstrate noticeable differences in purchasing intensity and average player spending.

---

## SQL Techniques

The project demonstrates practical SQL skills, including:

- Common Table Expressions (CTEs);
- `JOIN` operations;
- aggregation and conditional aggregation;
- window functions;
- `CASE WHEN` expressions;
- subqueries;
- `GROUP BY`;
- PostgreSQL aggregate functions;
- analytical metric calculation.

---

## Repository Structure

```text
gaming-product-analytics/
│
├── README.md
│
├── analysis/
│   ├── gaming_product_analysis.ipynb
│   ├── overall_monetization.csv
│   ├── monetization_by_race.csv
│   ├── purchase_statistics.csv
│   ├── purchase_amounts.csv
│   ├── zero_cost_transactions.csv
│   └── popular_items.csv
│
├── images/
│   ├── payer_share_by_race.png
│   ├── purchase_distribution.png
│   └── top_epic_items.png
│
└── sql/
    ├── 01_monetization_analysis.sql
    ├── 02_in_game_purchases.sql
    └── 03_race_activity_analysis.sql
```

---

## Tools

- PostgreSQL;
- SQL;
- Python;
- Pandas;
- Matplotlib;
- Jupyter Notebook;
- DBeaver;
- Git;
- GitHub.