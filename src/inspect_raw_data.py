from pathlib import Path
import pandas as pd


def inspect_raw_data():
    file_path = Path("data/raw/paysim.csv")

    if not file_path.exists():
        raise FileNotFoundError(f"Dataset not found at: {file_path}")

    df = pd.read_csv(file_path)

    print("\nRAW DATA INSPECTION")
    print("=" * 50)

    print(f"\nShape: {df.shape}")
    print(f"Columns: {list(df.columns)}")

    print("\nFirst 5 rows:")
    print(df.head())

    print("\nData types:")
    print(df.dtypes)

    print("\nMissing values:")
    print(df.isnull().sum())

    print("\nDuplicate rows:")
    print(df.duplicated().sum())

    print("\nTransaction types:")
    print(df["type"].value_counts())

    print("\nFraud label distribution:")
    print(df["isFraud"].value_counts())

    print("\nFlagged fraud distribution:")
    print(df["isFlaggedFraud"].value_counts())

    print("\nBasic amount statistics:")
    print(df["amount"].describe())

    summary_output = Path("data/outputs/raw_data_summary.csv")
    summary = pd.DataFrame({
        "column_name": df.columns,
        "data_type": [str(dtype) for dtype in df.dtypes],
        "missing_count": df.isnull().sum().values,
        "missing_percent": (df.isnull().sum().values / len(df)) * 100
    })

    summary.to_csv(summary_output, index=False)
    print(f"\nSummary file saved to: {summary_output}")


if __name__ == "__main__":
    inspect_raw_data()