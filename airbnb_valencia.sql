-- ===========================
-- 1. Drop old tables
-- ===========================
DROP TABLE IF EXISTS listings CASCADE;
DROP TABLE IF EXISTS calendar CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS neighbourhoods CASCADE;
DROP TABLE IF EXISTS clean_listings CASCADE;
DROP TABLE IF EXISTS clean_reviews CASCADE;

-- ===========================
-- 2. Create listings from header file
-- ===========================
\i create_listings.sql

-- ===========================
-- 3. Create other raw tables
-- ===========================
CREATE TABLE calendar (
    listing_id TEXT,
    date TEXT,
    available TEXT,
    price TEXT,
    adjusted_price TEXT,
    minimum_nights TEXT,
    maximum_nights TEXT
);

CREATE TABLE reviews (
    listing_id TEXT,
    review_id TEXT,
    review_date TEXT,
    reviewer_id TEXT,
    reviewer_name TEXT,
    comments TEXT
);

CREATE TABLE neighbourhoods (
    neighbourhood_group TEXT,
    neighbourhood TEXT
);

-- ===========================
-- 4. Load CSVs
-- ===========================
\COPY listings FROM 'listings.csv' WITH (FORMAT csv, HEADER true, QUOTE '"');
\COPY calendar FROM 'calendar.csv' WITH (FORMAT csv, HEADER true, QUOTE '"');
\COPY reviews FROM 'reviews.csv' WITH (FORMAT csv, HEADER true, QUOTE '"');
\COPY neighbourhoods FROM 'neighbourhoods.csv' WITH (FORMAT csv, HEADER true);

-- ===========================
-- 5. Create clean working tables
-- ===========================
CREATE TABLE clean_listings AS
SELECT
    id::BIGINT,
    neighbourhood_cleansed AS neighbourhood,
    room_type,
    regexp_replace(price, '[$,]', '', 'g')::NUMERIC AS price,
    NULLIF(minimum_nights, '')::INT AS minimum_nights,
    NULLIF(availability_365, '')::INT AS availability_365,
    NULLIF(number_of_reviews, '')::INT AS number_of_reviews,
    NULLIF(latitude, '')::FLOAT AS latitude,
    NULLIF(longitude, '')::FLOAT AS longitude
FROM listings
WHERE price IS NOT NULL AND price <> '';

CREATE TABLE clean_reviews AS
SELECT
    listing_id::BIGINT,
    review_date::DATE
FROM reviews
WHERE listing_id ~ '^[0-9]+$';

-- ===========================
-- 6. Row count sanity check
-- ===========================
SELECT 'listings' AS table, COUNT(*) FROM listings
UNION ALL
SELECT 'calendar', COUNT(*) FROM calendar
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'neighbourhoods', COUNT(*) FROM neighbourhoods
UNION ALL
SELECT 'clean_listings', COUNT(*) FROM clean_listings
UNION ALL
SELECT 'clean_reviews', COUNT(*) FROM clean_reviews;
