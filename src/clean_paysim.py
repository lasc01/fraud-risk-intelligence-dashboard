from pathlib import Path
import pandas as pd


RAW_PATH = Path("data/raw/paysim.csv")
CLEANED_PATH = Path("data/cleaned/transactions_cleaned.csv")
QUALITY_PATH = Path("data/outputs/data_quality_report.csv")


def load_data(file_path: Path) -> pd.DataFrame:
    if not file_path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")
    return pd.read_csv(file_path)


def standardize_columns(df: pd.DataFrame) -> pd.DataFrame:
    rename_map = {
        "step": "step_hour",
        "type": "transaction_type",
        "amount": "amount",
        "nameOrig": "origin_account_id",
        "oldbalanceOrg": "origin_balance_before",
        "newbalanceOrig": "origin_balance_after",
        "nameDest": "destination_account_id",
        "oldbalanceDest": "destination_balance_before",
        "newbalanceDest": "destination_balance_after",
        "isFraud": "is_fraud",
        "isFlaggedFraud": "is_flagged_fraud"
    }
    return df.rename(columns=rename_map)


def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()

    df.columns = [col.strip() for col in df.columns]

    df["transaction_type"] = df["transaction_type"].astype(str).str.strip().str.upper()
    df["origin_account_id"] = df["origin_account_id"].astype(str).str.strip()
    df["destination_account_id"] = df["destination_account_id"].astype(str).str.strip()

    numeric_cols = [
        "step_hour",
        "amount",
        "origin_balance_before",
        "origin_balance_after",
        "destination_balance_before",
        "destination_balance_after",
        "is_fraud",
        "is_flagged_fraud"
    ]

    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df.drop_duplicates()

    df = df[df["amount"].notna()]
    df = df[df["amount"] >= 0]

    df = df[df["step_hour"].notna()]
    df = df[df["step_hour"] >= 0]

    df["transaction_id"] = (
        "TXN"
        + df.index.astype(str).str.zfill(10)
    )

    base_timestamp = pd.Timestamp("2025-01-01 00:00:00")
    df["transaction_datetime"] = base_timestamp + pd.to_timedelta(df["step_hour"], unit="h")

    df["transaction_date"] = df["transaction_datetime"].dt.date
    df["transaction_hour"] = df["transaction_datetime"].dt.hour
    df["is_night_transaction"] = df["transaction_hour"].between(0, 5).astype(int)

    df["origin_account_type"] = df["origin_account_id"].str[0]
    df["destination_account_type"] = df["destination_account_id"].str[0]

    df["balance_change_check"] = (
        (df["origin_balance_before"] - df["amount"]).round(2)
        != df["origin_balance_after"].round(2)
    ).astype(int)

    df["high_value_flag"] = (df["amount"] > df["amount"].quantile(0.95)).astype(int)

    ordered_cols = [
        "transaction_id",
        "transaction_datetime",
        "transaction_date",
        "step_hour",
        "transaction_hour",
        "transaction_type",
        "origin_account_id",
        "destination_account_id",
        "origin_account_type",
        "destination_account_type",
        "amount",
        "origin_balance_before",
        "origin_balance_after",
        "destination_balance_before",
        "destination_balance_after",
        "is_fraud",
        "is_flagged_fraud",
        "is_night_transaction",
        "high_value_flag",
        "balance_change_check"
    ]

    df = df[ordered_cols]

    return df


def create_quality_report(df: pd.DataFrame) -> pd.DataFrame:
    report = pd.DataFrame({
        "column_name": df.columns,
        "data_type": [str(dtype) for dtype in df.dtypes],
        "missing_count": df.isnull().sum().values,
        "missing_percent": ((df.isnull().sum() / len(df)) * 100).round(2).values,
        "unique_count": df.nunique().values
    })
    return report


def main():
    print("\nLoading raw dataset...")
    df = load_data(RAW_PATH)

    print("Standardizing columns...")
    df = standardize_columns(df)

    print("Cleaning data...")
    cleaned_df = clean_data(df)

    print("Creating quality report...")
    quality_report = create_quality_report(cleaned_df)

    CLEANED_PATH.parent.mkdir(parents=True, exist_ok=True)
    QUALITY_PATH.parent.mkdir(parents=True, exist_ok=True)

    cleaned_df.to_csv(CLEANED_PATH, index=False)
    quality_report.to_csv(QUALITY_PATH, index=False)

    print("\nCleaning complete.")
    print(f"Cleaned rows: {len(cleaned_df):,}")
    print(f"Cleaned columns: {cleaned_df.shape[1]}")
    print(f"Saved cleaned file to: {CLEANED_PATH}")
    print(f"Saved quality report to: {QUALITY_PATH}")

    print("\nFraud distribution:")
    print(cleaned_df["is_fraud"].value_counts())

    print("\nTransaction type distribution:")
    print(cleaned_df["transaction_type"].value_counts())

    print("\nPreview:")
    print(cleaned_df.head())


if __name__ == "__main__":
    main()