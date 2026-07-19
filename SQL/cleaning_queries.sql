-- SQL Cleaning & Auditing Queries
-- Use these queries to audit and validate data quality before and during cleaning.

-- 1. TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows FROM loan_raw;

-- 2. DUPLICATE CHECK
-- Check if there are any duplicate Loan_ID records
SELECT Loan_ID, COUNT(*) 
FROM loan_raw 
GROUP BY Loan_ID 
HAVING COUNT(*) > 1;

-- 3. COUNT MISSING VALUES IN CATEGORICAL COLUMNS
SELECT 
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Missing_Gender,
    SUM(CASE WHEN Married IS NULL THEN 1 ELSE 0 END) AS Missing_Married,
    SUM(CASE WHEN Dependents IS NULL THEN 1 ELSE 0 END) AS Missing_Dependents,
    SUM(CASE WHEN Education IS NULL THEN 1 ELSE 0 END) AS Missing_Education,
    SUM(CASE WHEN Self_Employed IS NULL THEN 1 ELSE 0 END) AS Missing_Self_Employed,
    SUM(CASE WHEN Credit_History IS NULL THEN 1 ELSE 0 END) AS Missing_Credit_History
FROM loan_raw;

-- 4. COUNT MISSING VALUES IN NUMERICAL COLUMNS
SELECT 
    SUM(CASE WHEN ApplicantIncome IS NULL THEN 1 ELSE 0 END) AS Missing_ApplicantIncome,
    SUM(CASE WHEN CoapplicantIncome IS NULL THEN 1 ELSE 0 END) AS Missing_CoapplicantIncome,
    SUM(CASE WHEN LoanAmount IS NULL THEN 1 ELSE 0 END) AS Missing_LoanAmount,
    SUM(CASE WHEN Loan_Amount_Term IS NULL THEN 1 ELSE 0 END) AS Missing_Loan_Amount_Term
FROM loan_raw;

-- 5. RANGE AUDIT FOR NUMERICAL FEATURES
SELECT 
    MIN(ApplicantIncome) AS Min_Applicant_Income, MAX(ApplicantIncome) AS Max_Applicant_Income,
    MIN(CoapplicantIncome) AS Min_Coapplicant_Income, MAX(CoapplicantIncome) AS Max_Coapplicant_Income,
    MIN(LoanAmount) AS Min_Loan_Amount, MAX(LoanAmount) AS Max_Loan_Amount,
    MIN(Loan_Amount_Term) AS Min_Term, MAX(Loan_Amount_Term) AS Max_Term
FROM loan_raw;

-- 6. VALUE FREQUENCIES AND DOMAIN AUDITING FOR CATEGORICAL COLUMNS
-- Check Gender values
SELECT Gender, COUNT(*) AS count FROM loan_raw GROUP BY Gender;

-- Check Married values
SELECT Married, COUNT(*) AS count FROM loan_raw GROUP BY Married;

-- Check Dependents values
SELECT Dependents, COUNT(*) AS count FROM loan_raw GROUP BY Dependents;

-- Check Education values
SELECT Education, COUNT(*) AS count FROM loan_raw GROUP BY Education;

-- Check Self_Employed values
SELECT Self_Employed, COUNT(*) AS count FROM loan_raw GROUP BY Self_Employed;

-- Check Property_Area values
SELECT Property_Area, COUNT(*) AS count FROM loan_raw GROUP BY Property_Area;

-- Check Credit_History values
SELECT Credit_History, COUNT(*) AS count FROM loan_raw GROUP BY Credit_History;
