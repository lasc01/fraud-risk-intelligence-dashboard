CREATE OR REPLACE VIEW fraud.vw_transaction_detail AS
SELECT
    ft.transaction_id,
    dt.time_key,
    dt.transaction_datetime,
    dt.transaction_date,
    dt.year,
    dt.quarter,
    dt.month,
    dt.month_name,
    dt.day,
    dt.hour,
    dt.day_name,
    dt.is_weekend,
    dtt.transaction_type,
    oa.account_id AS origin_account_id,
    oa.account_type AS origin_account_type,
    oa.party_type AS origin_party_type,
    da.account_id AS destination_account_id,
    da.account_type AS destination_account_type,
    da.party_type AS destination_party_type,
    ft.amount,
    ft.origin_balance_before,
    ft.origin_balance_after,
    ft.destination_balance_before,
    ft.destination_balance_after,
    ft.is_fraud,
    ft.is_flagged_fraud,
    ft.is_night_transaction,
    ft.high_value_flag,
    ft.balance_change_check
FROM fraud.fact_transactions ft
JOIN fraud.dim_time dt
    ON ft.time_key = dt.time_key
JOIN fraud.dim_transaction_type dtt
    ON ft.transaction_type_key = dtt.transaction_type_key
JOIN fraud.dim_account oa
    ON ft.origin_account_key = oa.account_key
JOIN fraud.dim_account da
    ON ft.destination_account_key = da.account_key;


CREATE OR REPLACE VIEW fraud.vw_fraud_summary_daily AS
SELECT
    dt.transaction_date,
    dt.year,
    dt.quarter,
    dt.month,
    dt.month_name,
    COUNT(*) AS total_transactions,
    SUM(ft.amount) AS total_transaction_amount,
    SUM(CASE WHEN ft.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    SUM(CASE WHEN ft.is_fraud = 1 THEN ft.amount ELSE 0 END) AS fraud_amount,
    SUM(CASE WHEN ft.is_flagged_fraud = 1 THEN 1 ELSE 0 END) AS flagged_transactions,
    SUM(CASE WHEN ft.is_flagged_fraud = 1 THEN ft.amount ELSE 0 END) AS flagged_amount,
    SUM(CASE WHEN ft.high_value_flag = 1 THEN 1 ELSE 0 END) AS high_value_transactions,
    SUM(CASE WHEN ft.balance_change_check = 1 THEN 1 ELSE 0 END) AS balance_issue_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN ft.is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*),
        4
    ) AS fraud_rate_pct,
    ROUND(
        100.0 * SUM(CASE WHEN ft.is_flagged_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*),
        4
    ) AS flagged_rate_pct
FROM fraud.fact_transactions ft
JOIN fraud.dim_time dt
    ON ft.time_key = dt.time_key
GROUP BY
    dt.transaction_date,
    dt.year,
    dt.quarter,
    dt.month,
    dt.month_name
ORDER BY dt.transaction_date;


CREATE OR REPLACE VIEW fraud.vw_transaction_type_performance AS
SELECT
    dtt.transaction_type,
    COUNT(*) AS total_transactions,
    SUM(ft.amount) AS total_amount,
    AVG(ft.amount) AS avg_amount,
    SUM(CASE WHEN ft.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    SUM(CASE WHEN ft.is_fraud = 1 THEN ft.amount ELSE 0 END) AS fraud_amount,
    SUM(CASE WHEN ft.is_flagged_fraud = 1 THEN 1 ELSE 0 END) AS flagged_transactions,
    SUM(CASE WHEN ft.high_value_flag = 1 THEN 1 ELSE 0 END) AS high_value_transactions,
    SUM(CASE WHEN ft.balance_change_check = 1 THEN 1 ELSE 0 END) AS balance_issue_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN ft.is_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*),
        4
    ) AS fraud_rate_pct,
    ROUND(
        100.0 * SUM(CASE WHEN ft.is_flagged_fraud = 1 THEN 1 ELSE 0 END) / COUNT(*),
        4
    ) AS flagged_rate_pct
FROM fraud.fact_transactions ft
JOIN fraud.dim_transaction_type dtt
    ON ft.transaction_type_key = dtt.transaction_type_key
GROUP BY dtt.transaction_type
ORDER BY fraud_amount DESC, total_amount DESC;


CREATE OR REPLACE VIEW fraud.vw_origin_account_risk AS
WITH account_metrics AS (
    SELECT
        oa.account_id AS origin_account_id,
        oa.account_type AS origin_account_type,
        oa.party_type AS origin_party_type,
        COUNT(*) AS transaction_count,
        SUM(ft.amount) AS total_amount,
        AVG(ft.amount) AS avg_amount,
        SUM(CASE WHEN ft.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_transaction_count,
        SUM(CASE WHEN ft.is_fraud = 1 THEN ft.amount ELSE 0 END) AS fraud_amount,
        SUM(CASE WHEN ft.is_flagged_fraud = 1 THEN 1 ELSE 0 END) AS flagged_transaction_count,
        SUM(CASE WHEN ft.high_value_flag = 1 THEN 1 ELSE 0 END) AS high_value_transaction_count,
        SUM(CASE WHEN ft.is_night_transaction = 1 THEN 1 ELSE 0 END) AS night_transaction_count,
        SUM(CASE WHEN ft.balance_change_check = 1 THEN 1 ELSE 0 END) AS balance_issue_count
    FROM fraud.fact_transactions ft
    JOIN fraud.dim_account oa
        ON ft.origin_account_key = oa.account_key
    GROUP BY
        oa.account_id,
        oa.account_type,
        oa.party_type
)
SELECT
    origin_account_id,
    origin_account_type,
    origin_party_type,
    transaction_count,
    total_amount,
    avg_amount,
    fraud_transaction_count,
    fraud_amount,
    flagged_transaction_count,
    high_value_transaction_count,
    night_transaction_count,
    balance_issue_count,
    ROUND(
        100.0 * fraud_transaction_count / NULLIF(transaction_count, 0),
        4
    ) AS fraud_rate_pct,
    CASE
        WHEN fraud_transaction_count >= 5 THEN 'Critical'
        WHEN fraud_transaction_count >= 2 THEN 'High'
        WHEN flagged_transaction_count >= 1 OR high_value_transaction_count >= 5 THEN 'Medium'
        ELSE 'Low'
    END AS risk_band
FROM account_metrics
ORDER BY fraud_amount DESC, fraud_transaction_count DESC, total_amount DESC;