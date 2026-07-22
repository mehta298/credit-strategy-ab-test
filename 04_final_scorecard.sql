-- ================================================
-- File 4: Complete A/B Test Scorecard
-- ================================================
-- Single query using CTEs to produce the full
-- test result with recommendation
-- Key insight: statistical significance vs
-- practical significance in large portfolios

WITH champion AS (
    SELECT
        COUNT(*) AS approved,
        SUM(went_delinquent) AS delinquent,
        AVG(went_delinquent) AS delinq_rate
    FROM strategy_decisions
    WHERE champion_decision = 'approved'
),
challenger AS (
    SELECT
        COUNT(*) AS approved,
        SUM(went_delinquent) AS delinquent,
        AVG(went_delinquent) AS delinq_rate
    FROM strategy_decisions
    WHERE challenger_decision = 'approved'
),
total AS (
    SELECT COUNT(*) AS total_pop
    FROM strategy_decisions
)
SELECT
    -- Volume metrics
    c.approved AS champion_approved,
    ch.approved AS challenger_approved,
    c.approved - ch.approved AS borrowers_excluded,
    ROUND((ch.approved - c.approved) * 100.0 / 
          c.approved, 1) AS volume_impact_pct,

    -- Risk metrics
    ROUND(c.delinq_rate * 100, 2) AS champion_delinq_rate,
    ROUND(ch.delinq_rate * 100, 2) AS challenger_delinq_rate,
    ROUND((ch.delinq_rate - c.delinq_rate) * 100, 2)
        AS absolute_diff_pp,
    ROUND((ch.delinq_rate - c.delinq_rate) /
          c.delinq_rate * 100, 1) AS relative_reduction_pct,

    -- Impact
    c.delinquent - ch.delinquent AS bad_loans_prevented,

    -- Success criteria
    CASE WHEN (ch.delinq_rate - c.delinq_rate) /
              c.delinq_rate * 100 <= -15
         THEN 'MET' ELSE 'NOT MET'
    END AS delinq_target_15pct,

    CASE WHEN (ch.approved - c.approved) * 100.0 /
              c.approved >= -10
         THEN 'MET' ELSE 'NOT MET'
    END AS volume_target_10pct,

    -- Final recommendation
    CASE
        WHEN (ch.delinq_rate - c.delinq_rate) /
             c.delinq_rate * 100 <= -15
         AND (ch.approved - c.approved) * 100.0 /
             c.approved >= -10
        THEN 'SCALE CHALLENGER'
        WHEN (ch.delinq_rate - c.delinq_rate) /
             c.delinq_rate * 100 > -15
        THEN 'DO NOT SCALE — delinquency improvement insufficient'
        ELSE 'DO NOT SCALE — volume impact exceeds threshold'
    END AS recommendation

FROM champion c, challenger ch, total t;