-- SQL Business Intelligence Queries: Loan Approval Analytics
-- Compatible with MySQL, PostgreSQL, and SQLite
-- These queries analyze credit risk, approval rates, demographics, and financial distributions.

-- ============================================================================
-- 1. BASIC AGGREGATIONS & GENERAL METRICS
-- ============================================================================

-- Query 1: Overall Loan Approval Rate
-- Business Purpose: Benchmark the general acceptance rate of the bank.
SELECT 
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned;

-- Query 2: Gender-wise Approval Rate
-- Business Purpose: Identify if there is a gender distribution skew in approved loans.
SELECT 
    Gender,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Gender;

-- Query 3: Married vs Unmarried Approval Rate
-- Business Purpose: Analyze the impact of marital status on loan approvals.
SELECT 
    Married,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Married;

-- Query 4: Education-wise Approval Rate
-- Business Purpose: Evaluate if higher education levels correlate with a higher approval rate.
SELECT 
    Education,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Education;

-- Query 5: Self-Employed vs Salaried Approval Rate
-- Business Purpose: Determine if salaried applicants have better chances than business owners.
SELECT 
    Self_Employed,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Self_Employed;

-- Query 6: Property Area-wise Approval Rate
-- Business Purpose: Identify geographic regions with higher credit expansions.
SELECT 
    Property_Area,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Property_Area;

-- Query 7: Credit History-wise Approval Rate
-- Business Purpose: Assess the impact of historical credit guidelines on approval.
SELECT 
    Credit_History,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Credit_History;

-- Query 8: Average Income and Loan Amount by Loan Status
-- Business Purpose: Examine difference in financial capacity between approved and rejected files.
SELECT 
    Loan_Status,
    ROUND(AVG(ApplicantIncome), 2) AS Avg_Applicant_Income,
    ROUND(AVG(CoapplicantIncome), 2) AS Avg_Coapplicant_Income,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan_Amount
FROM loan_cleaned
GROUP BY Loan_Status;

-- Query 9: Dependents-wise Loan Approval Rate
-- Business Purpose: Analyze correlation between family dependencies and approval rates.
SELECT 
    Dependents,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Dependents
ORDER BY Dependents;

-- Query 10: Top 10 Highest Income Applicants
-- Business Purpose: Identify the bank's most affluent loan applicants.
SELECT 
    Loan_ID, Gender, Married, Education, ApplicantIncome, LoanAmount, Loan_Status
FROM loan_cleaned
ORDER BY ApplicantIncome DESC
LIMIT 10;


-- ============================================================================
-- 2. ADVANCED AGGREGATIONS & CONDITIONAL SEGMENTATIONS
-- ============================================================================

-- Query 11: Approval Rate by Income Categories
-- Business Purpose: Segment applicants into income tiers and evaluate approvals.
SELECT 
    CASE 
        WHEN ApplicantIncome < 3000 THEN 'Low Income (<3k)'
        WHEN ApplicantIncome BETWEEN 3000 AND 6000 THEN 'Medium Income (3k-6k)'
        WHEN ApplicantIncome BETWEEN 6000 AND 10000 THEN 'High Income (6k-10k)'
        ELSE 'Ultra High Income (>10k)'
    END AS Income_Category,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY 
    CASE 
        WHEN ApplicantIncome < 3000 THEN 'Low Income (<3k)'
        WHEN ApplicantIncome BETWEEN 3000 AND 6000 THEN 'Medium Income (3k-6k)'
        WHEN ApplicantIncome BETWEEN 6000 AND 10000 THEN 'High Income (6k-10k)'
        ELSE 'Ultra High Income (>10k)'
    END
ORDER BY Avg(ApplicantIncome);

-- Query 12: Approval Rate by Loan Amount Tiers
-- Business Purpose: Measure risk acceptance for smaller vs larger loan values.
SELECT 
    CASE 
        WHEN LoanAmount < 100 THEN 'Small Loans (<100k)'
        WHEN LoanAmount BETWEEN 100 AND 200 THEN 'Medium Loans (100k-200k)'
        ELSE 'Large Loans (>200k)'
    END AS Loan_Amount_Tier,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY 
    CASE 
        WHEN LoanAmount < 100 THEN 'Small Loans (<100k)'
        WHEN LoanAmount BETWEEN 100 AND 200 THEN 'Medium Loans (100k-200k)'
        ELSE 'Large Loans (>200k)'
    END
ORDER BY Avg(LoanAmount);

