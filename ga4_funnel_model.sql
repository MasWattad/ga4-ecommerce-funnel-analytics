/* =========================================================
   1) BASE EVENTS (cleaned extraction + stable session key)
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_events_base` AS
WITH base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_dt,
    event_timestamp,
    user_pseudo_id,
    event_name,

    -- session fields inside event_params
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS ga_session_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_number') AS ga_session_number,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'engaged_session_event') AS engaged_session_event,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'session_engaged') AS session_engaged,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_location,

    device.category AS device_category,
    geo.country AS country,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium,
    traffic_source.name AS campaign,

    ecommerce.transaction_id AS transaction_id,
    ecommerce.purchase_revenue_in_usd AS purchase_revenue_usd

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
SELECT
  *,
  CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS session_key
FROM base
WHERE ga_session_id IS NOT NULL;


/* =========================================================
   2) SESSION FUNNEL FLAGS (one row per session)
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_session_funnel_flags` AS
SELECT
  event_dt,
  session_key,
  user_pseudo_id,
  ga_session_id,
  MIN(event_timestamp) AS session_start_ts,

  -- session-level step flags (did it happen at least once in the session?)
  MAX(IF(event_name = 'page_view', 1, 0)) AS has_page_view,
  MAX(IF(event_name = 'view_item', 1, 0)) AS has_view_item,
  MAX(IF(event_name = 'add_to_cart', 1, 0)) AS has_add_to_cart,
  MAX(IF(event_name = 'begin_checkout', 1, 0)) AS has_begin_checkout,
  MAX(IF(event_name = 'purchase', 1, 0)) AS has_purchase,

  -- engagement
  MAX(IF(session_engaged = '1' OR engaged_session_event = 1, 1, 0)) AS is_engaged,

  -- new vs returning
  MAX(IF(ga_session_number = 1, 1, 0)) AS is_new_user_session,

  ANY_VALUE(device_category) AS device_category,
  ANY_VALUE(country) AS country,
  ANY_VALUE(traffic_source) AS traffic_source,
  ANY_VALUE(traffic_medium) AS traffic_medium,
  ANY_VALUE(campaign) AS campaign

FROM `funnel-ga4-project.funnel_ga4.vw_events_base`
GROUP BY 1,2,3,4;


/* =========================================================
   3) DAILY FUNNEL KPIs (main funnel uses reliable steps)
   Funnel: page_view -> view_item -> begin_checkout -> purchase
   Diagnostics: cart event coverage + checkout without cart rate
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_funnel_daily` AS
SELECT
  event_dt,
  COUNT(*) AS sessions,

  SUM(has_page_view) AS sessions_page_view,
  SUM(has_view_item) AS sessions_view_item,
  SUM(has_begin_checkout) AS sessions_begin_checkout,
  SUM(has_purchase) AS sessions_purchase,

  SAFE_DIVIDE(SUM(has_view_item), SUM(has_page_view)) AS cr_page_to_item,
  SAFE_DIVIDE(SUM(has_begin_checkout), SUM(has_view_item)) AS cr_item_to_checkout,
  SAFE_DIVIDE(SUM(has_purchase), SUM(has_begin_checkout)) AS cr_checkout_to_purchase,
  SAFE_DIVIDE(SUM(has_purchase), COUNT(*)) AS cr_session_to_purchase,

  -- diagnostics for instrumentation / UX gaps
  SUM(has_add_to_cart) AS sessions_add_to_cart,
  SAFE_DIVIDE(SUM(has_add_to_cart), COUNT(*)) AS rate_cart_event_coverage,

  SAFE_DIVIDE(
    SUM(CASE WHEN has_begin_checkout = 1 AND has_add_to_cart = 0 THEN 1 ELSE 0 END),
    COUNT(*)
  ) AS rate_checkout_without_cart

FROM `funnel-ga4-project.funnel_ga4.vw_session_funnel_flags`
GROUP BY 1;


/* =========================================================
   4) SEGMENT FUNNEL KPIs
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_funnel_by_segment` AS
SELECT
  device_category,
  traffic_medium,
  is_new_user_session,

  COUNT(*) AS sessions,
  SUM(has_view_item) AS sessions_view_item,
  SUM(has_begin_checkout) AS sessions_begin_checkout,
  SUM(has_purchase) AS sessions_purchase,

  SAFE_DIVIDE(SUM(has_purchase), COUNT(*)) AS cr_session_to_purchase,
  SAFE_DIVIDE(SUM(has_begin_checkout), SUM(has_view_item)) AS cr_item_to_checkout,
  SAFE_DIVIDE(SUM(has_purchase), SUM(has_begin_checkout)) AS cr_checkout_to_purchase,

  -- diagnostics
  SUM(has_add_to_cart) AS sessions_add_to_cart,
  SAFE_DIVIDE(SUM(has_add_to_cart), COUNT(*)) AS rate_cart_event_coverage,
  SAFE_DIVIDE(
    SUM(CASE WHEN has_begin_checkout = 1 AND has_add_to_cart = 0 THEN 1 ELSE 0 END),
    COUNT(*)
  ) AS rate_checkout_without_cart

FROM `funnel-ga4-project.funnel_ga4.vw_session_funnel_flags`
GROUP BY 1,2,3;


/* =========================================================
   5) REVENUE DAILY (purchase-only)
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_revenue_daily` AS
SELECT
  event_dt,
  COUNT(DISTINCT transaction_id) AS transactions,
  SUM(purchase_revenue_usd) AS revenue_usd,
  SAFE_DIVIDE(SUM(purchase_revenue_usd), COUNT(DISTINCT transaction_id)) AS aov_usd
FROM `funnel-ga4-project.funnel_ga4.vw_events_base`
WHERE event_name = 'purchase'
  AND transaction_id IS NOT NULL
GROUP BY 1;


/* =========================================================
   6) TIME TO PURCHASE (view -> checkout -> purchase)
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_time_to_purchase` AS
WITH per_session AS (
  SELECT
    session_key,
    MIN(IF(event_name='view_item', event_timestamp, NULL)) AS first_view_item_ts,
    MIN(IF(event_name='begin_checkout', event_timestamp, NULL)) AS first_begin_checkout_ts,
    MIN(IF(event_name='purchase', event_timestamp, NULL)) AS first_purchase_ts
  FROM `funnel-ga4-project.funnel_ga4.vw_events_base`
  GROUP BY 1
)
SELECT
  session_key,
  first_view_item_ts,
  first_begin_checkout_ts,
  first_purchase_ts,

  IF(first_begin_checkout_ts IS NOT NULL AND first_view_item_ts IS NOT NULL,
     (first_begin_checkout_ts - first_view_item_ts)/1e6, NULL) AS sec_view_to_checkout,

  IF(first_purchase_ts IS NOT NULL AND first_begin_checkout_ts IS NOT NULL,
     (first_purchase_ts - first_begin_checkout_ts)/1e6, NULL) AS sec_checkout_to_purchase,

  IF(first_purchase_ts IS NOT NULL AND first_view_item_ts IS NOT NULL,
     (first_purchase_ts - first_view_item_ts)/1e6, NULL) AS sec_view_to_purchase

FROM per_session
WHERE first_purchase_ts IS NOT NULL;


/* =========================================================
   7) SEGMENT FUNNEL + REVENUE (FIXED: uses vw_events_base)
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_segment_revenue_funnel` AS
WITH session_revenue AS (
  SELECT
    session_key,
    SUM(IFNULL(purchase_revenue_usd, 0)) AS session_revenue_usd
  FROM `funnel-ga4-project.funnel_ga4.vw_events_base`
  WHERE event_name = 'purchase'
  GROUP BY 1
)
SELECT
  f.device_category,
  f.traffic_medium,
  f.is_new_user_session,

  COUNT(*) AS sessions,
  SUM(f.has_view_item) AS sessions_view_item,
  SUM(f.has_begin_checkout) AS sessions_begin_checkout,
  SUM(f.has_purchase) AS sessions_purchase,

  SAFE_DIVIDE(SUM(f.has_view_item), COUNT(*)) AS rate_session_to_item,
  SAFE_DIVIDE(SUM(f.has_begin_checkout), SUM(f.has_view_item)) AS cr_item_to_checkout,
  SAFE_DIVIDE(SUM(f.has_purchase), SUM(f.has_begin_checkout)) AS cr_checkout_to_purchase,
  SAFE_DIVIDE(SUM(f.has_purchase), COUNT(*)) AS cr_session_to_purchase,

  SUM(IFNULL(r.session_revenue_usd, 0)) AS revenue_usd,
  SAFE_DIVIDE(SUM(IFNULL(r.session_revenue_usd, 0)), COUNT(*)) AS revenue_per_session_usd,
  SAFE_DIVIDE(SUM(IFNULL(r.session_revenue_usd, 0)), NULLIF(SUM(f.has_purchase), 0)) AS revenue_per_purchasing_session_usd,

  SUM(f.has_add_to_cart) AS sessions_add_to_cart,
  SAFE_DIVIDE(SUM(f.has_add_to_cart), COUNT(*)) AS rate_add_to_cart_event_coverage,
  SAFE_DIVIDE(
    SUM(CASE WHEN f.has_begin_checkout = 1 AND f.has_add_to_cart = 0 THEN 1 ELSE 0 END),
    COUNT(*)
  ) AS rate_checkout_without_cart_event

FROM `funnel-ga4-project.funnel_ga4.vw_session_funnel_flags` f
LEFT JOIN session_revenue r USING(session_key)
GROUP BY 1,2,3;


/* =========================================================
   8) DAILY FUNNEL + REVENUE (single trend table)
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_daily_funnel_revenue` AS
SELECT
  d.event_dt,
  d.sessions,
  d.sessions_view_item,
  d.sessions_begin_checkout,
  d.sessions_purchase,
  d.cr_session_to_purchase,
  d.cr_item_to_checkout,
  d.cr_checkout_to_purchase,
  r.transactions,
  r.revenue_usd,
  r.aov_usd,
  SAFE_DIVIDE(r.revenue_usd, d.sessions) AS revenue_per_session_usd
FROM `funnel-ga4-project.funnel_ga4.vw_funnel_daily` d
LEFT JOIN `funnel-ga4-project.funnel_ga4.vw_revenue_daily` r
  USING(event_dt);


/* =========================================================
   9) TIME-TO-PURCHASE DAILY STATS (polished: ignore NULLs)
   ========================================================= */

