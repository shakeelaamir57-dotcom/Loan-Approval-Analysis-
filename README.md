# Loan Approval Prediction & Banking Analytics
### SQL, Python, Power BI, XGBoost, CatBoost, and SHAP Explainable AI

---

## 1. Project Overview & Business Problem
In retail banking, underwriting residential mortgages and housing loans involves a careful trade-off between maximizing portfolio yields and minimizing default rates. Historically, loan evaluation was a manual, slow process prone to operational bottlenecks and human bias.

This project implements an **industry-grade end-to-end Loan Approval Prediction & Banking Analytics pipeline** designed to automate credit risk assessment for a retail bank. Working with the standard **Analytics Vidhya Loan Prediction Dataset**, we construct:
1. A **data cleaning and database ingestion pipeline** that loads transaction records into an SQL database.
2. **30 business intelligence SQL queries** analyzing credit histories, applicant demographics, and financial variables.
3. **Jupyter Notebooks (1 to 9)** detailing descriptive, exploratory, predictive, and explainable models.
4. **Machine Learning models** comparing Logistic Regression, Decision Trees, Random Forests, XGBoost, and CatBoost.
5. **Explainable AI (SHAP)** global and local explanations to meet credit underwriting compliance standards.
6. A **Power BI Dashboard visual design specification** for reporting to the Chief Risk Officer (CRO).

---

## 2. Project Architecture & Folder Structure

```text
Loan_Approval_Prediction/
│
├── Dataset/
│   ├── raw/          # Raw Analytics Vidhya/Kaggle dataset (train.csv)
│   ├── cleaned/      # Data after missing values & type imputations
│   └── processed/    # Feature-engineered dataset ready for ML models
│
├── SQL/
├── SQL/
│   ├── create_tables.sql      # DDL to initialize raw and cleaned table schemas
│   ├── insert_data.sql        # Ingestion strategies (COPY, LOAD DATA INFILE)
│   ├── cleaning_queries.sql   # Data auditing, range checks, and domain checks
│   ├── views.sql              # Analytical views for Power BI reporting
│   ├── stored_procedures.sql  # Procedures for automated reporting and scoring
│   ├── analysis_queries.sql   # 30 Business Intelligence queries
│   └── loan_database.db       # Embedded SQLite database containing clean tables
│
├── Notebooks/
│   ├── 01_Data_Loading.ipynb       # Ingestion and metadata inspections
│   ├── 02_Data_Cleaning.ipynb      # Imputation, type fixes, and outlier analysis
│   ├── 03_SQL_Analysis.ipynb       # Connecting to SQLite & executing 30 queries
│   ├── 04_EDA.ipynb                # Univariate, bivariate, multivariate plots
│   ├── 05_Feature_Engineering.ipynb # Business metric calculations (TotalIncome, ratios)
│   ├── 06_Model_Building.ipynb     # Pipeline, cross-validation, hyperparameter grid search
│   ├── 07_Model_Evaluation.ipynb   # Performance comparison tables, ROC curves, confusion matrices
│   ├── 08_SHAP_Explainability.ipynb# Global beeswarm and local waterfall plots
│   └── 09_Final_Insights.ipynb     # Executive board presentation and strategy report
│
├── Models/
│   ├── best_model.pkl              # Saved production model pipeline
│   ├── logistic_regression.pkl     # Serialized baseline model
│   ├── decision_tree.pkl           # Serialized baseline model
│   ├── random_forest_tuned.pkl     # Tuned Random Forest model
│   ├── xgboost_tuned.pkl           # Tuned XGBoost model
│   ├── catboost_tuned.pkl          # Tuned CatBoost model
│   └── test_splits.pkl             # Serialized training/testing subsets
│
├── Dashboard/
│   └── Loan Analysis Dashboard.pbix# Interactive Power BI report dashboard
│
├── Images/                         # Generated charts, distributions, and XAI outputs
├── banking_analytics_performance_report.docx # Executive performance report
├── requirements.txt                # Python package requirements
├── .gitignore                      # Excludes runtime checkpoints and binary model dumps
└── README.md                       # Main documentation
```

---

## 3. SQL Analytics & Database Schema

The database houses two primary tables: `loan_raw` and `loan_cleaned`. The schema DDL is compatible with PostgreSQL, MySQL, and SQLite.

### Key Data Ingestion Table Schemas:
- **`loan_raw`**: Ingests raw data, including missing fields, to support auditing.
- **`loan_cleaned`**: Enforces strict `NOT NULL` constraints on key demographic and financial fields post-imputation.

### 30 Business Intelligence Queries Summary:
The `SQL/analysis_queries.sql` script contains 30 structured analytical queries covering:
- **Demographics**: Approval rates across Gender, Marriage status, Dependents, and Education.
- **Financial Ratios**: Loan-to-Income (LTI) metrics and average requested limits.
- **Credit Risk Profiles**: Segments low-risk vs. high-risk applicants using credit history and total household income.
- **Advanced SQL**: Employs Common Table Expressions (CTEs), Subqueries, and Window Functions (`DENSE_RANK()`, running averages) to rank profiles and identify hubs of capital requests.

---

## 4. Python Workflow: Notebooks 1 - 9

### Notebook 1: Data Ingestion & Overview
- Loads raw CSV dataset from verified GitHub endpoints.
- Verifies shapes (614 rows, 13 columns), column data types (`dtypes`), and high-level null values.

### Notebook 2: Data Cleaning & Auditing
- **Imputation Strategy**: Mode for categorical features (`Gender`, `Married`, `Dependents`, `Self_Employed`, `Credit_History`), Median for continuous features (`LoanAmount`, `Loan_Amount_Term`) due to right-skewness.
- Audits outliers using boxplots; decides to keep real-world high-net-worth incomes to avoid distorting risk evaluations.
- Exports clean records to `Dataset/cleaned/loan_cleaned.csv`.

