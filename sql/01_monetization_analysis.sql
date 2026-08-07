/*
Project: Secrets of Darkwood
Analysis: Player monetization (real-money conversion)
 
Business context:
"Paradise petals" is the premium in-game currency. It can be earned through
quests OR bought for real money. The `payer` flag marks players who bought it
for real money — this is the only revenue-related field in the schema.
 
Note on terminology: the `amount` field in fantasy.events is denominated in
paradise petals, NOT in real money. Sums over `amount` are in-game spend,
not revenue.
*/
 
-- ============================================================
-- 1.1. Overall payer share
-- ============================================================
/*
Share of registered players who bought premium currency for real money.
 
`payer` is binary: 1 — paying player, 0 — non-paying.
*/

SELECT
    COUNT(id) AS players_total,
    SUM(payer) AS payers_total,
    SUM(payer) / COUNT(id)::NUMERIC AS payer_share
FROM fantasy.users;


-- ============================================================
-- 1.2. Payer share by character race
-- ============================================================
/*
Tests whether real-money conversion depends on the race chosen by the player.
 
Output is deliberately kept at raw counts as well as shares: the smallest race
has ~1.2k players, so the shares alone are not interpretable without knowing
the denominator. Significance of the observed spread is tested in the notebook
(chi-squared test of independence), not here.
*/

SELECT
    r.race,
    SUM(u.payer) AS payers_race,
    COUNT(u.id) AS players_race,
    SUM(u.payer) / COUNT(u.id)::NUMERIC AS payer_share
FROM fantasy.users AS u
LEFT JOIN fantasy.race AS r USING (race_id)
GROUP BY r.race
ORDER BY payer_share DESC;