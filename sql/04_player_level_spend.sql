/*
Player-level extract for the metric validation section: one row per buyer, since fantasy.events
is at the transaction grain and the A/A simulation is not.
 
Note the grain is buyers, not registered players — the notebook pads the 8,422 non-buyers back
in with zeros, because conditioning on having bought is conditioning on a post-treatment
outcome. The `payer` flag rides along so both candidate metrics come from the same extract.
*/

SELECT
    u.id AS player_id,
    r.race,
    u.payer,
    COUNT(e.transaction_id) AS purchases,
    SUM(e.amount::FLOAT8::NUMERIC) AS total_spend,
    AVG(e.amount) AS avg_purchase_amount
FROM fantasy.users AS u
INNER JOIN fantasy.events AS e USING (id)
LEFT JOIN fantasy.race AS r USING (race_id)
WHERE e.amount > 0
GROUP BY u.id, r.race, u.payer;