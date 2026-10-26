-- 14_validacion_customer_model.sql
-- Validaciones de la tabla final.

SELECT
  COUNT(*) AS total_filas,
  COUNT(DISTINCT user_id) AS clientes_unicos,

  COUNT(*) - COUNT(DISTINCT user_id)
    AS filas_duplicadas,

  COUNTIF(user_id IS NULL) AS ids_nulos,
  COUNTIF(first_order_id IS NULL) AS primera_orden_nula,
  COUNTIF(first_order_ts IS NULL) AS primera_fecha_nula,

  COUNTIF(repurchase_60d = 1) AS recompra_si,
  COUNTIF(repurchase_60d = 0) AS recompra_no,
  COUNTIF(repurchase_60d IS NULL) AS target_nulo,

  COUNTIF(
    has_full_60d_history = 1
    AND repurchase_60d IS NULL
  ) AS inconsistencia_seguimiento_1,

  COUNTIF(
    has_full_60d_history = 0
    AND repurchase_60d IS NOT NULL
  ) AS inconsistencia_seguimiento_2,

  COUNTIF(n_items IS NULL OR n_items <= 0)
    AS cantidad_items_invalida,

  COUNTIF(order_value IS NULL OR order_value <= 0)
    AS importe_invalido,

  COUNTIF(n_events_pre IS NULL)
    AS eventos_nulos,

  COUNTIF(days_since_signup < 0)
    AS antiguedad_negativa

FROM `bussiness-case-tyc.fabrizio_natal.customer_model`;