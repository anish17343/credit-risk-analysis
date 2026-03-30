# Default rate by credit score risk bucket
SELECT
    CASE
        WHEN credit_score >= 750 THEN 'Excellent (750+)'
        WHEN credit_score >= 670 THEN 'Good (670–749)'
        WHEN credit_score >= 580 THEN 'Fair (580–669)'
        ELSE 'Poor (<580)'
    END AS risk_bucket,
    COUNT(*) AS total_loans,
    SUM(`default`) AS total_defaults,
    ROUND(AVG(`default`) * 100, 2) AS default_rate_pct,
    ROUND(AVG(loan_amount), 0) AS avg_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM credit_data
GROUP BY risk_bucket
ORDER BY MIN(credit_score) DESC;

# Stress analysis by employment type
SELECT
    CASE
        WHEN `employment_type_Part-time` = TRUE THEN 'Part-time'
        WHEN `employment_type_Self-employed` = TRUE THEN 'Self-employed'
        WHEN employment_type_Unemployed = TRUE THEN 'Unemployed'
        ELSE 'Full-time'
    END AS employment_type,
    COUNT(*) AS total_borrowers,
    ROUND(AVG(income_loan_ratio), 3) AS avg_income_loan_ratio,
    ROUND(AVG(dti_ratio), 3) AS avg_dti,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(`default`) * 100, 2) AS default_rate_pct
FROM credit_data
GROUP BY employment_type
HAVING COUNT(*) > 50
ORDER BY default_rate_pct DESC;

# Profile the riskiest 10% of borrowers
WITH ranked AS (
    SELECT *,
        NTILE(10) OVER (ORDER BY dti_ratio DESC) AS dti_decile
    FROM credit_data
)
SELECT
    'Top 10% highest DTI' AS segment,
    COUNT(*) AS borrowers,
    ROUND(AVG(dti_ratio), 3) AS avg_dti,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    ROUND(AVG(income), 0) AS avg_income,
    ROUND(AVG(loan_amount), 0) AS avg_loan_amount,
    ROUND(AVG(`default`) * 100, 2) AS default_rate_pct,
    ROUND(AVG(estimated_monthly_interest), 2) AS avg_monthly_interest
FROM ranked
WHERE dti_decile = 1;

# Multi-step default funnel using CTEs
WITH age_groups AS (
    SELECT *,
        CASE
            WHEN age < 30 THEN 'Under 30'
            WHEN age BETWEEN 30 AND 45 THEN '30–45'
            WHEN age BETWEEN 46 AND 60 THEN '46–60'
            ELSE 'Over 60'
        END AS age_group
    FROM credit_data
),
term_defaults AS (
    SELECT
        age_group,
        loan_term,
        COUNT(*) AS total,
        SUM(`default`) AS defaults,
        ROUND(AVG(`default`) * 100, 2) AS default_rate_pct,
        ROUND(AVG(loan_amount), 0) AS avg_loan_amount
    FROM age_groups
    GROUP BY age_group, loan_term
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY age_group ORDER BY default_rate_pct DESC) AS rank_within_age
    FROM term_defaults
)
SELECT age_group, loan_term, total, defaults, default_rate_pct, avg_loan_amount
FROM ranked
WHERE rank_within_age = 1
ORDER BY default_rate_pct DESC;

# Portfolio concentration risk
SELECT
    CASE
        WHEN loan_purpose_Business = TRUE THEN 'Business'
        WHEN loan_purpose_Education = TRUE THEN 'Education'
        WHEN loan_purpose_Home = TRUE THEN 'Home'
        WHEN loan_purpose_Other = TRUE THEN 'Other'
        ELSE 'Uncategorized'
    END AS loan_purpose,
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 0) AS total_exposure,
    ROUND(AVG(`default`) * 100, 2) AS default_rate_pct,
    ROUND(SUM(loan_amount * `default`) / SUM(loan_amount) * 100, 2) AS exposure_weighted_default_pct,
    ROUND(AVG(estimated_monthly_interest), 2) AS avg_monthly_interest,
    ROUND(
        SUM(loan_amount) / (SELECT SUM(loan_amount) FROM credit_data) * 100,
        2
    ) AS portfolio_share_pct
FROM credit_data
GROUP BY loan_purpose
ORDER BY exposure_weighted_default_pct DESC;