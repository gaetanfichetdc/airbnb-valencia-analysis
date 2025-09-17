-- List of Queries for visualisation in Metabase 

\echo '--- Query: Which neighbourhoods show the highest concentration of Airbnb?'

SELECT 
  l.neighbourhood AS neighbourhood_name,
  COUNT(l.id) AS n_listings,
  p.population,
  ROUND(1000.0 * COUNT(l.id) / p.population, 2) AS listings_per_1000_residents
FROM clean_listings l
JOIN population_data p
  ON REGEXP_REPLACE(UPPER(unaccent(l.neighbourhood)), '[^A-Z0-9]', '', 'g') = p.key
GROUP BY l.neighbourhood, p.population
HAVING p.population > 0
ORDER BY listings_per_1000_residents DESC
LIMIT 15;

\echo '--- Query: Evolution of listings per habitants in time (top 10 boroughs)'

WITH yearly_listings AS (
  SELECT 
    l.neighbourhood,
    DATE_PART('year', r.review_date) AS year,
    COUNT(DISTINCT l.id) AS n_listings
  FROM clean_listings l
  JOIN clean_reviews r ON l.id = r.listing_id
  GROUP BY l.neighbourhood, DATE_PART('year', r.review_date)
),
with_pop AS (
  SELECT 
    yl.neighbourhood,
    yl.year,
    yl.n_listings,
    p.population,
    ROUND(1000.0 * yl.n_listings / p.population, 2) AS listings_per_1000
  FROM yearly_listings yl
  JOIN population_data_time p
    ON REGEXP_REPLACE(UPPER(unaccent(yl.neighbourhood)), '[^A-Z0-9]', '', 'g') = p.key
   AND yl.year = p.year
),
top10 AS (
  SELECT neighbourhood
  FROM with_pop
  WHERE year = 2024
  ORDER BY listings_per_1000 DESC
  LIMIT 10
)
SELECT *
FROM with_pop
WHERE neighbourhood IN (SELECT neighbourhood FROM top10)
ORDER BY neighbourhood, year;

\echo '--- Query: Are larger or smaller barrios are more Airbnb-saturated?'

SELECT 
  l.neighbourhood AS neighbourhood_name,
  COUNT(l.id) AS n_listings,
  p.population,
  ROUND(1000.0 * COUNT(l.id) / p.population, 2) AS listings_per_1000_residents
FROM clean_listings l
JOIN population_data p
  ON CASE
       WHEN l.neighbourhood = 'CABANYAL-CANYAMELAR' THEN 'CABANYALCANYAMELAR'
       WHEN l.neighbourhood = 'ELS ORRIOLS' THEN 'ORRIOLS'
       WHEN l.neighbourhood = 'LA FONTETA S.LLUIS' THEN 'LAFONTETASANTLLUIS'
       WHEN l.neighbourhood = 'LA VEGA BAIXA' THEN 'LABEGABAIXA'
       WHEN l.neighbourhood = 'MAHUELLA-TAULADELLA' THEN 'MAHUELLA'
       WHEN l.neighbourhood = 'SAFRANAR' THEN 'ELSAFRANAR'
       WHEN l.neighbourhood = 'SANT LLORENS' THEN 'SANTLLORENC'
       ELSE REGEXP_REPLACE(UPPER(unaccent(l.neighbourhood)), '[^A-Z0-9]', '', 'g')
     END = p.key
GROUP BY l.neighbourhood, p.population
HAVING p.population > 0
ORDER BY listings_per_1000_residents DESC
LIMIT 30;

\echo '--- Query: Heatmap of listings in Valencia over time'

WITH bins AS (
  SELECT
    id,
    ROUND(latitude::numeric, 3)  AS lat_bin,
    ROUND(longitude::numeric, 3) AS lon_bin
  FROM public.clean_listings
  WHERE latitude IS NOT NULL AND longitude IS NOT NULL
)
SELECT
  to_char(date_trunc('month', r.review_date::date), 'YYYY-MM') AS year_month,
  b.lat_bin,
  b.lon_bin,
  COUNT(DISTINCT r.listing_id) AS n_listings,
  COUNT(*) AS n_reviews
FROM public.reviews r
JOIN bins b ON b.id = r.listing_id::bigint
GROUP BY year_month, b.lat_bin, b.lon_bin
ORDER BY year_month, b.lat_bin, b.lon_bin;

\echo '--- Query: Heatmap of listings in Valencia (2024)'

SELECT 
    ROUND(latitude::numeric, 3) AS lat_bin,
    ROUND(longitude::numeric, 3) AS lon_bin,
    AVG(price) AS avg_price,
    COUNT(*) AS n_listings,
    AVG(number_of_reviews) AS avg_reviews
FROM public.clean_listings
WHERE latitude IS NOT NULL
  AND longitude IS NOT NULL
GROUP BY lat_bin, lon_bin;

\echo '--- Query: Evolution of the listing types in Valencia over time'

SELECT 
  DATE_PART('year', r.review_date) AS year,
  l.room_type,
  COUNT(DISTINCT l.id) AS n_listings
FROM clean_listings l
JOIN clean_reviews r ON l.id = r.listing_id
GROUP BY year, l.room_type
ORDER BY year, l.room_type;

\echo '--- Query: Co-evolution of the number of reviews / price per m^2 in Valencia over time'

WITH reviews_per_month AS (
  SELECT 
    DATE_TRUNC('month', r.review_date)::date AS month,
    COUNT(*) AS n_reviews
  FROM clean_reviews r
  GROUP BY DATE_TRUNC('month', r.review_date)
),
joined AS (
  SELECT 
    r.month,
    r.n_reviews,
    p.price_per_m2
  FROM reviews_per_month r
  JOIN rent_prices_valencia p
    ON r.month = p.date
)
SELECT *
FROM joined
ORDER BY month;