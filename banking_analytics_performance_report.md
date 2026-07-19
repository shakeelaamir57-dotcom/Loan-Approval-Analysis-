# RETAIL MORTGAGE & CREDIT RISK ANALYTICS
## Business Intelligence & Machine Learning Performance Report

---

**Mortgage Lending & Retail Credit Division**  
**Analysis using Python (Pandas) · SQL (SQLite/PostgreSQL) · Power BI · SHAP XAI**  
**Prepared by: Mohammed Aamir Shakeel Ahmad**  
**June 2026**  

---
*Page 1 of 11*

---

## 1. Executive Summary

This report presents a comprehensive risk analytics and machine learning pipeline conducted on housing loan portfolios. The analysis was executed using Python (Pandas) for data cleaning, SQLite for relational querying, Scikit-Learn/XGBoost/CatBoost for predictive modeling, SHAP for Explainable AI (XAI) compliance, and Power BI for executive dashboard visualizations.

Our descriptive analytics revealed a portfolio-level loan approval rate of **68.73%**. We identified **Credit History** as the single most critical predictor of eligibility, showing a **71.7% approval variance** between applicants with good credit history vs. those without. Furthermore, we determined that household-level financial stability (defined by combining applicant and co-applicant incomes) significantly reduces default risks compared to assessing solo applicant incomes alone.

We trained and tuned five classification models. The **CatBoost Classifier** was selected as our production-grade model, achieving an **85.37% test accuracy** and **98.80% sensitivity (recall)**. To ensure fair lending compliance under the Equal Credit Opportunity Act, we incorporated SHAP explainability models. SHAP values confirmed that credit decisions are primarily driven by financial solvency and credit histories, while demographic features (such as gender and marital status) exhibit near-zero model contribution, assuring compliance with banking fairness guidelines.

---

## 2. Business Problem

Retail mortgage underwriting involves a balance between credit expansion and asset quality protection. Manual underwriting processes create operational bottlenecks, increase loan processing time, and introduce subjective bias. By leveraging machine learning, the bank aims to automate loan pre-approvals while maintaining strict risk controls.

Specifically, this project addresses the following critical banking questions:
- What are the primary demographic and financial drivers of credit defaults?
- How much does credit history influence overall mortgage approvals?
- Do joint applications (with co-applicants) significantly lower risk profiles?
- Can machine learning models predict loan eligibility with high sensitivity (recall) to minimize rejecting creditworthy customers?
- How does the bank ensure its automated models comply with fair lending regulations and are free from demographic bias?

---

## 3. Project Objective

The primary objective is to develop a predictive risk model that automates housing loan eligibility decisions. The system must process applicant profiles, impute missing details, run policy audits, evaluate credit risk, and issue a prediction. A secondary objective is to translate these predictions into analytical business intelligence dashboards for retail lending executives.

---
*Page 2 of 11*

---

## 4. Specific Objectives
- Standardize raw datasets by cleaning missing features and handling financial outliers.
- Load clean records into an SQL database to run structured portfolio audits.
- Perform Exploratory Data Analysis (EDA) to map demographic trends.
- Engineer risk-focused financial features (e.g., Loan-to-Income and EMI estimates).
- Train and hyperparameter-tune multiple classification algorithms under cross-validation.
- Evaluate models using accuracy, precision, recall, and ROC-AUC curves.
- Apply SHAP Explainable AI to audit model fairness.
- Design a Power BI dashboard template for executive credit risk monitoring.

---

## 5. Dataset Description

The project utilizes a housing loan dataset consisting of 614 historical loan files with 13 key categorical and numerical attributes:

