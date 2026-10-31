
CREATE OR REPLACE VIEW vw_champion_meta AS
WITH games_per_league AS (
    SELECT tournament_key,
           COUNT(DISTINCT gameid) AS total_games
    FROM fact_champion_pick
    GROUP BY tournament_key
),
picks AS (
    SELECT tournament_key,
           champion_key,
           COUNT(*) AS total_picks,
           SUM(result) AS total_wins
    FROM fact_champion_pick
    GROUP BY tournament_key, champion_key
),
bans AS (
    SELECT tournament_key,
           champion_key,
           COUNT(*) AS total_bans
    FROM fact_champion_ban
    GROUP BY tournament_key, champion_key
)
SELECT
    t.league,
    c.champion_name,
    g.total_games,
    COALESCE(p.total_picks, 0) AS total_picks,
    COALESCE(p.total_wins, 0) AS total_wins,
    COALESCE(b.total_bans, 0) AS total_bans,
    ROUND(100.0 * COALESCE(p.total_picks, 0) / NULLIF(g.total_games, 0), 2) AS pick_rate,
    ROUND(100.0 * COALESCE(b.total_bans, 0) / NULLIF(g.total_games, 0), 2) AS ban_rate,
    ROUND(100.0 * p.total_wins / NULLIF(p.total_picks, 0), 2) AS win_rate
FROM games_per_league g
JOIN dim_tournament t
    ON t.tournament_key = g.tournament_key
CROSS JOIN dim_champion c
LEFT JOIN picks p
    ON p.tournament_key = g.tournament_key
   AND p.champion_key = c.champion_key
LEFT JOIN bans b
    ON b.tournament_key = g.tournament_key
   AND b.champion_key = c.champion_key;


SELECT league, champion_name, total_games, total_picks, total_bans,
       pick_rate, ban_rate, win_rate
FROM vw_champion_meta
WHERE league = 'LCK'
ORDER BY pick_rate DESC, champion_name
LIMIT 10;


SELECT league, champion_name, COUNT(*) AS row_count
FROM vw_champion_meta
GROUP BY league, champion_name
HAVING COUNT(*) > 1;

SELECT *
FROM vw_champion_meta
WHERE league = 'LCK'
ORDER BY pick_rate DESC
LIMIT 10;

SELECT league, champion_name,
       total_games, total_picks, total_bans,
       pick_rate, ban_rate, win_rate
FROM vw_champion_meta
WHERE league = 'LCK'
  AND total_picks >= 20
ORDER BY win_rate DESC, champion_name
LIMIT 10;

SELECT *
FROM vw_champion_meta
WHERE league = 'LPL'
ORDER BY ban_rate DESC
LIMIT 10;