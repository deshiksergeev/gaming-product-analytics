/*
Project: Secrets of Darkwood
Analysis: In-game purchases of epic items
 
All amounts are denominated in paradise petals (premium in-game currency),
not in real money. Aggregates over `amount` measure in-game spend.
*/


-- ============================================================
-- 2.1. Purchase Amount Statistics
-- ============================================================

/*
Descriptive statistics over all recorded transactions.
 
Zero-cost transactions are intentionally NOT filtered here: this query
establishes the baseline against which they are identified in 2.2.
 
Median is included specifically to expose skewness — with a right-skewed
distribution the mean is not a usable summary of a typical purchase.
*/

SELECT
    COUNT(transaction_id) AS total_transactions,
    SUM(amount) AS total_spend,
    MIN(amount) AS min_purchase_amount,
    MAX(amount) AS max_purchase_amount,
    AVG(amount) AS avg_purchase_amount,
    PERCENTILE_DISC(0.5)
        WITHIN GROUP (ORDER BY amount) AS median_purchase_amount,
    STDDEV(amount) AS std_purchase_amount
FROM fantasy.events;

/*
Supporting extract for the notebook: raw non-zero amounts, used to plot the
distribution. Filtered to amount > 0 so that the histogram and the summary
statistics computed on it refer to the same population.
*/

SELECT
    amount
FROM fantasy.events
WHERE amount > 0;


-- ============================================================
-- 2.2. Zero-Cost Transactions
-- ============================================================
/*
Zero-cost purchases generate no premium currency turnover and are treated as
a data quality issue. Counted here, then excluded from every downstream query.
*/


SELECT
    COUNT(*) FILTER (WHERE amount = 0) AS zero_cost_transactions,
    COUNT(*) FILTER (WHERE amount = 0) / COUNT(*)::NUMERIC AS zero_cost_share
FROM fantasy.events;

-- ============================================================
-- 2.3. Epic item popularity
-- ============================================================
/*
Ranks epic items by the share of buyers who purchased them at least once,
as required by the task — not by transaction count. The two orderings differ:
an item can dominate transaction volume through repeat purchases by a narrow
audience.
 
Per item:
  - transaction count and its share of all paid transactions;
  - share of unique buyers who purchased the item at least once.
 
Buyer shares do not sum to 100%: one buyer can purchase several items.
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