-- Query 13: Average Loan Amount and Term by Education and Employment Status
-- Business Purpose: Profile financial requests across occupational and educational classes.
SELECT 
    Education,
    Self_Employed,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan_Amount,
    ROUND(AVG(Loan_Amount_Term), 2) AS Avg_Term_Months,
    COUNT(*) AS Applicant_Count
FROM loan_cleaned
GROUP BY Education, Self_Employed;

-- Query 14: Average Loan-to-Income Ratio by Loan Status
-- Business Purpose: Measure if the ratio of loan requested to income triggers rejections.
SELECT 
    Loan_Status,
    ROUND(AVG(LoanAmount * 1000 / (ApplicantIncome + CoapplicantIncome)), 4) AS Avg_Loan_to_Income_Ratio
FROM loan_cleaned
GROUP BY Loan_Status;

-- Query 15: Co-applicant Income Impact Analysis
-- Business Purpose: Check if presence of a co-applicant improves approval chances.
SELECT 
    CASE WHEN CoapplicantIncome > 0 THEN 'Joint Application' ELSE 'Solo Application' END AS Application_Type,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY CASE WHEN CoapplicantIncome > 0 THEN 'Joint Application' ELSE 'Solo Application' END;

-- Query 16: High-Risk Category Analysis (No Credit History & Low Income)
-- Business Purpose: Verify approval performance on highest risk profile clients.
SELECT 
    CASE 
        WHEN Credit_History = 0 AND (ApplicantIncome + CoapplicantIncome) < 4000 THEN 'Critical High Risk'
        WHEN Credit_History = 0 THEN 'High Risk (No Credit History)'
        WHEN (ApplicantIncome + CoapplicantIncome) < 4000 THEN 'Moderate Risk (Low Income)'
        ELSE 'Low Risk'
    END AS Risk_Category,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY 
    CASE 
        WHEN Credit_History = 0 AND (ApplicantIncome + CoapplicantIncome) < 4000 THEN 'Critical High Risk'
        WHEN Credit_History = 0 THEN 'High Risk (No Credit History)'
        WHEN (ApplicantIncome + CoapplicantIncome) < 4000 THEN 'Moderate Risk (Low Income)'
        ELSE 'Low Risk'
    END
ORDER BY Approval_Rate;

-- Query 17: Property Area and Marital Status Combined Matrix
-- Business Purpose: Drill down demographics to cross-reference location and family.
SELECT 
    Property_Area,
    Married,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Property_Area, Married;

-- Query 18: Analysis of Education and Property Area Combined Approval Rate
-- Business Purpose: Refine regional target profiles by qualification levels.
SELECT 
    Education,
    Property_Area,
    COUNT(*) AS Total_Applicants,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Education, Property_Area
ORDER BY Education, Approval_Rate DESC;

-- Query 19: Loan Term (Term lengths in months) vs Loan Approval Rates
-- Business Purpose: Identify if shorter/longer amortization schedules affect default risks.
SELECT 
    Loan_Amount_Term AS Term_Months,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Loan_Amount_Term
ORDER BY Term_Months;

-- Query 20: Having Clause - Property Areas where the average loan amount requested is greater than 140k
-- Business Purpose: Filter geographical hubs seeking larger commercial capital.
SELECT 
    Property_Area,
    COUNT(*) AS Total_Applicants,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan_Amount
FROM loan_cleaned
GROUP BY Property_Area
HAVING AVG(LoanAmount) > 140.0;


-- ============================================================================
-- 3. SUBQUERIES, CTES, AND WINDOW FUNCTIONS
-- ============================================================================

-- Query 21: Subquery - Find applicants whose requested loan amount is greater than the average loan amount
-- Business Purpose: Isolate higher exposure applications.
SELECT 
    Loan_ID, ApplicantIncome, LoanAmount, Property_Area, Loan_Status
FROM loan_cleaned
WHERE LoanAmount > (SELECT AVG(LoanAmount) FROM loan_cleaned)
ORDER BY LoanAmount DESC
LIMIT 10;

-- Query 22: Subquery - Find demographics of the applicant who requested the absolute maximum loan amount
-- Business Purpose: Assess properties of extreme outlier exposures.
SELECT 
    Loan_ID, Gender, Married, Education, ApplicantIncome, LoanAmount, Property_Area, Loan_Status
FROM loan_cleaned
WHERE LoanAmount = (SELECT MAX(LoanAmount) FROM loan_cleaned);

