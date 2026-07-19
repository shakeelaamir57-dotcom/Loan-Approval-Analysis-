# Power BI Dashboard Setup & Visual Specifications
**Project**: Loan Approval Prediction & Banking Analytics
**System/Role**: Corporate Business Intelligence Analyst

---

## 1. Data Connection & Modeling

### Data Ingest Options:
1. **Option A (Cleaned CSV)**:
   - Import `Dataset/cleaned/loan_cleaned.csv` or `Dataset/processed/loan_processed.csv`.
2. **Option B (SQLite Database Direct Connection)**:
   - In Power BI Desktop, select **Get Data** -> **ODBC**.
   - Create a User DSN using the SQLite3 ODBC Driver pointing to `SQL/loan_database.db`.
   - Run: `SELECT * FROM loan_cleaned;` or query the views (`v_property_analysis`, `v_demographic_analysis`).

---

## 2. Color Palette & Typography (Corporate Design System)

* **Primary Background**: Light Gray (`#F8FAFC`) / Card Background: White (`#FFFFFF`)
* **Primary Accent (Corporate Navy)**: `#1E3A8A` (Deep Slate Blue)
* **Secondary Accent (Steel Slate)**: `#475569`
* **Success/Approved State**: `#10B981` (Emerald Green)
* **Failure/Rejected State**: `#EF4444` (Rose Red)
* **Body Font**: **Segoe UI** or **Segoe UI Semibold** (Standard clean Windows corporate look)

---

## 3. DAX Calculated Measures

To ensure data integrity, create a new table `_Measures Table` and write the following DAX calculations:

```dax
// 1. Total Applicants
Total Applicants = COUNTROWS(loan_cleaned)

// 2. Approved Loans
Approved Loans = CALCULATE([Total Applicants], loan_cleaned[Loan_Status] = "Y")

// 3. Rejected Loans
Rejected Loans = CALCULATE([Total Applicants], loan_cleaned[Loan_Status] = "N")

// 4. Approval Rate
Approval Rate = DIVIDE([Approved_Loans], [Total Applicants], 0)

// 5. Average Income
Avg Income = AVERAGE(loan_cleaned[ApplicantIncome])

// 6. Average Loan Amount
Avg Loan Amount = AVERAGE(loan_cleaned[LoanAmount])
```

---

## 4. Dashboard Canvas Layout

The layout follows a standard **Executive Summary** Grid.

### Row 1: Header & Key Performance Indicators (KPI Cards)
- **Title Banner**: `Loan Approval & Retail Credit Risk Dashboard` (Dark Navy `#1E3A8A` background, white text).
- **Cards**:
  1. **Total Applicants**: Display `Total Applicants` measure.
  2. **Approved Loans**: Display `Approved Loans` measure, colored Green (`#10B981`).
  3. **Rejected Loans**: Display `Rejected Loans` measure, colored Red (`#EF4444`).
  4. **Approval Rate**: Display `Approval Rate` formatted as a percentage (`68.73%`).
  5. **Average Loan Amount**: Display `Avg Loan Amount` measure (format: `$#,##0.00 K`).

### Row 2: Demographic & Property Segmentation (Main Insights)
- **Visual 1: Approval Rate by Property Area (Donut/Pie Chart)**
  - **Legend**: `Property_Area` (Urban, Semiurban, Rural)
  - **Values**: `Total Applicants`
  - **Details**: Show approval rate tooltips.
- **Visual 2: Approval Rate by Credit History (100% Stacked Bar Chart)**
  - **Axis**: `Credit_History` (0 = No History, 1 = Good History)
  - **Legend**: `Loan_Status` (Y, N)
  - **Values**: `Total Applicants`
- **Visual 3: Approval Rate by Education (Clustered Column Chart)**
  - **X-Axis**: `Education` (Graduate, Not Graduate)
  - **Y-Axis**: `Approval Rate`

### Row 3: Income & Financial Exposure Analysis (Distributions)
- **Visual 4: Loan Amount Distribution (Histogram/Bin Chart)**
  - **X-Axis**: `LoanAmount` (grouped in bins of $20K)
  - **Y-Axis**: Count of applicants
- **Visual 5: Applicant Income vs Loan Amount (Scatter Plot)**
  - **X-Axis**: `ApplicantIncome`
  - **Y-Axis**: `LoanAmount`
  - **Legend**: `Loan_Status` (Color code: Green for Y, Red for N)
  - **Details**: `Loan_ID`

---

## 5. Report Slicers (Global Canvas Filters)

Place these slicers in a collapsible side panel or as a top bar:
1. **Gender** (Dropdown list)
2. **Married** (Single select buttons: Yes / No)
3. **Education** (Checkbox: Graduate / Not Graduate)
4. **Self_Employed** (Dropdown: Yes / No)
5. **Property_Area** (Checkbox: Rural / Semiurban / Urban)
6. **Credit_History** (Radio Buttons: 0 / 1)
