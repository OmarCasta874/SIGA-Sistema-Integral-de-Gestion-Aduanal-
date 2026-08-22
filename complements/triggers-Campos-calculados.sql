-- =============================================================================
-- SIGA – Sistema Integral de Gestión Aduanal
-- Conversión de columnas GENERATED a columnas normales mantenidas por triggers
-- Aplica a: producto.valor_total, producto.peso_total, arancel.igi_importe,
--           factura.total
-- =============================================================================

USE BaseDatosSIGA;

-- =============================================================================
-- PASO 1: Quitar la definición GENERATED de cada columna (queda como columna
-- normal, editable, que los triggers de abajo se encargarán de mantener).
--
-- NOTA: MariaDB no permite convertir una columna GENERATED a columna normal
-- con MODIFY COLUMN directamente (error #1907). Hay que eliminarla y
-- volverla a crear como columna normal.
-- =============================================================================

ALTER TABLE producto
  DROP COLUMN valor_total,
  DROP COLUMN peso_total;

ALTER TABLE producto
  ADD COLUMN valor_total DECIMAL(14,2) NULL,
  ADD COLUMN peso_total  DECIMAL(12,2) NULL;

ALTER TABLE arancel
  DROP COLUMN igi_importe;

ALTER TABLE arancel
  ADD COLUMN igi_importe DECIMAL(12,2) NULL;

ALTER TABLE factura
  DROP COLUMN total;

ALTER TABLE factura
  ADD COLUMN total DECIMAL(12,2) NULL;

-- NOTA: al hacer DROP + ADD, las columnas quedan al final de la tabla
-- (cambia su posición respecto al esquema original) y las filas que YA
-- existían quedan con NULL en estas columnas, porque los triggers de más
-- abajo solo se disparan en INSERT/UPDATE futuros, no de forma retroactiva.
-- El PASO 3 rellena ("backfill") los datos existentes para que no queden
-- en NULL mientras tanto.

-- =============================================================================
-- PASO 1.5 (BACKFILL): Rellenar el valor calculado en las filas que ya
-- existían antes de este cambio, ya que los triggers del PASO 2 solo
-- afectan INSERT/UPDATE futuros.
-- =============================================================================

UPDATE producto
SET valor_total = valor_unitario * cantidad,
    peso_total  = peso * cantidad;

UPDATE arancel
SET igi_importe = subtotal * IGI / 100;

UPDATE factura
SET total = subtotal + IVA;

-- =============================================================================
-- PASO 2: Triggers que calculan el valor en cada INSERT/UPDATE
-- =============================================================================

DROP TRIGGER IF EXISTS trg_producto_calculados_ins;
DROP TRIGGER IF EXISTS trg_producto_calculados_upd;
DROP TRIGGER IF EXISTS trg_arancel_igi_importe_ins;
DROP TRIGGER IF EXISTS trg_arancel_igi_importe_upd;
DROP TRIGGER IF EXISTS trg_factura_total_ins;
DROP TRIGGER IF EXISTS trg_factura_total_upd;

-- -----------------------------------------------------------------------------
-- TRIGGER: trg_producto_calculados_ins / _upd
-- Tabla   : producto
-- Objetivo: Calcular valor_total (valor_unitario * cantidad) y peso_total
--           (peso * cantidad) antes de guardar la fila, para que el dato
--           quede consistente sin que la aplicación tenga que calcularlo.
-- -----------------------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER trg_producto_calculados_ins
BEFORE INSERT ON producto
FOR EACH ROW
BEGIN
    SET NEW.valor_total = NEW.valor_unitario * NEW.cantidad;
    SET NEW.peso_total  = NEW.peso * NEW.cantidad;
END$$

CREATE TRIGGER trg_producto_calculados_upd
BEFORE UPDATE ON producto
FOR EACH ROW
BEGIN
    SET NEW.valor_total = NEW.valor_unitario * NEW.cantidad;
    SET NEW.peso_total  = NEW.peso * NEW.cantidad;
END$$

DELIMITER ;

-- -----------------------------------------------------------------------------
-- TRIGGER: trg_arancel_igi_importe_ins / _upd
-- Tabla   : arancel
-- Objetivo: Calcular igi_importe (subtotal * IGI / 100) antes de guardar
--           la fila, reflejando el importe real del IGI en pesos.
-- -----------------------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER trg_arancel_igi_importe_ins
BEFORE INSERT ON arancel
FOR EACH ROW
BEGIN
    SET NEW.igi_importe = NEW.subtotal * NEW.IGI / 100;
END$$

CREATE TRIGGER trg_arancel_igi_importe_upd
BEFORE UPDATE ON arancel
FOR EACH ROW
BEGIN
    SET NEW.igi_importe = NEW.subtotal * NEW.IGI / 100;
END$$

DELIMITER ;

-- -----------------------------------------------------------------------------
-- TRIGGER: trg_factura_total_ins / _upd
-- Tabla   : factura
-- Objetivo: Calcular total (subtotal + IVA) antes de guardar la fila,
--           garantizando que el total de la factura sea consistente.
-- -----------------------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER trg_factura_total_ins
BEFORE INSERT ON factura
FOR EACH ROW
BEGIN
    SET NEW.total = NEW.subtotal + NEW.IVA;
END$$

CREATE TRIGGER trg_factura_total_upd
BEFORE UPDATE ON factura
FOR EACH ROW
BEGIN
    SET NEW.total = NEW.subtotal + NEW.IVA;
END$$

DELIMITER ;

-- =============================================================================
-- Verificación:
-- DESCRIBE producto;   -- valor_total y peso_total ya NO deben mostrar
--                         "GENERATED" en Extra (columna normal)
-- DESCRIBE arancel;    -- igi_importe sin GENERATED
-- DESCRIBE factura;    -- total sin GENERATED
-- SHOW TRIGGERS FROM BaseDatosSIGA LIKE 'producto';
-- SHOW TRIGGERS FROM BaseDatosSIGA LIKE 'arancel';
-- SHOW TRIGGERS FROM BaseDatosSIGA LIKE 'factura';
--
-- Prueba manual (ejemplo con producto):
--   INSERT INTO producto (nombre, descripcion, peso, valor_unitario, cantidad, paquete)
--   VALUES ('Prueba trigger', 'Producto de prueba', 2.5, 100.00, 4, <algún código de paquete>);
--   SELECT nombre, valor_total, peso_total FROM producto WHERE nombre = 'Prueba trigger';
--   -> valor_total debe ser 400.00 y peso_total debe ser 10.00, calculados
--      automáticamente por el trigger sin haberlos escrito en el INSERT.
-- =============================================================================
