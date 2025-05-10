---reservations
INSERT INTO TABLE airline_dwh.reservations
SELECT
  CAST(r.reservation_id AS STRING)                         AS reservation_id,
  CAST(r.passenger_id AS STRING)                           AS passenger_id,

  'UNKNOWN_AIRPORT'                                         AS airport_code,
  'UNKNOWN_AIRPLANE'                                        AS airplane_id,

  0.0                                                       AS revenue,
  0.0                                                       AS profit,
  r.payment_method                                          AS payment_method,
  r.booking_chanel                                          AS reservation_channel,
  'UNKNOWN_FARE'                                            AS fare_basis,
  0.0                                                       AS fuel_cost,
  0.0                                                       AS crew_fees,
  0.0                                                       AS meal_fees,
  0.0                                                       AS total_cost,

  'UNKNOWN_AIRPORT_NAME'                                    AS airport_name,
  'UNKNOWN_CITY'                                            AS airport_city,
  'UNKNOWN_COUNTRY'                                         AS airport_country,

  'UNKNOWN_PROMOTION'                                       AS promotion_name,
  'UNKNOWN_CATEGORY'                                        AS promotion_category,
  'NO_DESCRIPTION'                                          AS promotion_description,

  'UNKNOWN_MODEL'                                           AS model,
  -1                                                        AS capacity,
  'UNKNOWN_MANUFACTURER'                                    AS manufacturer,
  -1                                                        AS business_seats,
  -1                                                        AS economy_seats,
  -1                                                        AS first_class_seats,
  -1.0                                                      AS max_range_km,
  -1.0                                                      AS max_speed_kmh,
  -1.0                                                      AS fuel_capacity,
  -1                                                        AS number_of_engines,
  'UNKNOWN_ENGINE'                                          AS engine_type,
  -1.0                                                      AS fuel_consumption,
  'INACTIVE'                                                AS activity_status,

  COALESCE(d.day_of_week, 'Unknown')                        AS day_of_week,
  'dsa',
  'dsadas',
  'dasdsa',
  'dasdsa',
  'dasads',
  'dsat',
  COALESCE(d.calendar_quarter, 'Unknown')                   AS calendar_quarter,
  COALESCE(d.calendar_year, -1)                             AS calendar_year,
  COALESCE(d.calendar_month_name, 'Unknown')                AS calendar_month_name

FROM airline_staging.reservation r
LEFT JOIN airline_staging_migration.date_dim d
  ON CAST(r.booking_date AS DATE) = 'd.date';