CREATE SCHEMA IF NOT EXISTS fraud;

CREATE TABLE IF NOT EXISTS fraud.dim_time (
    time_key INT PRIMARY KEY,
    transaction_datetime TIMESTAMP UNIQUE,
    transaction_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    hour INT,
    day_of_week INT,
    day_name VARCHAR(20),
    is_weekend INT,
    is_night_transaction INT
);

CREATE TABLE IF NOT EXISTS fraud.dim_transaction_type (
    transaction_type_key SERIAL PRIMARY KEY,
    transaction_type VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS fraud.dim_account (
    account_key BIGSERIAL PRIMARY KEY,
    account_id VARCHAR(50) UNIQUE,
    account_type VARCHAR(10),
    party_type VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS fraud.fact_transactions (
    transaction_key BIGSERIAL PRIMARY KEY,
    transaction_id VARCHAR(20) UNIQUE,
    time_key INT NOT NULL,
    transaction_type_key INT NOT NULL,
    origin_account_key BIGINT NOT NULL,
    destination_account_key BIGINT NOT NULL,
    amount NUMERIC(18,2),
    origin_balance_before NUMERIC(18,2),
    origin_balance_after NUMERIC(18,2),
    destination_balance_before NUMERIC(18,2),
    destination_balance_after NUMERIC(18,2),
    is_fraud INT,
    is_flagged_fraud INT,
    is_night_transaction INT,
    high_value_flag INT,
    balance_change_check INT,
    FOREIGN KEY (time_key) REFERENCES fraud.dim_time(time_key),
    FOREIGN KEY (transaction_type_key) REFERENCES fraud.dim_transaction_type(transaction_type_key),
    FOREIGN KEY (origin_account_key) REFERENCES fraud.dim_account(account_key),
    FOREIGN KEY (destination_account_key) REFERENCES fraud.dim_account(account_key)
);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_time_key
ON fraud.fact_transactions(time_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_type_key
ON fraud.fact_transactions(transaction_type_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_origin_account_key
ON fraud.fact_transactions(origin_account_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_destination_account_key
ON fraud.fact_transactions(destination_account_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_is_fraud
ON fraud.fact_transactions(is_fraud);
