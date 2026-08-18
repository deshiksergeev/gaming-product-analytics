/*
Analysis: Player-level spend extract

Supports the metric validation section of the notebook: A/A simulation,
MDE estimation and power analysis all operate on the player grain, whereas
fantasy.events is at the transaction grain.

Grain: one row = one buyer (a player with at least one non-zero purchase).

The `payer` flag is carried through so that the two candidate experiment
metrics can be evaluated on the same extract:
  - real-money conversion (binary, per player);
  - in-game spend per buyer (continuous, heavy-tailed).
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