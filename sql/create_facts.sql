CREATE TABLE IF NOT EXISTS fact_champion_pick (
    gameid VARCHAR(100) NOT NULL,
    champion_key INTEGER NOT NULL,
    team_key INTEGER NOT NULL,
    role_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    tournament_key INTEGER NOT NULL,

    side VARCHAR(10),
    result INTEGER,
    kills INTEGER,
    deaths INTEGER,
    assists INTEGER,

    PRIMARY KEY (gameid, champion_key),

    FOREIGN KEY (champion_key)
        REFERENCES dim_champion(champion_key),

    FOREIGN KEY (team_key)
        REFERENCES dim_team(team_key),

    FOREIGN KEY (role_key)
        REFERENCES dim_role(role_key),

    FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    FOREIGN KEY (tournament_key)
        REFERENCES dim_tournament(tournament_key)
);

CREATE TABLE IF NOT EXISTS fact_champion_ban (
    gameid VARCHAR(100) NOT NULL,
    champion_key INTEGER NOT NULL,
    team_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    tournament_key INTEGER NOT NULL,

    side VARCHAR(10),

    PRIMARY KEY (gameid, champion_key),

    FOREIGN KEY (champion_key)
        REFERENCES dim_champion(champion_key),

    FOREIGN KEY (team_key)
        REFERENCES dim_team(team_key),

    FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    FOREIGN KEY (tournament_key)
        REFERENCES dim_tournament(tournament_key)
);