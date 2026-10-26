-- 05_integridad_referencial.sql
-- Comprobar registros sin correspondencia entre tablas.

SELECT
  'orders -> users' AS relacion,
  COUNT(*) AS registros_sin_correspondencia
FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders` o
LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.users` u
  ON o.user_id = u.id
WHERE u.id IS NULL

UNION ALL

SELECT
  'order_items -> orders',
  COUNT(*)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.orders` o
  ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
  'order_items -> products',
  COUNT(*)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.products` p
  ON oi.product_id = p.id
WHERE p.id IS NULL

UNION ALL

SELECT
  'order_items -> inventory_items',
  COUNT(*)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items` oi
LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.inventory_items` i
  ON oi.inventory_item_id = i.id
WHERE i.id IS NULL

UNION ALL

SELECT
  'events identificados -> users',
  COUNT(*)
FROM `bussiness-case-tyc.bussiness_case_ecommerce.events` e
LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.users` u
  ON e.user_id = u.id
WHERE e.user_id IS NOT NULL
  AND u.id IS NULL;