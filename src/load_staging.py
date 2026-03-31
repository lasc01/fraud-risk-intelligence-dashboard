from pathlib import Path
import os

import psycopg2
from dotenv import load_dotenv


load_dotenv()

CLEANED_FILE = Path("data/cleaned/transactions_cleaned.csv")


def get_connection():
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    dbname = os.getenv("DB_NAME")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")

    print(f"Connecting with host={host}, port={port}, dbname={dbname}, user={user}")
    print(f"Password loaded: {'YES' if password else 'NO'}")

    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password
    )


def validate_file():
    if not CLEANED_FILE.exists():
        raise FileNotFoundError(f"Cleaned file not found: {CLEANED_FILE}")


def load_csv_to_staging():
    validate_file()

    file_size_mb = CLEANED_FILE.stat().st_size / (1024 * 1024)
    print(f"CSV file found: {CLEANED_FILE}")
    print(f"CSV size: {file_size_mb:,.2f} MB")
    print("Connecting to PostgreSQL...")

    conn = get_connection()
    cur = conn.cursor()

    try:
        print("Truncating staging table...")
        cur.execute("TRUNCATE TABLE fraud.stg_transactions;")
        conn.commit()

        print("Loading CSV directly into fraud.stg_transactions...")

        with open(CLEANED_FILE, "r", encoding="utf-8") as f:
            cur.copy_expert(
                """
                COPY fraud.stg_transactions (
                    transaction_id,
                    transaction_datetime,
                    transaction_date,
                    step_hour,
                    transaction_hour,
                    transaction_type,
                    origin_account_id,
                    destination_account_id,
                    origin_account_type,
                    destination_account_type,
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
                FROM STDIN WITH (
                    FORMAT CSV,
                    HEADER TRUE
                )
                """,
                f
            )

        conn.commit()
        print("Load completed successfully.")

        cur.execute("SELECT COUNT(*) FROM fraud.stg_transactions;")
        row_count = cur.fetchone()[0]
        print(f"Rows now in staging table: {row_count:,}")

    except Exception as e:
        conn.rollback()
        print("Load failed.")
        raise e

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    load_csv_to_staging()