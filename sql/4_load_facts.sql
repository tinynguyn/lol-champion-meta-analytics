INSERT INTO fact_champion_pick (
    gameid,
    champion_key,
    team_key,
    role_key,
    date_key,
    tournament_key,
    side,
    result,
    kills,
    deaths,
    assists
)
SELECT
    s.gameid,
    c.champion_key,
    t.team_key,
    r.role_key,
    d.date_key,
    tr.tournament_key,
    s.side,
    s.result::INTEGER,
    s.kills::NUMERIC::INTEGER,
    s.deaths::NUMERIC::INTEGER,
    s.assists::NUMERIC::INTEGER
FROM stg_match_data s
JOIN dim_champion c
    ON s.champion = c.champion_name
JOIN dim_team t
    ON s.team = t.team_name
JOIN dim_role r
    ON s.position = r.role_name
JOIN dim_date d
    ON s.date::timestamp::DATE = d.full_date
JOIN dim_tournament tr
    ON s.league = tr.league
    AND s.split = tr.split
    AND EXTRACT(YEAR FROM s.date::timestamp)::INTEGER = tr.season_year
WHERE s.league <> 'LCS.A'
  AND s.position IN ('top', 'jng', 'mid', 'bot', 'sup')
ON CONFLICT (gameid, champion_key) DO NOTHING;

WITH bans AS (
    SELECT
        s.gameid,
        s.team,
        s.side,
        s.date,
        s.league,
        s.split,
        TRIM(b.champion) AS champion
    FROM stg_match_data s
    CROSS JOIN LATERAL (
        VALUES
            (s.ban1),
            (s.ban2),
            (s.ban3),
            (s.ban4),
            (s.ban5)
    ) AS b(champion)
    WHERE s.position = 'team'
      AND s.league <> 'LCS.A'
      AND b.champion IS NOT NULL
      AND TRIM(b.champion) <> ''
)
INSERT INTO fact_champion_ban (
    gameid,
    champion_key,
    team_key,
    date_key,
    tournament_key,
    side
)
SELECT
    b.gameid,
    c.champion_key,
    t.team_key,
    d.date_key,
    tr.tournament_key,
    b.side
FROM bans b
JOIN dim_champion c
    ON b.champion = c.champion_name
JOIN dim_team t
    ON b.team = t.team_name
JOIN dim_date d
    ON b.date::timestamp::DATE = d.full_date
JOIN dim_tournament tr
    ON b.league = tr.league
    AND b.split = tr.split
    AND EXTRACT(YEAR FROM b.date::timestamp)::INTEGER = tr.season_year
ON CONFLICT (gameid, champion_key) DO NOTHING;