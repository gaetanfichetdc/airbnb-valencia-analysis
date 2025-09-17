# 🏠 Airbnb in Valencia — Data Exploration & Visualization

This project analyzes Airbnb activity in Valencia (2010–2025).  
It covers data ingestion (PostgreSQL), cleaning, spatio-temporal queries, and visualization in Metabase and Python.

---

## 📂 Repository structure

```
├── airbnb_valencia.sql              # SQL script to create & load all tables
├── calendar.csv                     # Availability and daily prices
├── create_listings.sql              # Create table schema for listings
├── fixed_rent_prices_valencia.csv   # Cleaned rent price data
├── listings.csv                     # Raw Airbnb listings
├── neighbourhoods.csv               # Neighbourhood metadata
├── neighbourhoods.geojson           # GeoJSON shapes for mapping
├── population_data.csv              # Population by neighbourhood
├── population_data_time.csv         # Population by neighbourhood & year
├── queries_valencia.sql             # Analysis queries (heatmaps, price trends, etc.)
└── reviews.csv.gz                   # Review history (compressed, 2010–2025)
```

---

## 🛠️ Setup

### 1. Create the PostgreSQL database
```bash
createdb airbnb_valencia
psql -d airbnb_valencia -f airbnb_valencia.sql
```

⚠️ Note: The `reviews.csv` dataset is provided as a compressed file (`reviews.csv.gz`).  
Decompress it before running the SQL script if needed:

```bash
gunzip reviews.csv.gz
```

### 2. Run the analysis queries
```bash
psql -d airbnb_valencia -f queries_valencia.sql
```

---

## 📊 Visualization

- Connect Metabase (or another BI tool) to the `airbnb_valencia` database.  
- Use the queries in `queries_valencia.sql` to generate:  
  - Heatmaps of Airbnb listings in Valencia  
  - Yearly/monthly evolution (2010–2025)  
  - Price trends vs. number of reviews  
