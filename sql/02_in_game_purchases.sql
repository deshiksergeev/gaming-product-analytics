/*
In-game purchases of epic items. All amounts are in paradise petals, not money.
*/
 
-- Baseline over all rows. Zero-cost transactions are deliberately not filtered here — this is
-- the query against which they are identified below.

SELECT
    COUNT(transaction_id) AS total_transactions,
    -- amount is float4; sum(real) returns real and accumulates 1.3M values in a
    -- 24-bit mantissa, losing ~0.12% (820k petals). The intermediate float8 cast
    -- matters: float4 -> numeric renders through six significant digits and still
    -- drifts by ~60 petals, while float4 -> float8 is exact.
    SUM(amount::FLOAT8::NUMERIC) AS total_spend,
    MIN(amount) AS min_purchase_amount,
    MAX(amount) AS max_purchase_amount,
    AVG(amount) AS avg_purchase_amount,
    PERCENTILE_DISC(0.5)
        WITHIN GROUP (ORDER BY amount) AS median_purchase_amount,
    STDDEV(amount) AS std_purchase_amount
FROM fantasy.events;

-- Distribution extract for the notebook, filtered to match the population every downstream
-- query uses.

SELECT
    amount
FROM fantasy.events
WHERE amount > 0;


SELECT
    COUNT(*) FILTER (WHERE amount = 0) AS zero_cost_transactions,
    COUNT(*) FILTER (WHERE amount = 0) / COUNT(*)::NUMERIC AS zero_cost_share
FROM fantasy.events;

-- "Excluded as a data quality issue" needs a reason. This extract lets the notebook check
-- whether the zero-cost rows cluster on a few players, items or dates (promotion, logging
-- artifact) or spread uniformly (systematic pricing bug).

SELECT
    e.transaction_id,
    e.id,
    e.date,
    e.item_code,
    i.game_items,
    e.seller_id
FROM fantasy.events AS e
LEFT JOIN fantasy.items AS i USING (item_code)
WHERE e.amount = 0;

------------------ 2.3. Epic item popularity --------------------------------
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


WITH paid_events AS (
    SELECT
    		transaction_id,
    		id,
    		item_code
    FROM fantasy.events
    WHERE amount > 0
),
item_transaction_stats AS (
    SELECT DISTINCT
        item_code,
        COUNT(transaction_id)
            OVER (PARTITION BY item_code) AS total_transactions,
        COUNT(transaction_id)
            OVER (PARTITION BY item_code) / COUNT(*) OVER ()::NUMERIC AS transaction_share
    FROM paid_events
),
item_buyer_stats AS (
    SELECT
        item_code,
        COUNT(DISTINCT id)
            / (
                SELECT COUNT(DISTINCT id)
                FROM paid_events
            )::NUMERIC AS buyer_share
    FROM paid_events
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