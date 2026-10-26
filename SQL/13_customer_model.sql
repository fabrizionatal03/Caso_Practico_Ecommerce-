-- 13_customer_model.sql
-- Tabla final: una fila por cliente.
-- Incluye clientes sin seguimiento completo, con target NULL.

CREATE OR REPLACE TABLE
  `bussiness-case-tyc.fabrizio_natal.customer_model`
AS

WITH parametros AS (
  SELECT
    MAX(created_at) AS fecha_corte
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
),

ordenes_validas AS (
  SELECT
    order_id,
    user_id,
    created_at,
    num_of_item,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY created_at, order_id
    ) AS numero_compra
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
  WHERE status IN ('Complete', 'Shipped', 'Processing')
    AND order_id IS NOT NULL
    AND user_id IS NOT NULL
    AND created_at IS NOT NULL
),

primera_compra AS (
  SELECT
    user_id,
    order_id AS first_order_id,
    created_at AS first_order_ts,
    num_of_item AS n_items
  FROM ordenes_validas
  WHERE numero_compra = 1
),

recompras AS (
  SELECT
    pc.user_id,
    COUNT(o.order_id) AS n_reorders_60d
  FROM primera_compra pc
  LEFT JOIN ordenes_validas o
    ON pc.user_id = o.user_id
    AND o.numero_compra > 1
    AND o.created_at <= TIMESTAMP_ADD(
      pc.first_order_ts, INTERVAL 60 DAY
    )
  GROUP BY pc.user_id
),

-- Agregacion a una fila por primera orden.
-- Son variables candidatas bajo el supuesto de checkout.
cesta_inicial AS (
  SELECT
    pc.user_id,
    ROUND(SUM(oi.sale_price), 2) AS order_value,
    COUNT(DISTINCT oi.product_id) AS n_distinct_products,
    COUNT(DISTINCT p.category) AS n_categories,
    COUNT(DISTINCT p.brand) AS n_brands,

    ARRAY_AGG(
      p.department IGNORE NULLS
      ORDER BY oi.sale_price DESC, p.department
      LIMIT 1
    )[SAFE_OFFSET(0)] AS department_highest_price_item,

    ARRAY_AGG(
      p.category IGNORE NULLS
      ORDER BY oi.sale_price DESC, p.category
      LIMIT 1
    )[SAFE_OFFSET(0)] AS category_highest_price_item,

    COUNTIF(oi.created_at > pc.first_order_ts)
      AS n_items_registered_late

  FROM primera_compra pc
  JOIN `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
    ON pc.first_order_id = oi.order_id
  LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.products` p
    ON oi.product_id = p.id
  GROUP BY pc.user_id
),

-- Agregacion a una fila por cliente.
-- Solo incluye navegacion anterior a primera compra.
actividad_previa AS (
  SELECT
    pc.user_id,
    COUNT(e.id) AS n_events_pre,
    COUNT(DISTINCT e.session_id) AS n_sessions_pre,
    COUNTIF(e.event_type = 'product') AS n_product_views_pre,
    COUNTIF(e.event_type = 'cart') AS n_cart_events_pre

  FROM primera_compra pc
  LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.events` e
    ON pc.user_id = e.user_id
    AND e.created_at < pc.first_order_ts
    AND e.event_type IN (
      'product', 'cart', 'department', 'home'
    )
  GROUP BY pc.user_id
)

SELECT
  pc.user_id,
  pc.first_order_id,
  pc.first_order_ts,

  -- Target y elegibilidad
  CASE
    WHEN TIMESTAMP_ADD(
      pc.first_order_ts, INTERVAL 60 DAY
    ) > par.fecha_corte THEN NULL
    WHEN r.n_reorders_60d > 0 THEN 1
    ELSE 0
  END AS repurchase_60d,

  IF(
    TIMESTAMP_ADD(pc.first_order_ts, INTERVAL 60 DAY)
      <= par.fecha_corte,
    1, 0
  ) AS has_full_60d_history,

  -- Variables disponibles en la primera orden
  pc.n_items,
  EXTRACT(MONTH FROM pc.first_order_ts) AS first_order_month,
  EXTRACT(DAYOFWEEK FROM pc.first_order_ts) AS first_order_dow,

  -- Variables candidatas de la primera cesta
  ci.order_value,
  ci.n_distinct_products,
  ci.n_categories,
  ci.n_brands,
  ci.department_highest_price_item,
  ci.category_highest_price_item,

  -- Diagnostico; NO usar como variable predictora
  ci.n_items_registered_late,

  -- Caracteristicas del cliente
  u.age,
  u.gender,
  u.country,
  u.traffic_source,
  TIMESTAMP_DIFF(
    pc.first_order_ts, u.created_at, DAY
  ) AS days_since_signup,

  -- Navegacion previa
  ap.n_events_pre,
  ap.n_sessions_pre,
  ap.n_product_views_pre,
  ap.n_cart_events_pre,

  -- Metadato; NO usar como variable predictora
  par.fecha_corte AS observation_cutoff

FROM primera_compra pc
JOIN recompras r USING (user_id)
CROSS JOIN parametros par
LEFT JOIN cesta_inicial ci USING (user_id)
LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.users` u
  ON pc.user_id = u.id
LEFT JOIN actividad_previa ap USING (user_id);