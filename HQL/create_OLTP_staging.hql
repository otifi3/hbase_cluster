use airline_staging;
-- Airport Table
CREATE EXTERNAL TABLE airport (
    Airport_Code STRING,
    Airport_Name STRING,
    City STRING,
    Country STRING,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/airport/'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Airplane Table
CREATE EXTERNAL TABLE airplane (
    Airplane_id INT,
    model STRING,
    capacity INT,
    manufacturer STRING,
    business_seats INT,
    economy_seats INT,
    first_class_seats INT,
    max_range_km DOUBLE,
    max_speed_kmh DOUBLE,
    registration_date STRING,
    fuel_capacity DOUBLE,
    number_of_engines INT,
    engine_type STRING,
    fuel_consumption DOUBLE,
    status STRING,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/airplane'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Baggage Table
CREATE EXTERNAL TABLE baggage (
    bagging_id INT,
    weight_KG DOUBLE,
    baggage_type STRING,
    tracking_number STRING,
    status STRING,
    Ticket_id INT,
    Flight_id INT,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/baggage'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Complain Table
CREATE EXTERNAL TABLE complain (
    Complain_id INT,
    Problem_severity_level STRING,
    status STRING,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/complain'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Employee Table
CREATE EXTERNAL TABLE employee (
    Employee_ID INT,
    fname STRING,
    lname STRING,
    phone STRING,
    email STRING,
    DOB STRING,
    Gender STRING,
    role_description STRING,
    status_martial STRING,
    address STRING,
    salary DOUBLE,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/employee'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Crew Table
CREATE EXTERNAL TABLE crew (
    crew_id INT,
    employee_id INT,
    ticket_id INT,
    Assignment_date STRING,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/crew'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Flight Table
CREATE EXTERNAL TABLE flight (
    Flight_id INT,
    departure_time STRING,
    arrival_time STRING,
    duration DOUBLE,
    status STRING,
    flight_no STRING,
    distance_in_miles DOUBLE,
    arrival_airport_id STRING,
    departure_airport_id STRING,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/flight'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Interaction Table
CREATE EXTERNAL TABLE interaction (
    Interaction_ID INT,
    Interaction_type STRING,
    Interaction_description STRING,
    Interaction_date_time STRING,
    replay_date_time STRING,
    Interaction_chanel STRING,
    feedback STRING,
    flight_id INT,
    Passenger_ID INT,
    Employee_ID INT,
    complaint_id INT,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/interaction'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Miles Table
CREATE EXTERNAL TABLE miles (
    miles_id INT,
    miles_type STRING,
    miles DOUBLE,
    passenger_id INT,
    ticket_id INT,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/miles'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Stay Table
CREATE EXTERNAL TABLE stay (
    stay_id INT,
    duration DOUBLE,
    location STRING,
    Ticket_ID INT,
    Passenger_ID INT,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/stay'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Passenger Table
CREATE EXTERNAL TABLE passenger (
    Passenger_ID INT,
    fname STRING,
    lname STRING,
    phone STRING,
    email STRING,
    DOB STRING,
    Gender STRING,
    occupation STRING,
    nationality STRING,
    membership_status STRING,
    address STRING,
    passport_no STRING,
    loyalty_tier STRING,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/passenger'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Promotion Table
CREATE EXTERNAL TABLE promotion (
    promotion_id INT,
    discount_percent DOUBLE,
    name STRING,
    Assigned_tier STRING,
    start_date STRING,
    end_date STRING,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/promotion'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Reservation Table
CREATE EXTERNAL TABLE reservation (
    Reservation_ID INT,
    class_type STRING,
    Booking_date STRING,
    Booking_Chanel STRING,
    payment_method STRING,
    validity_date STRING,
    status STRING,
    Flight_ID INT,
    Passenger_ID INT,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/reservation'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Ticket Table
CREATE EXTERNAL TABLE ticket (
    Ticket_ID INT,
    Seat_no STRING,
    class_type STRING,
    Fare DOUBLE,
    baggage_allowance INT,
    issued_date STRING,
    gate STRING,
    terminal STRING,
    meal STRING,
    status STRING,
    Fuel_Surcharge DOUBLE,
    Taxes DOUBLE,
    Airport_Fees DOUBLE,
    Airline_Profit DOUBLE,
    base_price DOUBLE,
    overnight_stay_price DOUBLE,
    miles_id INT,
    promotion_ID INT,
    airplane_id INT,
    Flight_ID INT,
    departure_airport STRING,
    arrival_airport STRING,
    Passenger_ID INT,
    Reservation_ID INT,
    IS_INSERTED STRING,
    IS_MODIFIED STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/staging/ticket'
TBLPROPERTIES ("skip.header.line.count"="1");