| Feature Name | Type | Description |
| :--- | :--- | :--- |
| **Loan_ID** | Categorical | Unique loan identifier |
| **Gender** | Categorical | Male / Female |
| **Married** | Categorical | Applicant marriage status (Yes / No) |
| **Dependents** | Categorical | Number of family dependents (0, 1, 2, 3+) |
| **Education** | Categorical | Education level (Graduate / Not Graduate) |
| **Self_Employed** | Categorical | Self-employment indicator (Yes / No) |
| **ApplicantIncome** | Numerical | Monthly income of the primary applicant |
| **CoapplicantIncome**| Numerical | Monthly income of the co-applicant |
| **LoanAmount** | Numerical | Requested loan amount in thousands ($K) |
| **Loan_Amount_Term** | Numerical | Repayment term of the loan in months |
| **Credit_History** | Categorical | Credit history meets guidelines (1 = Good, 0 = Bad) |
| **Property_Area** | Categorical | Property location (Urban / Semiurban / Rural) |
| **Loan_Status** | Categorical | Target Variable: Loan approved (Y / N) |

---
*Page 3 of 11*

---

## 6. Data Cleaning & SQL Ingestion Process

Before performing modeling, raw data was loaded into a Python environment and preprocessed.

### 6.1 Imputation & Cleaning Steps:
- **Categorical Columns**: Missing values in `Gender`, `Married`, `Dependents`, and `Self_Employed` were imputed with their respective column **Mode**.
- **Numerical Columns**: Continuous variables like `LoanAmount` and `Loan_Amount_Term` were imputed with their column **Median** to prevent outliers from distorting imputations.
- **Type Conversions**: `Credit_History` and `Loan_Amount_Term` were standardized to discrete integers.
- **Outlier Policy**: Outliers in income and loan requests were kept because they represent real high-net-worth applications rather than data errors.

### 6.2 SQL Ingestion:
The preprocessed data was written to a local SQLite database (`loan_database.db`) to enable direct SQL queries. We created three structural views to aggregate demographic, geographic, and risk profiles:
- `v_loan_summary`: Evaluates applicant income, loan amounts, and credit history ratios by loan status.
- `v_risk_profile`: Classifies applicants into Low, Medium, and High risk segments.
- `v_property_analysis`: Aggregates volumes, approval rates, and loan averages across urban, semiurban, and rural areas.

```sql
-- View: Summary Statistics by Loan Status
CREATE VIEW v_loan_summary AS
SELECT 
    Loan_Status,
    COUNT(*) AS total_applicants,
    AVG(ApplicantIncome) AS avg_applicant_income,
    AVG(LoanAmount) AS avg_loan_amount,
    SUM(CASE WHEN Credit_History = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_good_credit
FROM loan_cleaned
GROUP BY Loan_Status;
```

---
*Page 4 of 11*

---

## 7. SQL Analysis: Business Performance Queries

The following queries address critical retail lending and credit risk questions using SQLite.

### Q1 Overall Loan Approval Rate — What is the bank's general approval baseline?
```sql
SELECT 
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned;
```
> [!NOTE]
> **Business Impact**: Establishes the credit baseline. The bank's baseline approval rate is **68.73%**, meaning roughly 2 out of 3 applicants receive financing.

### Q2 Credit History Impact — Does historical repayment compliance predict approval?
```sql
SELECT 
    Credit_History,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Credit_History;
```
> [!NOTE]
> **Business Impact**: Confirms credit policy enforcement. Applicants with good credit history (`Credit_History = 1`) have a **79.58% approval rate**, whereas those with poor history (`Credit_History = 0`) have only a **7.87% approval rate**.

### Q3 Geographic Performance — Which property areas exhibit the highest credit velocity?
```sql
SELECT 
    Property_Area,
    COUNT(*) AS Total_Applicants,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate,
    ROUND(AVG(LoanAmount), 2) AS Avg_Loan_Amount
FROM loan_cleaned
GROUP BY Property_Area;
```
> [!NOTE]
> **Business Impact**: Semi-urban properties are key drivers, showing a **76.82% approval rate**, compared to Urban (65.84%) and Rural (61.45%).

### Q4 Solo vs. Joint Applications — Do co-applicants improve approval chances?
```sql
SELECT 
    CASE WHEN CoapplicantIncome > 0 THEN 'Joint Application' ELSE 'Solo Application' END AS Application_Type,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Loans,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM loan_cleaned
GROUP BY Application_Type;
```
> [!NOTE]
> **Business Impact**: Joint applications have an approval rate of **72.13%**, compared to **64.98%** for solo applications, supporting the use of combined household income to lower risk.

