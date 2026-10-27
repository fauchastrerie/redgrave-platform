-- AFC Redgrave · dbt lab · write your answers in YOUR Snowflake account
-- Replace each <...> with your answer (keep the $$ on both sides), then Run All.
-- You can run this file again: it replaces your previous answers for this lab.

USE ROLE SYSADMIN;
USE WAREHOUSE REDGRAVE_WH;
CREATE SCHEMA IF NOT EXISTS REDGRAVE.LAB;
CREATE TABLE IF NOT EXISTS REDGRAVE.LAB.ANSWERS (
    lab VARCHAR, question VARCHAR, answer VARCHAR, submitted_at TIMESTAMP_TZ);

DELETE FROM REDGRAVE.LAB.ANSWERS WHERE lab = 'RED-201';

INSERT INTO REDGRAVE.LAB.ANSWERS VALUES
('RED-201', 'NAME', $$Jules Faucher$$, CURRENT_TIMESTAMP()),
('RED-201', 'Q1', $$Silver models are views because they are intermediate cleaning steps: a view stores nothing, is cheap to build and is recomputed at each read, so it always reflects the latest bronze data. Gold models are tables because Power BI dashboards read them all day: the result (joins + aggregations) is stored once at each dbt run and read many times without recomputing. One line per folder in dbt_project.yml (+materialized: view / table) decides it.$$, CURRENT_TIMESTAMP()),
('RED-201', 'Q2', $$source() reads a table that dbt does not build (the bronze tables loaded by COPY INTO), declared in sources.yml with its database and schema; it also allows the freshness check. ref() reads another dbt model: dbt resolves it to the right schema and uses it to build the dependency graph (DAG), so it runs models in the right order (silver_orders and silver_products before silver_order_lines, then the gold tables).$$, CURRENT_TIMESTAMP()),
('RED-201', 'Q3', $$The test accepted_values_silver_orders_status__paid__refunded failed (1 failing row: order 999 with status PENDING, lower-cased to pending in silver, which is not in [paid, refunded]). dbt build runs and tests each node in DAG order and skips everything downstream of a failed test: result PASS=10 ERROR=1 SKIP=13 (silver_order_lines, the 3 gold tables and their tests). So gold was not rebuilt with bad data and the dashboard kept the last correct numbers. The channel test did not fail because Online became online in silver (lower(trim(channel))).$$, CURRENT_TIMESTAMP()),
('RED-201', 'Q4', $$dbt source freshness answered WARN for bronze.orders and bronze.order_items (products has freshness: null, so it is not checked): the last _loaded_at is 2026-10-22, about 5 days old, which is older than warn_after (24 hours) but younger than error_after (90 days). It warns whenever the last load is more than 24 hours old; it would be PASS after a reload less than 24 hours ago, and ERROR if no load arrived for more than 90 days.$$, CURRENT_TIMESTAMP()),
('RED-201', 'Q5', $$Everything to the right of silver_orders in the lineage graph: silver_order_lines (it refs silver_orders), then gold_revenue_by_channel, gold_daily_sales and gold_top_products (they all ref silver_order_lines), plus their tests (relationships test on silver_order_lines.order_id, unique/not_null on gold keys, assert_gold_matches_silver).$$, CURRENT_TIMESTAMP());

SELECT question, answer FROM REDGRAVE.LAB.ANSWERS WHERE lab = 'RED-201' ORDER BY question;
