-- 12_validacion_usuarios.sql
-- Calidad y disponibilidad temporal de datos de usuario.

WITH primera_compra AS (
  SELECT
    user_id,
    order_id AS first_order_id,
    created_at AS first_order_ts
  FROM `bussiness-case-tyc.bussiness_case_ecommerce.orders`
  WHERE status IN ('Complete', 'Shipped', 'Processing')
    AND user_id IS NOT NULL
    AND created_at IS NOT NULL
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_id
    ORDER BY created_at, order_id
  ) = 1
)

SELECT
  COUNT(*) AS clientes,
  COUNTIF(u.id IS NULL) AS clientes_sin_usuario,
  COUNTIF(u.age IS NULL) AS edad_nula,
  COUNTIF(u.age < 0 OR u.age > 100) AS edad_fuera_rango,
  COUNTIF(u.gender IS NULL) AS genero_nulo,
  COUNTIF(u.country IS NULL) AS pais_nulo,
  COUNTIF(u.traffic_source IS NULL) AS fuente_nula,
  COUNTIF(u.created_at IS NULL) AS registro_sin_fecha,
  COUNTIF(u.created_at > pc.first_order_ts)
    AS usuarios_registrados_despues,
  ROUND(AVG(u.age), 2) AS edad_promedio
FROM primera_compra pc
LEFT JOIN `bussiness-case-tyc.bussiness_case_ecommerce.users` u
  ON pc.user_id = u.id;
