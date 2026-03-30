# credit-risk-analysis
This project analyzes 255,000+ loan records to identify borrower risk patterns and improve lending decision-making using Python (data cleaning &amp; feature engineering) and SQL (analytical queries).
## Problem
Lending institutions struggle to identify which borrower segments carry the highest default risk. Raw loan data is often messy, inconsistently typed, and lacks the engineered features needed for meaningful risk segmentation.

## Actions Taken

### Data Cleaning & Feature Engineering (Python)
- Imported and explored a 255K-record loan dataset from Kaggle
- Identified and handled null values and duplicate records
- Assigned correct data types: categorical encoding and numeric casting
- Detected outliers using Seaborn (boxplots) and Matplotlib (distribution plots)
- Renamed columns for readability and consistency
- Applied label encoding and dummy variables for ML-readiness
- Engineered 4 new features:
  - income_to_loan_ratio — affordability indicator
  - credit_utilization_proxy — derived from available fields
  - employment_stability — categorical risk flag
  - monthly_interest_burden — cash-flow stress metric

### Segmentation Analysis (SQL — 5 queries)
- Default rate by **employment type** → Unemployed borrowers default at 13.55% vs 9.46% for full-time
- Default rate by **age group & loan term** → Under-30 cohort shows a 20.12% default rate
- Risk by **loan purpose** → Business loans carry the highest exposure ($6.52B)
- **High-DTI segment** analysis → Top 10% DTI borrowers average 0.86 DTI with 12.15% default rate
- **Credit risk buckets** → Poor credit (<580) segment holds 51% of all loans yet defaults at 12.47%

## Results
- Identified that age and employment type are the strongest default predictors in this portfolio
- Revealed that 130K+ borrowers in the Poor credit bucket represent the single largest risk concentration
- Produced a clean, analysis-ready dataset with engineered features for downstream modeling
