-- Gold: one row per day, for the chairwoman's daily dashboard. Expected: 30 rows.
select
    order_date,
    count(distinct order_id)                                            as orders,
    count(distinct case when status = 'refunded' then order_id end)     as refunded_orders,
    coalesce(sum(case when status = 'paid' then line_revenue_gbp end), 0) as paid_revenue_gbp
from {{ ref('silver_order_lines') }}
group by order_date
