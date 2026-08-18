/*
Analysis: Player activity by character race (ad hoc request)
 
Request from the analytics team: test the hypothesis that some races are
harder to play and therefore require more epic item purchases to progress.
The design goal is balance — no race should be markedly easier or harder.
 
The question is therefore about game balance, not about audience segmentation
for marketing. Purchase intensity is read here as a proxy for progression
difficulty.
 
All amounts are in paradise petals (in-game currency), not real money.
*/

------------------- Purchase activity by race ---------------------------
/*
Per race:
  - registered players;
  - buyers (players with at least one non-zero purchase) and their share;
  - share of real-money payers among buyers;
  - purchases per buyer;
  - average purchase amount per buyer;
  - total spend per buyer.
 
Two distinct populations are involved and must not be conflated:
  buyers  — spend petals on epic items (may have earned them via quests);
  payers  — bought petals for real money (`payer` = 1).
A player can be one without being the other.
 
Zero-cost transactions are excluded per the task specification.
*/

WITH total_players AS (
    SELECT
        race_id,
        COUNT(id) AS total_registered_players
    FROM fantasy.users
    GROUP BY race_id
),
-- Buyer-side aggregates. INNER JOIN drops races with no purchases at all;
-- verified that no such race exists in this data.
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
-- Payers restricted to buyers only: the denominator of payers_buyers_share
-- is buyers, so the numerator must come from the same population.
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