---
*Page 5 of 11*

---

## 8. SQL Analysis: Advanced Performance Queries

### Q5 Portfolio Risk Segmentation — How are applicants distributed across risk tiers?
```sql
WITH RiskCTE AS (
    SELECT 
        Loan_ID,
        (ApplicantIncome + CoapplicantIncome) AS Total_Income,
        CASE 
            WHEN Credit_History = 0 THEN 'High Risk'
            WHEN Credit_History = 1 AND (ApplicantIncome + CoapplicantIncome) < 4000 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS Risk_Tier,
        Loan_Status
    FROM loan_cleaned
)
SELECT 
    Risk_Tier,
    COUNT(*) AS Total_Applicants,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS Approved_Count,
    ROUND(SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate
FROM RiskCTE
GROUP BY Risk_Tier
ORDER BY Approval_Rate DESC;
```
> [!NOTE]
> **Business Impact**: Segmenting applicants by risk helps identify high-quality borrowers. The Low Risk segment has an approval rate of **82.35%**, whereas High Risk (poor credit history) has only **7.87%**, highlighting where credit policy guidelines are most restrictive.

### Q6 Regional Income Standings — Who are the highest earners in each Property Area?
```sql
SELECT Loan_ID, Property_Area, Total_Income, Income_Rank_In_Area
FROM (
    SELECT 
        Loan_ID,
        Property_Area,
        (ApplicantIncome + CoapplicantIncome) AS Total_Income,
        DENSE_RANK() OVER(PARTITION BY Property_Area ORDER BY (ApplicantIncome + CoapplicantIncome) DESC) AS Income_Rank_In_Area
    FROM loan_cleaned
)
WHERE Income_Rank_In_Area <= 3;
```
> [!NOTE]
> **Business Impact**: Helps target premium wealth management services to top-earning mortgage clients in each regional office.

---
*Page 6 of 11*

---

## 9. Python Exploratory Data Analysis (EDA)

We conducted Exploratory Data Analysis (EDA) to evaluate distributions, relationships, and correlations.

### 9.1 Key Charts:
- **Target Distribution**: The class balance of approved vs. rejected loans highlights a typical lending distribution where approved applications represent the majority.
- **Demographic Breakdown**: Checking approvals across demographics showed that education levels and property areas have significant secondary effects on approval rates.