CREATE OR REPLACE VIEW `funnel-ga4-project.funnel_ga4.vw_time_to_purchase_daily_stats` AS
WITH session_dates AS (
  SELECT
    session_key,
    MIN(event_dt) AS event_dt
  FROM `funnel-ga4-project.funnel_ga4.vw_session_funnel_flags`
  GROUP BY 1
),
t AS (
  SELECT
    sd.event_dt,
    tp.sec_view_to_purchase,
    tp.sec_view_to_checkout,
    tp.sec_checkout_to_purchase
  FROM `funnel-ga4-project.funnel_ga4.vw_time_to_purchase` tp
  JOIN session_dates sd USING(session_key)
)
SELECT
  event_dt,
  COUNT(*) AS purchasing_sessions,

  APPROX_QUANTILES(sec_view_to_purchase, 100)[OFFSET(50)] AS median_sec_view_to_purchase,
  APPROX_QUANTILES(sec_view_to_checkout, 100)[OFFSET(50)] AS median_sec_view_to_checkout,
  APPROX_QUANTILES(sec_checkout_to_purchase, 100)[OFFSET(50)] AS median_sec_checkout_to_purchase,

  APPROX_QUANTILES(sec_view_to_purchase, 100)[OFFSET(90)] AS p90_sec_view_to_purchase,
  APPROX_QUANTILES(sec_view_to_checkout, 100)[OFFSET(90)] AS p90_sec_view_to_checkout,
  APPROX_QUANTILES(sec_checkout_to_purchase, 100)[OFFSET(90)] AS p90_sec_checkout_to_purchase

FROM t
WHERE sec_view_to_purchase IS NOT NULL
  AND sec_view_to_checkout IS NOT NULL
  AND sec_checkout_to_purchase IS NOT NULL
GROUP BY 1;


SELECT *
FROM `funnel-ga4-project.funnel_ga4.vw_session_funnel_flags`
ORDER BY event_dt
LIMIT 20;


SELECT
  event_dt,
  COUNT(*) AS sessions_total,
  SUM(has_page_view) AS sessions_with_page_view,
  SUM(has_view_item) AS sessions_with_view_item,
  SUM(has_begin_checkout) AS sessions_with_begin_checkout,
  SUM(has_purchase) AS sessions_with_purchase,
  SUM(has_add_to_cart) AS sessions_with_add_to_cart
FROM `funnel-ga4-project.funnel_ga4.vw_session_funnel_flags`
GROUP BY 1
ORDER BY event_dt
LIMIT 15;
