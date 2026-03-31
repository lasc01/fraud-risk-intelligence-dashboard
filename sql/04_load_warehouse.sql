TRUNCATE TABLE fraud.fact_transactions RESTART IDENTITY CASCADE;
TRUNCATE TABLE fraud.dim_time RESTART IDENTITY CASCADE;
TRUNCATE TABLE fraud.dim_transaction_type RESTART IDENTITY CASCADE;
TRUNCATE TABLE fraud.dim_account RESTART IDENTITY CASCADE;

INSERT INTO fraud.dim_time (
    time_key,
    transaction_datetime,
    transaction_date,
    year,
    quarter,
    month,
    month_name,
    day,
    hour,
    day_of_week,
    day_name,
    is_weekend,
    is_night_transaction
)
SELECT DISTINCT
    TO_CHAR(transaction_datetime, 'YYYYMMDDHH24')::INT AS time_key,
    transaction_datetime,
    transaction_date,
    EXTRACT(YEAR FROM transaction_datetime)::INT AS year,
    EXTRACT(QUARTER FROM transaction_datetime)::INT AS quarter,
    EXTRACT(MONTH FROM transaction_datetime)::INT AS month,
    TRIM(TO_CHAR(transaction_datetime, 'Month'))::VARCHAR(20) AS month_name,
    EXTRACT(DAY FROM transaction_datetime)::INT AS day,
    EXTRACT(HOUR FROM transaction_datetime)::INT AS hour,
    EXTRACT(DOW FROM transaction_datetime)::INT AS day_of_week,
    TRIM(TO_CHAR(transaction_datetime, 'Day'))::VARCHAR(20) AS day_name,
    CASE
        WHEN EXTRACT(DOW FROM transaction_datetime) IN (0, 6) THEN 1
        ELSE 0
    END AS is_weekend,
    is_night_transaction
FROM fraud.stg_transactions;

INSERT INTO fraud.dim_transaction_type (transaction_type)
SELECT DISTINCT transaction_type
FROM fraud.stg_transactions
ORDER BY transaction_type;

INSERT INTO fraud.dim_account (
    account_id,
    account_type,
    party_type
)
SELECT DISTINCT
    account_id,
    account_type,
    CASE
        WHEN account_type = 'C' THEN 'Customer'
        WHEN account_type = 'M' THEN 'Merchant'
        ELSE 'Unknown'
    END AS party_type
FROM (
    SELECT origin_account_id AS account_id,
           origin_account_type AS account_type
    FROM fraud.stg_transactions

    UNION

    SELECT destination_account_id AS account_id,
           destination_account_type AS account_type
    FROM fraud.stg_transactions
) a;

INSERT INTO fraud.fact_transactions (
    transaction_id,
    time_key,
    transaction_type_key,
    origin_account_key,
    destination_account_key,
    amount,
    origin_balance_before,
    origin_balance_after,
    destination_balance_before,
    destination_balance_after,
    is_fraud,
    is_flagged_fraud,
    is_night_transaction,
    high_value_flag,
    balance_change_check
)
SELECT
    s.transaction_id,
    TO_CHAR(s.transaction_datetime, 'YYYYMMDDHH24')::INT AS time_key,
    dtt.transaction_type_key,
    oa.account_key AS origin_account_key,
    da.account_key AS destination_account_key,
    s.amount,
    s.origin_balance_before,
    s.origin_balance_after,
    s.destination_balance_before,
    s.destination_balance_after,
    s.is_fraud,
    s.is_flagged_fraud,
    s.is_night_transaction,
    s.high_value_flag,
    s.balance_change_check
FROM fraud.stg_transactions s
JOIN fraud.dim_transaction_type dtt
    ON s.transaction_type = dtt.transaction_type
JOIN fraud.dim_account oa
    ON s.origin_account_id = oa.account_id
JOIN fraud.dim_account da
    ON s.destination_account_id = da.account_id;