-- Query 23: CTE - Classify total income into tiers and calculate approvals
-- Business Purpose: Standardize business intelligence reporting using clean CTE abstractions.
WITH IncomeTiers AS (
    SELECT 
        Loan_ID,
        (ApplicantIncome + CoapplicantIncome) AS Total_Income,
        Loan_Status
    FROM loan_cleaned
)
SELECT 
    CASE 
        WHEN Total_Income < 4000 THEN 'Tier 3 (<4k)'
        WHEN Total_Income BETWEEN 4000 AND 8000 THEN 'Tier 2 (4k-8k)'
        ELSE 'Tier 1 (>8k)'
    END AS Income_Tier,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Count,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM IncomeTiers
GROUP BY 
    CASE 
        WHEN Total_Income < 4000 THEN 'Tier 3 (<4k)'
        WHEN Total_Income BETWEEN 4000 AND 8000 THEN 'Tier 2 (4k-8k)'
        ELSE 'Tier 1 (>8k)'
    END
ORDER BY Income_Tier;

-- Query 24: CTE - Identify Applicants with Good Credit History and Above-Average Total Income
-- Business Purpose: Isolate "Prime" class clients for fast-track processing or pre-approval.
WITH PrimeApplicants AS (
    SELECT 
        Loan_ID,
        Gender,
        Education,
        (ApplicantIncome + CoapplicantIncome) AS Total_Income,
        Credit_History,
        Loan_Status
    FROM loan_cleaned
    WHERE Credit_History = 1 
      AND (ApplicantIncome + CoapplicantIncome) > (SELECT AVG(ApplicantIncome + CoapplicantIncome) FROM loan_cleaned)
)
SELECT 
    Loan_Status,
    COUNT(*) AS Count,
    ROUND(AVG(Total_Income), 2) AS Avg_Total_Income
FROM PrimeApplicants
GROUP BY Loan_Status;

-- Query 25: Window Function - Rank applicants by Total Income within their Property Area
-- Business Purpose: Identify the top earning applicants in each region.
SELECT 
    Loan_ID,
    Property_Area,
    (ApplicantIncome + CoapplicantIncome) AS Total_Income,
    DENSE_RANK() OVER(PARTITION BY Property_Area ORDER BY (ApplicantIncome + CoapplicantIncome) DESC) AS Income_Rank_In_Area
FROM loan_cleaned
LIMIT 15;

-- Query 26: Window Function - Running average of Loan Amount by Property Area
-- Business Purpose: Analyze trend behavior across regional accounts.
SELECT 
    Loan_ID,
    Property_Area,
    LoanAmount,
    ROUND(AVG(LoanAmount) OVER(PARTITION BY Property_Area ORDER BY Loan_ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS Running_Avg_LoanAmount
FROM loan_cleaned
LIMIT 15;

-- Query 27: Detailed Profile - Graduate Married Males vs Graduate Married Females
-- Business Purpose: Contrast specific demographics within the prime borrower profiles.
SELECT 
    Gender,
    COUNT(*) AS Applicants,
    ROUND(AVG(ApplicantIncome), 2) AS Avg_Income,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan_Requested,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
WHERE Education = 'Graduate' AND Married = 'Yes' AND Gender IN ('Male', 'Female')
GROUP BY Gender;

-- Query 28: Low-Risk Applicants (Good Credit History and High Income) Approval Rate
-- Business Purpose: Confirm check on approvals of low risk groups.
SELECT 
    COUNT(*) AS Low_Risk_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
WHERE Credit_History = 1 AND (ApplicantIncome + CoapplicantIncome) > 6000;

-- Query 29: Loan Amount vs Income Tiers correlation metrics (Average ratios by Loan_Status)
-- Business Purpose: Show aggregate metrics of loan requested vs income capacity.
SELECT 
    Loan_Status,
    COUNT(*) AS Total_Apps,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan,
    ROUND(AVG(ApplicantIncome + CoapplicantIncome), 2) AS Avg_Income,
    ROUND(AVG(LoanAmount / (ApplicantIncome + CoapplicantIncome)), 5) AS Avg_Ratio
FROM loan_cleaned
GROUP BY Loan_Status;

-- Query 30: CTE & Join - High-Value Approved Loans profile
-- Business Purpose: Retrieve clean demographic metrics for approved loans above the 75th percentile.
WITH Percentiles AS (
    SELECT LoanAmount FROM loan_cleaned
),
ApprovedHighValue AS (
    SELECT 
        Loan_ID, Gender, Married, Education, ApplicantIncome, LoanAmount, Property_Area
    FROM loan_cleaned
    WHERE Loan_Status = 'Y' 
      AND LoanAmount > 170.0 -- 75th percentile approximation
)
SELECT 
    Property_Area,
    COUNT(*) AS High_Value_Count,
    ROUND(AVG(ApplicantIncome), 2) AS Avg_Income,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan
FROM ApprovedHighValue
GROUP BY Property_Area;
