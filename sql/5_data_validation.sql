
SELECT
    (SELECT COUNT(*) FROM stg_match_data
     WHERE league <> 'LCS.A'
       AND position IN ('top', 'jng', 'mid', 'bot', 'sup')) AS expected_picks,
    (SELECT COUNT(*) FROM fact_champion_pick) AS actual_picks;


WITH bans AS (
    SELECT s.gameid, TRIM(b.champion) AS champion
    FROM stg_match_data s
    CROSS JOIN LATERAL (
        VALUES (s.ban1), (s.ban2), (s.ban3), (s.ban4), (s.ban5)
    ) AS b(champion)
    WHERE s.position = 'team'
      AND s.league <> 'LCS.A'
      AND b.champion IS NOT NULL
      AND TRIM(b.champion) <> ''
)
SELECT
    (SELECT COUNT(*) FROM bans) AS expected_bans,
    (SELECT COUNT(*) FROM fact_champion_ban) AS actual_bans;


SELECT 'Pick' AS fact_table,
       COUNT(*) FILTER (WHERE gameid IS NULL OR champion_key IS NULL
           OR team_key IS NULL OR role_key IS NULL OR date_key IS NULL
           OR tournament_key IS NULL) AS missing_records
FROM fact_champion_pick
UNION ALL
SELECT 'Ban',
       COUNT(*) FILTER (WHERE gameid IS NULL OR champion_key IS NULL
           OR team_key IS NULL OR date_key IS NULL
           OR tournament_key IS NULL)
FROM fact_champion_ban;


SELECT 'Pick' AS fact_table, gameid, champion_key, COUNT(*) AS occurrences
FROM fact_champion_pick
GROUP BY gameid, champion_key
HAVING COUNT(*) > 1
UNION ALL
SELECT 'Ban', gameid, champion_key, COUNT(*)
FROM fact_champion_ban
GROUP BY gameid, champion_key
HAVING COUNT(*) > 1;