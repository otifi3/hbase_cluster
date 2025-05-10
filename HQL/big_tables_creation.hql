CREATE TABLE airline_dwh.passenger (
    passenger_id STRING,
    passenger_key STRING,
    age_category STRING,
    age INT,
    gender STRING,
    occupation STRING,
    nationality STRING,
    membership_status STRING,
    country STRING,
    city STRING,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP
)
PARTITIONED BY (loyalty_tier STRING)
CLUSTERED BY (passenger_id) INTO 16 BUCKETS
STORED AS ORC
TBLPROPERTIES (
  'transactional' = 'true'
);


INSERT INTO airline_dwh.passenger PARTITION (loyalty_tier)
SELECT 
    passenger_id,
    passenger_key,
    age_category,
    age,
    gender,
    occupation,
    nationality,
    membership_status,
    city,
    start_date,
    end_date,
    created_at,
    country,
    loyalty_tier
FROM airline_staging_migration.passenger_dim;


CREATE TABLE airline_dwh.reservations (
    reservation_id STRING,
    passenger_id STRING,
    airport_code STRING,
    airplane_id STRING,
    revenue DOUBLE,
    profit DOUBLE,
    payment_method STRING,
    reservation_channel STRING,
    fare_basis STRING,
    airport_fees DOUBLE,
    taxes DOUBLE,
    fuel_cost DOUBLE,
    crew_fees DOUBLE,
    meal_fees DOUBLE,
    total_cost DOUBLE,
    distance_in_miles DOUBLE,

    airport_name STRING,
    airport_city STRING,
    airport_country STRING,

    promotion_name STRING,
    promotion_category STRING,
    promotion_description STRING,

    model STRING,
    capacity INT,
    manufacturer STRING,
    business_seats INT,
    economy_seats INT,
    first_class_seats INT,
    max_range_km DOUBLE,
    max_speed_kmh DOUBLE,
    fuel_capacity DOUBLE,
    number_of_engines INT,
    engine_type STRING,
    fuel_consumption DOUBLE,
    activity_status STRING,
    
    full_date_description STRING, 
    day_of_week STRING,
    day_number_in_calendar_month INT,
    calendar_week_number_in_year INT,
    calendar_quarter STRING,
    calendar_month_name STRING
)
PARTITIONED BY (calendar_year STRING)
CLUSTERED BY (passenger_id) INTO 16 BUCKETS
STORED AS ORC;


INSERT INTO TABLE airline_dwh.reservations PARTITION (calendar_year)
SELECT 
    rf.reservation_id,
    rf.passenger_id,
    rf.airport_code,
    rf.airplane_id,
    rf.revenue,
    rf.profit,
    rf.payment_method,
    rf.reservation_channel,
    rf.fare_basis,
    rf.airport_fees,
    rf.taxes,
    rf.fuel_cost,
    rf.crew_fees,
    rf.meal_fees,
    rf.total_cost,
    rf.distance_in_miles,

    ad.airport_name,
    ad.city AS airport_city,
    ad.country AS airport_country, 

    pd.name AS promotion_name,
    pd.category AS promotion_category,
    pd.description AS promotion_description,

    da.model,
    da.capacity,
    da.manufacturer,
    da.business_seats,
    da.economy_seats,
    da.first_class_seats,
    da.max_range_km,
    da.max_speed_kmh,
    da.fuel_capacity,
    da.number_of_engines,
    da.engine_type,
    da.fuel_consumption,
    da.activity_status,

    dd.full_date_description,
    dd.day_number_in_calendar_month AS day,
    dd.calendar_week_number_in_year AS week,
    dd.calendar_quarter AS quarter,
    dd.day_of_week AS weekday,
    dd.calendar_month_name,
    dd.calendar_year
FROM 
    airline_staging_migration.reservation_fact rf
JOIN airline_staging_migration.airport_dim ad 
    ON rf.airport_code = ad.airport_code
JOIN airline_staging_migration.date_dim dd 
    ON rf.date_id = dd.date_id
JOIN airline_staging_migration.dim_promotion pd 
    ON rf.promotion_id = pd.promotion_id
JOIN airline_staging_migration.dim_airplane da 
    ON rf.airplane_id = da.airplane_id;


