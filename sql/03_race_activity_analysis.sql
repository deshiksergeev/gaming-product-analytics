/*
Project: Secrets of Darkwood
Analysis: Player activity by character race
Description:
Compare player activity and monetization behavior across character races
using buyer conversion, payer conversion, purchase frequency, average
purchase amount, and revenue per buyer.
*/


-- ============================================================
-- Ad Hoc Analysis: Player Activity by Character Race
-- ============================================================

WITH total_players AS (
    SELECT
        race_id,
        COUNT(id) AS total_registered_players
    FROM fantasy.users
    GROUP BY race_id
),
in_game_buyers AS (
    SELECT
        u.race_id,
        COUNT(DISTINCT u.id) AS total_buyers,
        COUNT(e.amount) AS total_purchases,
        SUM(e.amount) AS total_revenue
    FROM fantasy.users AS u
    INNER JOIN fantasy.events AS e USING (id)
    WHERE e.amount > 0
    GROUP BY u.race_id
),
payers AS (
    SELECT
        race_id,
        SUM(payer) AS total_payers
    FROM fantasy.users
    WHERE id IN (
        SELECT id
        FROM fantasy.events
        WHERE amount > 0
    )
    GROUP BY race_id
)
SELECT
    r.race,
    tp.total_registered_players,
    ib.total_buyers,
    ib.total_buyers
        / tp.total_registered_players::NUMERIC AS buyers_registered_share,
    p.total_payers
        / ib.total_buyers::NUMERIC AS payers_buyers_share,
    ib.total_purchases
        / ib.total_buyers::NUMERIC AS avg_purchases_per_buyer,
    ib.total_revenue
        / ib.total_purchases::NUMERIC AS avg_purchase_amount,
    ib.total_revenue
        / ib.total_buyers::NUMERIC AS revenue_per_buyer
FROM total_players AS tp
INNER JOIN in_game_buyers AS ib USING (race_id)
INNER JOIN payers AS p USING (race_id)
INNER JOIN fantasy.race AS r USING (race_id)
ORDER BY revenue_per_buyer DESC;