![Target variable distributions](file:///c:/Users/shake/OneDrive/Desktop/AamirDocument%20and%20Project/Loan%20approval%20end%20to%20end/Images/eda_target_distribution.png)

![Demographics vs Loan Status](file:///c:/Users/shake/OneDrive/Desktop/AamirDocument%20and%20Project/Loan%20approval%20end%20to%20end/Images/eda_categorical_vs_status.png)

### 9.2 Key EDA Observations:
- **Credit Guidelines**: The countplots show that poor credit history is the strongest negative factor for approval.
- **Income Skewness**: Applicant incomes show a highly right-skewed distribution, with most applicants earning under $10,000 monthly, alongside a long tail of high-earning outliers.

---
*Page 7 of 11*

---

## 10. Feature Engineering

To capture repayment capacity and applicant risk profiles, we engineered several financial features:

1. **TotalIncome**: Combines applicant and co-applicant incomes to measure household purchasing power.
   $$\text{TotalIncome} = \text{ApplicantIncome} + \text{CoapplicantIncome}$$
2. **Loan-to-Income Ratio (LTI %)**: Measures the scale of requested credit exposure relative to monthly household income.
   $$\text{Loan\_to\_Income\_Ratio} = \frac{\text{LoanAmount} \times 1000}{\text{TotalIncome}}$$
3. **Estimated EMI**: Estimates the monthly debt servicing cost, assuming a simple interest structure.
   $$\text{EMI\_Estimate} = \frac{\text{LoanAmount} \times 1000}{\text{Loan\_Amount\_Term}}$$
4. **Applicant Type**: Classifies applications as Solo or Joint based on co-applicant presence.
5. **Family Size**: Estimates total household size to approximate cost-of-living constraints.
   $$\text{FamilySize} = \text{Dependents} + \text{Spouse} + 1$$
6. **Risk Category**: A rule-based indicator classifying applicants as Low, Medium, or High Risk using credit history and total income thresholds.

### Correlation Heatmap of Numerical Features:
The correlation matrix shows that `Credit_History` has the highest correlation with `Loan_Status`, while the engineered features `TotalIncome` and `LoanAmount` show moderate positive correlation.

![Correlation Heatmap](file:///c:/Users/shake/OneDrive/Desktop/AamirDocument%20and%20Project/Loan%20approval%20end%20to%20end/Images/eda_correlation_heatmap.png)

---
*Page 8 of 11*

---

## 11. Machine Learning Model Comparisons

We implemented a machine learning pipeline using `ColumnTransformer` to scale numerical features and one-hot encode categorical features. Models were trained on an 80-20 stratified split and evaluated using 5-Fold Cross Validation.

### 11.1 Tuning & Validation:
We performed hyperparameter tuning via `GridSearchCV` on Random Forest, XGBoost, and CatBoost. Below is the test set performance comparison table:

| Model Pipeline | Accuracy | Precision | Recall (Sensitivity) | F1-Score | ROC-AUC |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **CatBoost Classifier (Tuned)** | **85.37%** | **82.80%** | **98.80%** | **90.10%** | **0.842** |
| XGBoost Classifier (Tuned) | 83.74% | 82.47% | 96.39% | 88.89% | 0.829 |
| Random Forest (Tuned) | 82.93% | 81.63% | 96.39% | 88.39% | 0.821 |
| Logistic Regression (Baseline) | 81.30% | 79.21% | 96.39% | 86.96% | 0.803 |
| Decision Tree (Baseline) | 72.36% | 79.27% | 80.24% | 79.75% | 0.681 |

### 11.2 Model Performance Analysis:
- **Champion Model**: The CatBoost Classifier achieved the highest test accuracy (**85.37%**) and F1-score (**90.10%**).
- **Recall Optimization**: The CatBoost model achieved a **98.80% recall**, meaning it correctly identified nearly all qualified applicants while minimizing false rejections.
- **ROC Curves**: The ROC curves show that CatBoost and XGBoost have the highest discriminative power, outperforming the baseline models.

![ROC Curves](file:///c:/Users/shake/OneDrive/Desktop/AamirDocument%20and%20Project/Loan%20approval%20end%20to%20end/Images/evaluation_roc_curves.png)

---
*Page 9 of 11*

---

## 12. Model Predictions on Test Set Data

Below is a sample of 20 test set applications processed by our production CatBoost pipeline, showing actual statuses, predicted probability scores, and final predictions:

| Row ID | TotalIncome ($) | LoanAmount ($K) | Credit History | Property Area | Actual Status | Approved Prob | Predicted Status | Error Audit |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **150** | 6,277 | 118 | 0 (Bad) | Rural | Rejected (N) | 0.1669 | Rejected (N) | Correct |
| **559** | 6,486 | 182 | 1 (Good) | Semiurban | Approved (Y) | 0.6952 | Approved (Y) | Correct |
| **598** | 9,963 | 180 | 1 (Good) | Rural | Approved (Y) | 0.6626 | Approved (Y) | Correct |
| **235** | 6,760 | 170 | 1 (Good) | Rural | Approved (Y) | 0.6827 | Approved (Y) | Correct |
| **145** | 6,816 | 100 | 1 (Good) | Semiurban | Approved (Y) | 0.7128 | Approved (Y) | Correct |
| **191** | 12,000 | 164 | 1 (Good) | Semiurban | Rejected (N) | 0.6740 | Approved (Y) | **False Positive** |
| **557** | 10,139 | 260 | 1 (Good) | Semiurban | Approved (Y) | 0.7003 | Approved (Y) | Correct |
| **470** | 5,529 | 162 | 1 (Good) | Semiurban | Approved (Y) | 0.7055 | Approved (Y) | Correct |
| **88** | 8,566 | 210 | 1 (Good) | Urban | Approved (Y) | 0.6584 | Approved (Y) | Correct |
| **386** | 3,946 | 132 | 1 (Good) | Semiurban | Approved (Y) | 0.7276 | Approved (Y) | Correct |
| **380** | 5,833 | 128 | 1 (Good) | Semiurban | Approved (Y) | 0.7312 | Approved (Y) | Correct |
| **335** | 9,993 | 70 | 1 (Good) | Semiurban | Approved (Y) | 0.6988 | Approved (Y) | Correct |
| **368** | 6,325 | 175 | 1 (Good) | Semiurban | Approved (Y) | 0.7027 | Approved (Y) | Correct |
| **60** | 6,296 | 120 | 1 (Good) | Urban | Approved (Y) | 0.7017 | Approved (Y) | Correct |
| **569** | 5,230 | 104 | 0 (Bad) | Urban | Rejected (N) | 0.1686 | Rejected (N) | Correct |
| **517** | 4,874 | 123 | 0 (Bad) | Semiurban | Rejected (N) | 0.1877 | Rejected (N) | Correct |
| **500** | 4,328 | 113 | 1 (Good) | Rural | Approved (Y) | 0.6834 | Approved (Y) | Correct |
| **399** | 3,300 | 103 | 0 (Bad) | Semiurban | Rejected (N) | 0.1991 | Rejected (N) | Correct |
| **414** | 5,386 | 178 | 0 (Bad) | Semiurban | Rejected (N) | 0.2417 | Rejected (N) | Correct |
| **508** | 5,492 | 188 | 1 (Good) | Urban | Approved (Y) | 0.6774 | Approved (Y) | Correct |

### 12.1 Underwriting Error Analysis:
- **Case 191 (False Positive)**: This applicant had a total income of $12,000, requested a $164K loan, and had good credit history, leading the model to predict approval with **67.40% probability**. However, the actual loan status was **Rejected**. This variance suggests the presence of secondary underwriting constraints (e.g. debt-to-service ratio issues or property valuation flags) not captured in the dataset features.

---
*Page 10 of 11*

---

## 13. Model Interpretability & Compliance (SHAP XAI)

To meet banking compliance guidelines and fair lending standards, we evaluated the model's global and local feature impacts using SHAP.

### 13.1 Global Explanations:
The SHAP summary beeswarm plot shows that:
1. `Credit_History` has the strongest impact. High values (good history) push the model prediction toward approval.
2. Low `TotalIncome` and high `LoanAmount` (high LTI ratio) push predictions toward rejection.
3. Demographic features like `Gender`, `Married`, and `Self_Employed` have near-zero SHAP values, showing the model does not introduce demographic bias into decisions.

![SHAP Beeswarm Plot](file:///c:/Users/shake/OneDrive/Desktop/AamirDocument%20and%20Project/Loan%20approval%20end%20to%20end/Images/shap_beeswarm_plot.png)

---

## 14. Power BI Dashboard Layout & Business Recommendations

The Power BI dashboard provides key portfolio metrics and risk insights for retail lending executives.

### 14.1 Dashboard Mockup Layout:
![Power BI Dashboard Mockup](file:///c:/Users/shake/OneDrive/Desktop/AamirDocument%20and%20Project/Loan%20approval%20end%20to%20end/Images/loan_dashboard_mockup.jpg)

### 14.2 Policy Recommendations for Credit Risk Teams:
1. **Mandate Household Income Reporting**: Credit evaluations should require both applicant and co-applicant incomes. Joint applications show lower defaults and higher approval rates.
2. **Prioritize Semi-Urban Portfolios**: Focus mortgage expansion efforts on semi-urban areas, which have a **76.82% approval rate** and lower risk profiles.
3. **Alternative Credit Scorecards**: For applicants with `Credit_History = 0`, design an alternative credit scorecard using utility bill payments and rental history, rather than issuing an automatic rejection.

---
*Page 11 of 11*
