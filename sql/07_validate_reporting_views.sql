SELECT COUNT(*) AS transaction_detail_rows
FROM fraud.vw_transaction_detail;

SELECT COUNT(*) AS fraud_summary_daily_rows
FROM fraud.vw_fraud_summary_daily;

SELECT COUNT(*) AS transaction_type_rows
FROM fraud.vw_transaction_type_performance;

SELECT COUNT(*) AS origin_account_risk_rows
FROM fraud.vw_origin_account_risk;

SELECT *
FROM fraud.vw_transaction_type_performance
ORDER BY fraud_amount DESC;

SELECT *
FROM fraud.vw_fraud_summary_daily
ORDER BY transaction_date
LIMIT 10;

SELECT *
FROM fraud.vw_origin_account_risk
ORDER BY fraud_amount DESC
LIMIT 10;