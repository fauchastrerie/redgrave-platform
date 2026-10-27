# redgrave-platform

AFC Redgrave data platform — **RED-201 · dbt and the medallion pattern** (Jules Faucher).

```
REDGRAVE.BRONZE (raw, COPY INTO)  →  REDGRAVE.SILVER (dbt views)  →  REDGRAVE.GOLD (dbt tables, Power BI)
```

## Contents

| Path | What it is |
|---|---|
| `redgrave_dbt/` | The dbt project (dbt-core 1.11): models, tests, freshness, macros |
| `redgrave_dbt/models/silver/` | `silver_products`, `silver_orders` (dedup, lower-case channel, `order_date`), `silver_order_lines` (line revenue + joins) |
| `redgrave_dbt/models/gold/` | `gold_revenue_by_channel`, `gold_daily_sales`, `gold_top_products` |
| `redgrave_dbt/models/*/schema.yml` | Tests: unique / not_null / accepted_values / relationships |
| `redgrave_dbt/tests/` | Singular test: gold must not lose or invent revenue |
| `submit_answers_dbt.sql` | My answers (Q1–Q5), already run in Snowflake (`REDGRAVE.LAB.ANSWERS`) |

## Results (Snowflake account UH10925)

| Check | Result |
|---|---|
| `GOLD_REVENUE_BY_CHANNEL` | matchday kiosk 76 / 11,476.00 · megastore 76 / 6,872.00 · online 76 / 3,088.00 → **21,436.00 GBP** |
| `GOLD_DAILY_SALES` | **30 rows** (240 orders, 12 refunded) |
| `SILVER_ORDER_LINES` | 480 rows, 22,120.00 GBP (same as Postgres) |
| `dbt test` | `Done. PASS=18 WARN=0 ERROR=0` |
| `dbt build` | `Done. PASS=24 WARN=0 ERROR=0 SKIP=0` |
| Step 8 (status `PENDING` injected) | `FAIL 1 accepted_values_silver_orders_status__paid__refunded` → `PASS=10 ERROR=1 SKIP=13` |
| After fix | `Done. PASS=24` |
| `dbt source freshness` | `WARN` on `orders` and `order_items` (last load 2026-10-22, > 24 h, < 90 days) |

All runs are logged in `REDGRAVE.LAB.DBT_RESULTS` by the `on-run-end` hook.

## How it was run

dbt was executed with **dbt Projects on Snowflake** (`EXECUTE DBT PROJECT`, dbt Core 1.11.11, compatible with `require-dbt-version: >=1.11.0, <1.12.0`), with the project object `REDGRAVE.LAB.REDGRAVE_DBT`. Inside Snowflake the connection is the Snowsight session, so the `profiles.yml` used there had no `env_var(...)`. The `profiles.yml` committed here is the course one: it only reads environment variables, so there is no secret in this repository. Because `REDGRAVE_RUNTIME` is not set in Snowflake, the `runtime` column in `DBT_RESULTS` shows the macro default, `local`. `dbt docs serve` is not available in Snowflake: docs were generated with `dbt docs generate`, and the lineage can be viewed on the dbt project page in Snowsight.

To run it locally (as in the lab):

```bash
cd redgrave_dbt
python3 -m venv .venv && source .venv/bin/activate
pip install dbt-core==1.11.16 dbt-snowflake==1.11.6
export SNOWFLAKE_ACCOUNT="ORGNAME-ACCOUNTNAME" SNOWFLAKE_USER="YOUR_USER" SNOWFLAKE_PRIVATE_KEY_FILE="/full/path/to/rsa_key.p8"
export DBT_PROFILES_DIR=.
dbt debug && dbt build && dbt source freshness
```
