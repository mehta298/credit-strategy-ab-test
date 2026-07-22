-- ================================================
-- File 3: A/B Test Analysis Queries
-- ================================================

-- Query 1: Approval volume comparison
SELECT
    'Champion' AS strategy,
    COUNT(*) AS approved_loans,
    ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM strategy_decisions), 1) 
        AS approval_rate_pct
FROM strategy_decisions
WHERE champion_decision = 'approved'

UNION ALL

SELECT
    'Challenger' AS strategy,
    COUNT(*) AS approved_loans,
    ROUND(COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM strategy_decisions), 1) 
        AS approval_rate_pct
FROM strategy_decisions
WHERE challenger_decision = 'approved';


-- Query 2: Delinquency rate comparison
SELECT
    'Champion' AS strategy,
    COUNT(*) AS approved_loans,
    SUM(went_delinquent) AS delinquent_loans,
    ROUND(AVG(went_delinquent) * 100, 2) AS delinquency_rate_pct
FROM strategy_decisions
WHERE champion_decision = 'approved'

UNION ALL

SELECT
    'Challenger' AS strategy,
    COUNT(*) AS approved_loans,
    SUM(went_delinquent) AS delinquent_loans,
    ROUND(AVG(went_delinquent) * 100, 2) AS delinquency_rate_pct
FROM strategy_decisions
WHERE challenger_decision = 'approved';


-- Query 3: Marginal population analysis
-- Who exactly does the challenger exclude?
SELECT
    decision_segment,
    COUNT(*) AS loan_count,
    ROUND(AVG(fico_score), 0) AS avg_fico,
    ROUND(AVG(annual_income), 0) AS avg_income,
    ROUND(AVG(dti), 1) AS avg_dti,
    ROUND(AVG(went_delinquent) * 100, 2) AS delinquency_rate_pct,
    ROUND(AVG(loan_amount), 0) AS avg_loan_amount
FROM strategy_decisions
WHERE champion_decision = 'approved'
GROUP BY decision_segment
ORDER BY delinquency_rate_pct DESC;