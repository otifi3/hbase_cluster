-- Create a database
CREATE DATABASE  test_db;

-- Use the created database
USE test_db;

-- Drop table if it already exists
DROP TABLE IF EXISTS employee;

-- Create a sample table
CREATE TABLE employee (
    id INT,
    name STRING,
    salary FLOAT,
    department STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Insert sample data using inline method (good for testing)
INSERT INTO TABLE employee VALUES
(1, 'Alice', 50000.0, 'Engineering'),
(2, 'Bob', 40000.0, 'HR'),
(3, 'Charlie', 60000.0, 'Engineering'),
(4, 'Diana', 45000.0, 'Marketing');

-- Run some queries to test
SELECT * FROM employee;

-- Count employees
SELECT COUNT(*) AS total_employees FROM employee;

-- Average salary by department
SELECT department, AVG(salary) AS avg_salary
FROM employee
GROUP BY department;

-- Cleanup
DROP TABLE IF EXISTS employee;
DROP DATABASE IF EXISTS test_db CASCADE;


-- enables vectorized execution for all queries during the current session
SET hive.vectorized.execution.enabled=true;
-- enables vectorized execution during the Reduce phase of a MapReduce job.
SET hive.vectorized.execution.reduce.enabled=true;
-- enables vectorized execution during the Map phase of a MapReduce job.
SET hive.vectorized.execution.map.enabled=true;
