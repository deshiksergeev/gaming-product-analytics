/*
Project: Secrets of Darkwood
Analysis: Player monetization
Description:
Analyze the overall share of paying players and compare payer conversion
across character races.
*/

-- ============================================================
-- 1.1. Overall Payer Share
-- ============================================================
/*
Calculate the share of registered players who made at least one payment.

The `payer` field is a binary indicator:
1 — paying player
0 — non-paying player.
*/

SELECT
    COUNT(id) AS players_total,
    SUM(payer) AS payers_total,
    SUM(payer) / COUNT(id)::NUMERIC AS payer_share
FROM fantasy.users;


-- ============================================================
-- 1.2. Payer Share by Character Race
-- ============================================================
/*
Compare the share of paying players across character races.

The analysis joins player data with the race reference table
to calculate the number and share of paying players for each race.
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