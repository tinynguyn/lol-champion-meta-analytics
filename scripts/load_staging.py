import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine, text

# 1. Find the project directory
project_dir = Path(__file__).resolve().parent.parent

# 2. Define the CSV file path
csv_path = project_dir / "data" / "2020-spring-match-data-OraclesElixir-2020-05-15.csv"

# 3. Read CSV
df = pd.read_csv(csv_path, dtype=str)

# 4. Check data
print("Rows:", len(df))
print("Columns:", len(df.columns))
print(df.head())

# 5. Connect to PostgreSQL
engine = create_engine(
    "postgresql+psycopg://localhost:5432/lol_warehouse"
)

with engine.connect() as connection:
    result = connection.execute(text("SELECT current_database();"))
    print("Connected to:", result.scalar())

# 6. Load CSV into PostgreSQL staging table
df.to_sql(
    name="stg_match_data",
    con=engine,
    if_exists="replace",
    index=False,
    chunksize=1000
)

print("Staging data loaded successfully!")