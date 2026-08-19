/*
Real-money conversion.
 
"Paradise petals" is the premium currency: players earn it through quests OR buy it for money.
The binary `payer` flag marks the second group and is the only revenue-related field in the
schema — `amount` in fantasy.events is denominated in petals, not money.
*/

SELECT
    COUNT(id) AS players_total,
    SUM(payer) AS payers_total,
    SUM(payer) / COUNT(id)::NUMERIC AS payer_share
FROM fantasy.users;

-- Raw counts are kept alongside the shares: the smallest race has 1.2k players, and the
-- spread is tested in the notebook rather than read off the ranking.

SELECT
    r.race,
    SUM(u.payer) AS payers_race,
    COUNT(u.id) AS players_race,
    SUM(u.payer) / COUNT(u.id)::NUMERIC AS payer_share
FROM fantasy.users AS u
LEFT JOIN fantasy.race AS r USING (race_id)
GROUP BY r.race
ORDER BY payer_share DESC;