SET hive.support.concurrency=true;
SET hive.enforce.bucketing=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;


-- passenger
-- This query is used to update the passenger table in the airline_dwh (ACID table)

MERGE INTO airline_dwh.passenger AS target
USING (
  SELECT
    CAST(passenger_id AS STRING) AS passenger_id,
    gender, occupation, nationality, membership_status,
    loyalty_tier,
    CASE
      WHEN is_inserted IS NOT NULL THEN CAST(is_inserted AS DATE)
      ELSE CAST(is_modified AS DATE)
    END AS start_date,
    CAST(is_modified AS DATE) AS end_update
  FROM airline_staging.passenger
  WHERE is_inserted IS NOT NULL OR is_modified IS NOT NULL
) AS source
ON target.passenger_id = source.passenger_id AND target.end_date = DATE '9999-12-31'

WHEN MATCHED AND source.end_update IS NOT NULL THEN
  UPDATE SET end_date = source.end_update

WHEN NOT MATCHED THEN
  INSERT (
    passenger_id, gender, occupation, nationality,
    membership_status, loyalty_tier, start_date, end_date
  )
  VALUES (
    source.passenger_id, source.gender, source.occupation, source.nationality,
    source.membership_status, source.loyalty_tier, source.start_date,
    DATE '9999-12-31'
  );


-- passenger_no
-- This query is used to update the passenger_no table in the airline_dwh (NoN ACID table)

WITH expired AS (
  SELECT
    curr.passenger_id,
    curr.passenger_key,
    curr.age_category,
    curr.age,
    curr.gender,
    curr.occupation,
    curr.nationality,
    curr.membership_status,
    curr.country,
    curr.city,
    curr.loyalty_tier,
    curr.start_date,
    CAST(stage.is_modified AS DATE) AS end_date,
    curr.created_at
  FROM airline_dwh.passenger_no curr
  JOIN airline_staging.passenger stage
    ON curr.passenger_id = CAST(stage.passenger_id AS STRING)
  WHERE curr.end_date = DATE '9999-12-31'
    AND stage.is_modified IS NOT NULL
),
new_data AS (
  SELECT
    CAST(stage.passenger_id AS STRING) AS passenger_id,
    NULL AS passenger_key,
    NULL AS age_category,
    NULL AS age,
    stage.gender,
    stage.occupation,
    stage.nationality,
    stage.membership_status,
    NULL AS country,
    NULL AS city,
    stage.loyalty_tier,
    COALESCE(CAST(stage.is_inserted AS DATE), CAST(stage.is_modified AS DATE)) AS start_date,
    DATE '9999-12-31' AS end_date,
    CURRENT_TIMESTAMP AS created_at
  FROM airline_staging.passenger stage
  WHERE stage.is_inserted IS NOT NULL OR stage.is_modified IS NOT NULL
),
unchanged AS (
  SELECT
    passenger_id,
    passenger_key,
    age_category,
    age,
    gender,
    occupation,
    nationality,
    membership_status,
    country,
    city,
    CAST(loyalty_tier AS STRING) AS loyalty_tier,
    start_date,
    end_date,
    created_at
  FROM airline_dwh.passenger_no
  WHERE end_date = DATE '9999-12-31'
    AND passenger_id NOT IN (
      SELECT CAST(passenger_id AS STRING)
      FROM airline_staging.passenger
      WHERE is_modified IS NOT NULL
    )
)
INSERT OVERWRITE TABLE airline_dwh.passenger_no
SELECT * FROM expired
UNION ALL
SELECT * FROM new_data
UNION ALL
SELECT * FROM unchanged;








