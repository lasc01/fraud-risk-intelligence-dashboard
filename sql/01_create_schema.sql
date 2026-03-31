CREATE SCHEMA IF NOT EXISTS fraud;

CREATE TABLE IF NOT EXISTS fraud.stg_transactions (
    transaction_id VARCHAR(20),
    transaction_datetime TIMESTAMP,
    transaction_date DATE,
    step_hour INT,
    transaction_hour INT,
    transaction_type VARCHAR(50),
    origin_account_id VARCHAR(50),
    destination_account_id VARCHAR(50),
    origin_account_type VARCHAR(10),
    destination_account_type VARCHAR(10),
    amount NUMERIC(18,2),
    origin_balance_before NUMERIC(18,2),
    origin_balance_after NUMERIC(18,2),
    destination_balance_before NUMERIC(18,2),
    destination_balance_after NUMERIC(18,2),
    is_fraud INT,
    is_flagged_fraud INT,
    is_night_transaction INT,
    high_value_flag INT,
    balance_change_check INT
);