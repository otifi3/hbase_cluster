USE airline_staging_migration;

-- Table: overnight_stay_fact (Managed Table)
CREATE TABLE overnight_stay_fact (
    stay_id INT,
    stay_key STRING,
    duration INT,
    stay_location STRING,
    passenger_id INT,
    date_id INT,
    airport_code STRING
) 
STORED AS ORC;

-- Table: interaction_fact (Managed Table)
CREATE TABLE interaction_fact (
    employee_id INT,
    passenger_id INT,
    interaction_date INT,
    response_date INT,
    satisfaction_score FLOAT,
    response_time INT,
    interaction_time INT,
    interaction_channel STRING
) 
STORED AS ORC;

-- Table: complaint_fact (Managed Table)
CREATE TABLE complaint_fact (
    complaint_category_id INT,
    employee_id INT,
    passenger_id INT,
    airport_id STRING,
    createdon INT,
    firstresponseon INT,
    investigationstarton INT,
    investigationendon INT,
    resolvedon INT,
    complaint_channel STRING,
    satisfaction_score FLOAT,
    complaint_status STRING
) 
STORED AS ORC;

-- Table: complaint_category_dim (Managed Table)
CREATE TABLE complaint_category_dim (
    complaint_category_id INT,
    category_name STRING,
    default_resolution_time INT
) 
STORED AS ORC;

-- Table: airport_dim (Managed Table)
CREATE TABLE airport_dim (
    airport_code STRING,
    airport_name STRING,
    city STRING,
    country STRING
) 
STORED AS ORC;

-- Table: fact_flight_activity (Managed Table)
CREATE TABLE fact_flight_activity (
    flight_id INT,
    arrival_date STRING,
    arrival_time STRING,
    actual_arrival_date STRING,
    actual_arrival_time STRING,
    departure_date STRING,
    departure_time STRING,
    actual_departure_date STRING,
    actual_departure_time STRING,
    departure_airport_id STRING,
    arrival_airport_id STRING,
    airplane_id STRING
) 
STORED AS ORC;

-- Table: employee_dim (Managed Table)
CREATE TABLE employee_dim (
    employee_id INT,
    age INT,
    gender STRING,
    role STRING,
    status STRING
) 
STORED AS ORC;

-- Table: reservation_tracking_fact (Managed Table)
CREATE TABLE reservation_tracking_fact (
    reservation_id INT,
    ticket_id INT,
    passenger_id INT,
    fare_class STRING,
    reservation_date STRING,
    reservation_cancel_date STRING,
    reservation_upgrade INT,
    ticket_confirm_date STRING,
    ticket_upgrade_date STRING,
    flight_date STRING,
    flight_feedback STRING
) 
STORED AS ORC;

-- Table: date_dim (Managed Table)
CREATE TABLE date_dim (
    date_id INT,
    `date` STRING,
    full_date_description STRING,
    day_of_week STRING,
    day_number_in_calendar_month INT,
    calendar_week_number_in_year INT,
    calendar_month_name STRING,
    calendar_month_number_in_year INT,
    calendar_quarter INT,
    calendar_year_quarter STRING,
    calendar_year INT,
    day_number_in_fiscal_month INT,
    last_day_in_fiscal_month_indicator BOOLEAN,
    fiscal_month STRING,
    fiscal_month_number_in_year INT,
    fiscal_year_month STRING,
    fiscal_quarter INT,
    fiscal_year_quarter STRING,
    fiscal_year INT
) 
STORED AS ORC;

-- Table: passenger_dim (Managed Table)
CREATE TABLE passenger_dim (
    passenger_id INT,
    passenger_key INT,
    age_category STRING,
    age INT,
    gender STRING,
    occupation STRING,
    nationality STRING,
    membership_status STRING,
    loyalty_tier STRING,
    city STRING,
    country STRING,
    start_date STRING,
    end_date STRING,
    created_at STRING
) 
STORED AS ORC;

-- Table: dim_crew (Managed Table)
CREATE TABLE dim_crew (
    crew_id INT,
    crew_key STRING,
    age INT,
    gender STRING,
    role_description STRING,
    marital_status STRING,
    city STRING,
    country STRING,
    nationality STRING
) 
STORED AS ORC;

