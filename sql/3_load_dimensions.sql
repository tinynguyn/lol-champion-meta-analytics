
WITH all_champions AS (
    SELECT TRIM(champion) AS champion_name
    FROM stg_match_data
    WHERE league <> 'LCS.A'
      AND champion IS NOT NULL

    UNION

    SELECT TRIM(b.champion) AS champion_name
    FROM stg_match_data s
    CROSS JOIN LATERAL (
        VALUES (s.ban1), (s.ban2), (s.ban3), (s.ban4), (s.ban5)
    ) AS b(champion)
    WHERE s.league <> 'LCS.A'
      AND s.position = 'team'
      AND b.champion IS NOT NULL
)
INSERT INTO dim_champion (champion_name)
SELECT champion_name
FROM all_champions
WHERE champion_name <> ''
ON CONFLICT (champion_name) DO NOTHING;

INSERT INTO dim_team (team_name)
SELECT DISTINCT team
FROM stg_match_data
WHERE league <> 'LCS.A' AND team IS NOT NULL
ON CONFLICT (team_name) DO NOTHING;

INSERT INTO dim_role (role_name)
VALUES
    ('top'),
    ('jng'),
    ('mid'),
    ('bot'),
    ('sup')
ON CONFLICT (role_name) DO NOTHING;
SELECT *
FROM dim_role
ORDER BY role_key;

INSERT INTO dim_date (
    date_key,
    full_date,
    day,
    week_of_year,
    month,
    year
)
SELECT DISTINCT
    TO_CHAR(date::timestamp, 'YYYYMMDD')::INTEGER,
    date::timestamp::DATE,
    EXTRACT(DAY FROM date::timestamp)::INTEGER,
    EXTRACT(WEEK FROM date::timestamp)::INTEGER,
    EXTRACT(MONTH FROM date::timestamp)::INTEGER,
    EXTRACT(YEAR FROM date::timestamp)::INTEGER
FROM stg_match_data
WHERE league <> 'LCS.A'
  AND date IS NOT NULL
  AND TRIM(date) <> ''
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO dim_tournament (
    league, region, split, season_year
)
SELECT DISTINCT
    league,
    CASE
        WHEN league = 'LCK' THEN 'Korea'
        WHEN league = 'LPL' THEN 'China'
        WHEN league = 'LCS' THEN 'North America'
        WHEN league = 'LEC' THEN 'Europe'
        WHEN league = 'PCS' THEN 'Pacific'
        WHEN league = 'CBLOL' THEN 'Brazil'
        WHEN league = 'TCL' THEN 'Turkey'
        ELSE 'Unknown'
    END AS region,
    split,
    EXTRACT(YEAR FROM date::timestamp)::INTEGER
FROM stg_match_data
WHERE league <> 'LCS.A'
  AND league IS NOT NULL
  AND split IS NOT NULL
  AND date IS NOT NULL
  AND TRIM(date) <> ''
ON CONFLICT (league, split, season_year) DO NOTHING;