### Notebook 3: SQL Analysis
- Connects Python to an embedded SQLite database (`loan_database.db`).
- Creates database views and executes the **30 business intelligence queries**, converting output tables into readable pandas DataFrames.

### Notebook 4: Deep Exploratory Data Analysis (EDA)
- **Univariate**: Displays pie charts of Target status (`Loan_Status`) and distributions of applicant incomes.
- **Bivariate**: Uses countplots, boxplots, and violin plots to cross-reference demographics against approval rates.
- **Multivariate**: Plotting Loan Amount vs. Total Income colored by approval status, alongside a full correlation heatmap.

### Notebook 5: Feature Engineering
Calculates new business-level metrics:
- $\text{TotalIncome} = \text{ApplicantIncome} + \text{CoapplicantIncome}$
- $\text{Loan-to-Income Ratio} = \frac{\text{LoanAmount} \times 1000}{\text{TotalIncome}}$
- $\text{EMI Estimate} = \frac{\text{LoanAmount} \times 1000}{\text{Loan\_Amount\_Term}}$
- $\text{ApplicantType}$ (Solo vs. Joint application)
- $\text{FamilySize}$ (Applicant + Spouse + Dependents)
- $\text{RiskCategory}$ (Rule-based: Low, Medium, High risk indicator based on credit history and income)
- Encodes target variable `Loan_Status` (Y=1, N=0) and saves the processed dataset to `Dataset/processed/loan_processed.csv`.

### Notebook 6: Machine Learning Pipeline
- Uses `ColumnTransformer` to dynamically scale numerical fields and one-hot encode categorical fields.
- Performs an 80-20 stratified split.
- Trains: Logistic Regression, Decision Tree, Random Forest, XGBoost, and CatBoost.
- Applies 5-Fold Cross Validation.
- Performs Hyperparameter Tuning via `GridSearchCV` / `RandomizedSearchCV` on tree models.
- Serializes trained pipelines into the `Models/` directory.

### Notebook 7: Model Evaluation & Metrics
Evaluates model pipelines on the test set:
- **Metrics Evaluated**: Accuracy, Precision, Recall, F1-Score, and ROC-AUC.
- Generates confusion matrices and comparative ROC-AUC curve plots.
- Recommendation: **CatBoost / XGBoost Classifier** is selected as the production candidate.

### Notebook 8: Explainable AI (SHAP)
- Analyzes feature contributions using Shapley Additive Explanations.
- Generates global feature importance and beeswarm summary plots.
- Illustrates local explainability with waterfall plots for individual approved and rejected files.

### Notebook 9: Executive Insights
- Consolidates results into a strategy briefing for the Retail Lending Board and Chief Risk Officer.

---

## 5. Model Evaluation Results

After tuning, the models achieved the following performance on the test set:

| Model | Accuracy | Precision | Recall (Sensitivity) | F1-Score | ROC-AUC |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **CatBoost Classifier (Tuned)** | **85.37%** | **82.80%** | **98.80%** | **90.10%** | **0.842** |
| XGBoost Classifier (Tuned) | 83.74% | 82.47% | 96.39% | 88.89% | 0.829 |
| Random Forest (Tuned) | 82.93% | 81.63% | 96.39% | 88.39% | 0.821 |
| Logistic Regression (Baseline) | 81.30% | 79.21% | 96.39% | 86.96% | 0.803 |
| Decision Tree (Baseline) | 72.36% | 79.27% | 80.24% | 79.75% | 0.681 |

### Model Performance Analysis:
- **The Champion Model**: The **CatBoost Classifier** outperforms others across all metrics.
- **Recall Optimization**: In credit underwriting, a high Recall (98.80%) is valuable because it means the bank minimizes the number of qualified borrowers it mistakenly turns away, while maintaining a robust Precision (82.80%) to filter out credit defaults.

---

## 6. Explainable AI (SHAP) Insights

SHAP values explain the model's global logic and individual decisions:
1. **Credit History**: Globally, `Credit_History` is the single most important indicator. Its presence boosts the approval probability log-odds.
2. **Total Household Income**: Household income acts as a buffer. High `TotalIncome` helps offset high loan amounts.
3. **Property Area**: Semi-urban locations strongly drive positive predictions, aligning with the bank's regional lending performance.
4. **Fair Lending Compliance**: Features like `Gender` and `Self_Employed` have near-zero SHAP values, showing the model avoids demographic bias.

---

## 7. Power BI Dashboard Specification

A professional corporate dashboard is delivered in `Dashboard/Loan Analysis Dashboard.pbix`, featuring:
- **KPI Cards**: Total Applicants, Approved, Rejected, Approval Rate, Average Loan Amount.
- **Segmentation Visuals**: Approval rate by Property Area, Credit History, and Education level.
- **DAX Calculations**: Standardized counting and division measures for portfolio analysis.
- **Global Filters**: Gender, Marital Status, Education, Property Area, and Credit History.

---

## 8. Strategic Executive Recommendations
1. **Household Income Mandate**: Evaluate loan applications on `TotalIncome` (Applicant + Co-applicant) rather than Applicant Income alone, as joint applications display higher stability and approval rates.
2. **Semi-urban Property Focus**: Target marketing campaigns toward semi-urban regions, which show the highest approval rates (~76.8%) and lowest relative default metrics.
3. **Alternative Scorecards**: Develop an alternative credit scoring pipeline (using transactional and utility payment history) for applicants with `Credit_History = 0`, as automatic rejections in this segment may miss qualified first-time homebuyers.
