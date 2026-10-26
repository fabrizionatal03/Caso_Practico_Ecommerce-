-- 03_perfil_order_items.sql

SELECT
  status,
  COUNT(*) AS total_items,
  COUNT(DISTINCT order_id) AS ordenes_distintas,
  COUNTIF(order_id IS NULL) AS order_id_nulos,
  COUNTIF(product_id IS NULL) AS product_id_nulos,
  COUNTIF(inventory_item_id IS NULL) AS inventory_id_nulos,
  COUNTIF(sale_price IS NULL) AS precios_nulos,
  COUNTIF(sale_price <= 0) AS precios_no_positivos,
  ROUND(AVG(sale_price), 2) AS precio_promedio
FROM `bussiness-case-tyc.bussiness_case_ecommerce.order_items`
GROUP BY status
ORDER BY total_items DESC;
