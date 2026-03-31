# Fraud Risk Intelligence Dashboard for Digital Payments

## Project Summary

This project is an end to end fraud analytics and business intelligence solution built for a digital payments scenario. It was designed to simulate how a fraud analytics team or risk operations team might process raw transaction data, prepare it for reporting, store it in a dimensional warehouse, and turn it into decision ready insights through an executive dashboard.

The solution combines Python, PostgreSQL, SQL, and Power BI to move from raw transactional records to structured fraud monitoring outputs. Instead of treating the project as only a fraud detection exercise, the work was approached as a full analytics workflow with data cleaning, feature engineering, staging, warehouse modelling, reporting layer development, and dashboard design.

The project uses the PaySim synthetic financial transactions dataset and focuses on fraud risk monitoring at scale. The final result is a fraud intelligence dashboard that highlights total activity, fraud scale, fraud concentration, transaction type risk, and daily fraud trends.

## Business Context

Digital payment systems process very large numbers of transactions every day. In such environments, fraud rarely appears evenly across all transaction categories. Some transaction types carry much higher risk than others, and fraud teams need a practical way to answer questions such as:

1. How many transactions are being processed overall.
2. How many of those transactions are fraudulent.
3. What the fraud rate looks like.
4. How much financial exposure is associated with fraud.
5. Which transaction categories are the main drivers of fraud.
6. How fraud behaviour changes over time.
7. Which operational areas should be prioritised for monitoring and control.

This project addresses those questions by building a structured fraud reporting solution that can support both executive level monitoring and analytical exploration.

## Project Objectives

The project was built with the following objectives in mind:

1. Clean and standardise raw transaction data using Python.
2. Create a repeatable ETL workflow for data preparation.
3. Load cleaned records into a PostgreSQL staging layer.
4. Design a dimensional warehouse model suitable for fraud analytics.
5. Create SQL reporting views for simplified dashboard development.
6. Build a Power BI dashboard that presents fraud metrics and trends clearly.
7. Produce insights that could support fraud operations, management reporting, and decision making.

## Why This Project Matters

This project demonstrates more than dashboard creation. It shows the ability to work across multiple layers of a data solution.

1. It shows data cleaning and feature engineering skills in Python.
2. It shows warehousing and SQL modelling skills in PostgreSQL.
3. It shows understanding of dimensional design for analytics.
4. It shows reporting layer preparation through SQL views.
5. It shows business intelligence storytelling in Power BI.

That combination makes the project realistic, practical, and relevant for roles in data analytics, business intelligence, fraud analytics, and analytics engineering.

## Dataset

The project uses the **PaySim synthetic financial transactions dataset**, a widely used dataset for fraud related analysis. The dataset contains transaction level records that simulate mobile money transactions and includes fraud labels.

### Raw dataset characteristics

The original dataset contains 11 columns, including:

1. `step`
2. `type`
3. `amount`
4. `nameOrig`
5. `oldbalanceOrg`
6. `newbalanceOrig`
7. `nameDest`
8. `oldbalanceDest`
9. `newbalanceDest`
10. `isFraud`
11. `isFlaggedFraud`

### Cleaned dataset enrichment

After cleaning and transformation, additional fields were created to make the dataset more suitable for warehouse loading and reporting. These included:

1. `transaction_id`
2. `transaction_datetime`
3. `transaction_date`
4. `transaction_hour`
5. `origin_account_type`
6. `destination_account_type`
7. `is_night_transaction`
8. `high_value_flag`
9. `balance_change_check`

### Final transaction volume

The final warehouse fact table contains:

**6,362,620 transactions**

Fraud validation confirmed:

1. Non fraud transactions: **6,354,407**
2. Fraud transactions: **8,213**

This preserved the original fraud distribution accurately.

## Tools and Technologies

The project was built using the following tools and technologies:

1. **Python**, for data cleaning, transformation, feature engineering, and ETL logic.
2. **Pandas**, for structured data handling and preprocessing.
3. **PostgreSQL**, for staging, warehousing, and SQL based reporting views.
4. **SQL**, for schema creation, table loading, dimensional modelling, and reporting queries.
5. **Power BI**, for dashboard creation and visual storytelling.
6. **GitHub**, for version control and project presentation.

## Solution Architecture

The project follows a layered analytics architecture.

Raw CSV data  
to Python cleaning and standardisation  
to PostgreSQL staging tables  
to dimensional warehouse tables  
to SQL reporting views  
to Power BI dashboard

This layered design is important because it separates data preparation from reporting and makes the solution more realistic than a flat file dashboarding workflow.

### Architecture flow

1. Raw PaySim data is stored in the raw data layer.
2. Python scripts clean, standardise, and enrich the data.
3. Cleaned data is loaded into a PostgreSQL staging table.
4. SQL scripts populate the warehouse dimension tables and fact table.
5. SQL reporting views are created for business ready dashboarding.
6. Power BI connects to the reporting layer to build the dashboard.

## Project Structure

```text
fraud_risk_project/
├── data/
│   ├── raw/
│   ├── cleaned/
│   └── outputs/
├── images/
├── powerbi/
├── sql/
├── src/
├── README.md
└── requirements.txt
