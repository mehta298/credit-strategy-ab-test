-- ================================================
-- File 2: Champion and Challenger Strategy View
-- ================================================
-- Creates a view applying both strategies to every
-- loan simultaneously for fair comparison

CREATE VIEW IF NOT EXISTS strategy_decisions AS
SELECT
    loan_id,
    fico_score,
    annual_income,
    dti,
    loan_amount,
    went_delinquent,
    loan_status,
    grade,

    -- Champion: current approval policy
    CASE 
        WHEN fico_score >= 620 
         AND annual_income >= 40000 
         AND dti <= 45 
        THEN 'approved'
        ELSE 'declined'
    END AS champion_decision,

    -- Challenger: tightened approval policy
    CASE 
        WHEN fico_score >= 640 
         AND annual_income >= 45000 
         AND dti <= 40 
        THEN 'approved'
        ELSE 'declined'
    END AS challenger_decision,

    -- Segment classification
    CASE
        WHEN fico_score >= 620 
         AND annual_income >= 40000 
         AND dti <= 45
         AND NOT (fico_score >= 640 
              AND annual_income >= 45000 
              AND dti <= 40)
        THEN 'champion_only'
        WHEN fico_score >= 640 
         AND annual_income >= 45000 
         AND dti <= 40
        THEN 'both_approve'
        ELSE 'both_decline'
    END AS decision_segment

FROM loans;