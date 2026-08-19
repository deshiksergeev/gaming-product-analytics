/*
Purchase activity by race (ad hoc).
 
The analytics team's hypothesis is that some races are harder to play and so need more epic
items to progress. This is a game balance question, not audience segmentation, and purchase
intensity stands in for progression difficulty.
 
Two populations that must not be conflated: buyers spend petals (possibly earned via quests),
payers bought petals for money. A player can be one without the other. Amounts are in petals.
*/

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
        COUNT(e.transaction_id) AS total_purchases,
        SUM(e.amount::FLOAT8::NUMERIC) AS total_spend
    FROM fantasy.users AS u
    INNER JOIN fantasy.events AS e USING (id)
    WHERE e.amount > 0
    GROUP BY u.race_id
),
-- Restricted to buyers, because buyers are the denominator of payers_buyers_share below.
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
    ib.total_spend
        / ib.total_purchases::NUMERIC AS avg_purchase_amount,
    ib.total_spend
        / ib.total_buyers::NUMERIC AS spend_per_buyer
FROM total_players AS tp
INNER JOIN in_game_buyers AS ib USING (race_id)
INNER JOIN payers AS p USING (race_id)
INNER JOIN fantasy.race AS r USING (race_id)
ORDER BY avg_purchases_per_buyer DESC;