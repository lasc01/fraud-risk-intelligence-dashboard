SELECT COUNT(*) AS dim_time_rows
FROM fraud.dim_time;

SELECT COUNT(*) AS dim_transaction_type_rows
FROM fraud.dim_transaction_type;

SELECT COUNT(*) AS dim_account_rows
FROM fraud.dim_account;

SELECT COUNT(*) AS fact_transactions_rows
FROM fraud.fact_transactions;

SELECT dtt.transaction_type, COUNT(*) AS transaction_count
FROM fraud.fact_transactions ft
JOIN fraud.dim_transaction_type dtt
    ON ft.transaction_type_key = dtt.transaction_type_key
GROUP BY dtt.transaction_type
ORDER BY transaction_count DESC;

SELECT ft.is_fraud, COUNT(*) AS fraud_count
FROM fraud.fact_transactions ft
GROUP BY ft.is_fraud
ORDER BY ft.is_fraud;
