-- 01_exploracion.sql
-- Perfil inicial de claves por tabla
SELECT
  'orders' AS tabla,
  COUNT(*) AS total_filas,
  COUNTIF(order_id IS NULL) AS claves_nulas,
  COUNT(*) - COUNT(DISTINCT order_id)
    - COUNTIF(order_id IS NULL) AS filas_con_clave_repetida
FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`

UNION ALL

SELECT 'order_items',
  COUNT(*),
  COUNTIF(id IS NULL),
  COUNT(*) - COUNT(DISTINCT id) - COUNTIF(id IS NULL)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items`

UNION ALL

SELECT 'users',
  COUNT(*),
  COUNTIF(id IS NULL),
  COUNT(*) - COUNT(DISTINCT id) - COUNTIF(id IS NULL)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.users`

UNION ALL

SELECT 'products',
  COUNT(*),
  COUNTIF(id IS NULL),
  COUNT(*) - COUNT(DISTINCT id) - COUNTIF(id IS NULL)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.products`

UNION ALL

SELECT 'events',
  COUNT(*),
  COUNTIF(id IS NULL),
  COUNT(*) - COUNT(DISTINCT id) - COUNTIF(id IS NULL)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.events`

UNION ALL

SELECT 'inventory_items',
  COUNT(*),
  COUNTIF(id IS NULL),
  COUNT(*) - COUNT(DISTINCT id) - COUNTIF(id IS NULL)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.inventory_items`

UNION ALL

SELECT 'distribution_centers',
  COUNT(*),
  COUNTIF(id IS NULL),
  COUNT(*) - COUNT(DISTINCT id) - COUNTIF(id IS NULL)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.distribution_centers`;