-- Table: reservation_fact (Managed Table)
CREATE TABLE reservation_fact (
    reservation_id INT,
    passenger_id INT,
    airport_code STRING,
    airplane_id STRING,
    date_id INT,
    promotion_id INT,
    revenue FLOAT,
    profit FLOAT,
    payment_method STRING,
    reservation_channel STRING,
    fare_basis STRING,
    airport_fees FLOAT,
    taxes FLOAT,
    fuel_cost FLOAT,
    crew_fees FLOAT,
    meal_fees FLOAT,
    total_cost FLOAT,
    distance_in_miles INT
) 
STORED AS ORC;

-- Table: dim_promotion (Managed Table)
CREATE TABLE dim_promotion (
    promotion_id INT,
    promotion_key STRING,
    description STRING,
    name STRING,
    category STRING,
    assigned_tier STRING
) 
STORED AS ORC;

-- Table: loyalty_program_fact (Managed Table)
CREATE TABLE loyalty_program_fact (
    loyalty_id INT,
    points_type STRING,
    points FLOAT,
    fare_base STRING,
    op_type STRING,
    promotion_id INT,
    passenger_id INT,
    date_id INT
) 
STORED AS ORC;

-- Table: dim_airplane (Managed Table)
CREATE TABLE dim_airplane (
    airplane_id STRING,
    model STRING,
    capacity INT,
    manufacturer STRING,
    business_seats INT,
    economy_seats INT,
    first_class_seats INT,
    max_range_km INT,
    max_speed_kmh INT,
    fuel_capacity INT,
    number_of_engines INT,
    engine_type STRING,
    fuel_consumption FLOAT,
    activity_status STRING
) 
STORED AS ORC;


-- Load data into overnight_stay_fact table
LOAD DATA INPATH '/data/airline/orc_dwh/overnight_stay_fact.orc' INTO TABLE overnight_stay_fact;

-- Load data into interaction_fact table
LOAD DATA INPATH '/data/airline/orc_dwh/interaction_fact.orc' INTO TABLE interaction_fact;

-- Load data into complaint_fact table
LOAD DATA INPATH '/data/airline/orc_dwh/complaint_fact.orc' INTO TABLE complaint_fact;

-- Load data into complaint_category_dim table
LOAD DATA INPATH '/data/airline/orc_dwh/complaint_category_dim.orc' INTO TABLE complaint_category_dim;

-- Load data into airport_dim table
LOAD DATA INPATH '/data/airline/orc_dwh/airport_dim.orc' INTO TABLE airport_dim;

-- Load data into fact_flight_activity table
LOAD DATA INPATH '/data/airline/orc_dwh/fact_flight_activity.orc' INTO TABLE fact_flight_activity;

-- Load data into employee_dim table
LOAD DATA INPATH '/data/airline/orc_dwh/employee_dim.orc' INTO TABLE employee_dim;

-- Load data into reservation_tracking_fact table
LOAD DATA INPATH '/data/airline/orc_dwh/reservation_tracking_fact.orc' INTO TABLE reservation_tracking_fact;

-- Load data into date_dim table
LOAD DATA INPATH '/data/airline/orc_dwh/date_dim.orc' INTO TABLE date_dim;

-- Load data into passenger_dim table
LOAD DATA INPATH '/data/airline/orc_dwh/passenger_dim.orc' INTO TABLE passenger_dim;

-- Load data into dim_crew table
LOAD DATA INPATH '/data/airline/orc_dwh/dim_crew.orc' INTO TABLE dim_crew;

-- Load data into reservation_fact table
LOAD DATA INPATH '/data/airline/orc_dwh/reservation_fact.orc' INTO TABLE reservation_fact;

-- Load data into dim_promotion table
LOAD DATA INPATH '/data/airline/orc_dwh/dim_promotion.orc' INTO TABLE dim_promotion;

-- Load data into loyalty_program_fact table
LOAD DATA INPATH '/data/airline/orc_dwh/loyalty_program_fact.orc' INTO TABLE loyalty_program_fact;

-- Load data into dim_airplane table
LOAD DATA INPATH '/data/airline/orc_dwh/dim_airplane.orc' INTO TABLE dim_airplane;
