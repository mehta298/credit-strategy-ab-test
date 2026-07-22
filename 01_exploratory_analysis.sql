-- ================================================
-- Credit Strategy A/B Test
-- File 1: Exploratory Analysis
-- Data: Lending Club 2007-2018 (1.37M loans)
-- ================================================

-- Overall portfolio baseline
SELECT
    COUNT(*) AS total_loans,
    ROUND(AVG(fico_score), 0) AS avg_fico,
    ROUND(AVG(annual_income), 0) AS avg_income,
    ROUND(AVG(dti), 1) AS avg_dti,
    ROUND(AVG(loan_amount), 0) AS avg_loan_amount,
    SUM(went_delinquent) AS total_delinquent,
    ROUND(AVG(went_delinquent) * 100, 2) AS overall_delinquency_rate_pct
FROM loans;

-- Delinquency rate by FICO band
-- Shows the fundamental risk-score relationship
SELECT 
    CASE 
        WHEN fico_score < 620 THEN 'Below 620'
        WHEN fico_score < 640 THEN '620 to 639'
        WHEN fico_score < 660 THEN '640 to 659'
        WHEN fico_score < 680 THEN '660 to 679'
        WHEN fico_score < 700 THEN '680 to 699'
        WHEN fico_score < 720 THEN '700 to 719'
        WHEN fico_score >= 720 THEN '720 and above'
    END AS fico_band,
    COUNT(*) AS total_loans,
    SUM(went_delinquent) AS delinquent_loans,
    ROUND(AVG(went_delinquent) * 100, 2) AS delinquency_rate_pct
FROM loans
GROUP BY fico_band
ORDER BY MIN(fico_score);