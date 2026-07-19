-- SQL Views for Banking Analytics and Reporting
-- Compatible with MySQL, PostgreSQL, and SQLite

-- DROP VIEWS IF THEY EXIST
DROP VIEW IF EXISTS v_loan_summary;
DROP VIEW IF EXISTS v_risk_profile;
DROP VIEW IF EXISTS v_property_analysis;
DROP VIEW IF EXISTS v_demographic_analysis;

-- 1. VIEW: SUMMARY STATISTICS BY LOAN STATUS
CREATE VIEW v_loan_summary AS
SELECT 
    Loan_Status,
    COUNT(*) AS total_applicants,
    AVG(ApplicantIncome) AS avg_applicant_income,
    AVG(CoapplicantIncome) AS avg_coapplicant_income,
    AVG(ApplicantIncome + CoapplicantIncome) AS avg_total_income,
    AVG(LoanAmount) AS avg_loan_amount,
    AVG(Loan_Amount_Term) AS avg_term_months,
    SUM(CASE WHEN Credit_History = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_good_credit
FROM loan_cleaned
GROUP BY Loan_Status;

-- 2. VIEW: RISK PROFILE ANALYSIS
-- Categorize applicants into Low, Medium, and High risk using Credit_History and Total Income
CREATE VIEW v_risk_profile AS
SELECT 
    Loan_ID,
    Gender,
    Married,
    Credit_History,
    (ApplicantIncome + CoapplicantIncome) AS Total_Income,
    LoanAmount,
    Loan_Status,
    CASE 
        WHEN Credit_History = 0 THEN 'High Risk'
        WHEN Credit_History = 1 AND (ApplicantIncome + CoapplicantIncome) < 4000 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Segment
FROM loan_cleaned;

-- 3. VIEW: PROPERTY AREA ANALYSIS
-- Aggregates loan amount and approval performance per property area
CREATE VIEW v_property_analysis AS
SELECT 
    Property_Area,
    COUNT(*) AS total_applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    SUM(CASE WHEN Loan_Status = 'N' THEN 1 ELSE 0 END) AS rejected_loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS approval_rate,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount,
    ROUND(AVG(ApplicantIncome + CoapplicantIncome), 2) AS avg_total_income
FROM loan_cleaned
GROUP BY Property_Area;

-- 4. VIEW: DEMOGRAPHIC ANALYSIS
-- Breakdown of loan status and income across gender, education status, and marital status
CREATE VIEW v_demographic_analysis AS
SELECT 
    Gender,
    Married,
    Education,
    COUNT(*) AS total_applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS approval_rate,
    ROUND(AVG(ApplicantIncome), 2) AS avg_applicant_income,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount
FROM loan_cleaned
GROUP BY Gender, Married, Education;
