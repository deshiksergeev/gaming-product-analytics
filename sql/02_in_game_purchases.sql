/*
Project: Secrets of Darkwood
Analysis: In-game purchase analysis
Description:
Analyze the distribution of in-game purchase amounts, identify potential
data quality issues, and evaluate the popularity of epic game items.
*/


-- ============================================================
-- 2.1. Purchase Amount Statistics
-- ============================================================
/*
Calculate descriptive statistics for transaction amounts,
including total revenue, minimum and maximum purchase amounts,
mean, median, and standard deviation.

The median is included to assess the skewness of the purchase
amount distribution and compare it with the mean.
*/

SELECT
    COUNT(transaction_id) AS total_transactions,
    SUM(amount) AS total_revenue,
    MIN(amount) AS min_purchase_amount,
    MAX(amount) AS max_purchase_amount,
    AVG(amount) AS avg_purchase_amount,
    PERCENTILE_DISC(0.5)
        WITHIN GROUP (ORDER BY amount) AS median_purchase_amount,
    STDDEV(amount) AS std_purchase_amount
FROM fantasy.events;

/*
Additional query for notebook visualization.

Retrieve all non-zero purchase amounts to visualize
the transaction amount distribution and compare
the mean and median purchase values.
*/

SELECT
    amount
FROM fantasy.events
WHERE amount > 0;

-- ============================================================
-- 2.2. Zero-Cost Transactions
-- ============================================================
/*
Identify transactions with zero purchase amount and calculate
their share among all recorded transactions.

Zero-cost transactions are treated as a potential data quality
issue and are excluded from the analysis of paid item popularity.
*/

WITH zero_cost_transactions AS (
    SELECT
        CASE
            WHEN amount = 0 THEN 1
            ELSE 0
        END AS is_zero_cost
    FROM fantasy.events
)
SELECT
    SUM(is_zero_cost) AS zero_cost_transactions,
    SUM(is_zero_cost) / COUNT(*)::NUMERIC AS zero_cost_share
FROM zero_cost_transactions;


-- ============================================================
-- 2.3. Popular Epic Items
-- ============================================================
/*
Analyze the popularity of epic game items based on non-zero
purchase transactions.

The analysis calculates:
- total number of transactions for each item;
- share of all non-zero transactions;
- share of users who purchased each item.

The results are joined with the item reference table to display
human-readable item names.
*/


WITH item_transaction_stats AS (
    SELECT DISTINCT
        item_code,
        COUNT(transaction_id)
            OVER (PARTITION BY item_code) AS total_transactions,
        COUNT(transaction_id)
            OVER (PARTITION BY item_code) / COUNT(*) OVER ()::NUMERIC AS transaction_share
    FROM fantasy.events
    WHERE amount > 0
),
item_buyer_stats AS (
    SELECT
        item_code,
        COUNT(DISTINCT id)
            / (
                SELECT COUNT(DISTINCT id)
                FROM fantasy.events
                WHERE amount > 0
            )::NUMERIC AS buyer_share
    FROM fantasy.events
    WHERE amount > 0
    GROUP BY item_code
)
SELECT
    i.game_items AS epic_item,
    its.total_transactions,
    its.transaction_share,
    ibs.buyer_share
FROM item_transaction_stats AS its
LEFT JOIN item_buyer_stats AS ibs USING (item_code)
LEFT JOIN fantasy.items AS i USING (item_code)
ORDER BY buyer_share DESC;