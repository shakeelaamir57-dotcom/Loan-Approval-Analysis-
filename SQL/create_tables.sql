-- SQL DDL Script: Table Creation for Loan Prediction Database
-- Compatible with MySQL, PostgreSQL, and SQLite

-- DROP TABLES IF THEY EXIST TO ENSURE IDEMPOTENCY
DROP TABLE IF EXISTS loan_cleaned;
DROP TABLE IF EXISTS loan_raw;

-- 1. RAW INGESTION TABLE (Accepts NULLs and raw types)
CREATE TABLE loan_raw (
    Loan_ID VARCHAR(20) PRIMARY KEY,
    Gender VARCHAR(10),
    Married VARCHAR(10),
    Dependents VARCHAR(5),
    Education VARCHAR(20),
    Self_Employed VARCHAR(10),
    ApplicantIncome INT,
    CoapplicantIncome DOUBLE PRECISION,
    LoanAmount DOUBLE PRECISION,
    Loan_Amount_Term DOUBLE PRECISION,
    Credit_History DOUBLE PRECISION,
    Property_Area VARCHAR(20),
    Loan_Status VARCHAR(5)
);

-- 2. CLEANED DATA TABLE FOR ANALYTICS (Standardized columns, no missing values)
CREATE TABLE loan_cleaned (
    Loan_ID VARCHAR(20) PRIMARY KEY,
    Gender VARCHAR(10) NOT NULL,
    Married VARCHAR(10) NOT NULL,
    Dependents VARCHAR(5) NOT NULL,
    Education VARCHAR(20) NOT NULL,
    Self_Employed VARCHAR(10) NOT NULL,
    ApplicantIncome INT NOT NULL,
    CoapplicantIncome DOUBLE PRECISION NOT NULL,
    LoanAmount DOUBLE PRECISION NOT NULL,
    Loan_Amount_Term INT NOT NULL,
    Credit_History INT NOT NULL, -- 0 or 1
    Property_Area VARCHAR(20) NOT NULL,
    Loan_Status VARCHAR(5) NOT NULL
);
