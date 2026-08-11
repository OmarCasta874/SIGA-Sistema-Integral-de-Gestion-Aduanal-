-- =============================================================================
-- SIGA – Sistema Integral de Gestión Aduanal
-- Triggers de base de datos
-- Universidad Tecnológica de Tijuana – Bases de Datos Avanzadas
-- =============================================================================

USE BaseDatosSIGA;

DROP TRIGGER IF EXISTS t_generar_permiso;
DROP TRIGGER IF EXISTS t_generar_operacion;
DROP TRIGGER IF EXISTS t_generar_pedimento;
DROP TRIGGER IF EXISTS trg_generar_folio_permiso;
DROP TRIGGER IF EXISTS trg_validar_apertura_operacion;
DROP TRIGGER IF EXISTS trg_inspeccion_automatica_semaforo_rojo;

DROP TRIGGER IF EXISTS t_generar_operacion;

-- =============================================================================
-- TRIGGER 2
-- Nombre   : t_generar_operacion
-- Evento   : BEFORE INSERT
-- Tabla principal  : operacion_aduanera
-- Tablas consultas : producto, paquete (verificar mercancía del cliente)
-- Tablas afectadas : bitacora (INSERT automático),
--                    operacion_aduanera (SET NEW.bitacora con el FK generado)
-- Objetivo : Validar que el cliente tenga mercancía registrada en el sistema
--            antes de permitir la apertura de una operación aduanera, ya que
--            no puede despacharse una operación sin productos que amparar.
--            Además, crea automáticamente el registro en bitácora y lo vincula
--            a la operación, resolviendo la dependencia del FK sin intervención
--            manual.
-- RFs      : RF30 – Registro de operación aduanera con cliente, aduana y fecha
--            RF33 – Validación de requisitos antes de procesar una operación
--            RF52 – Registro automático en bitácora de cada acción del sistema
-- =============================================================================

DELIMITER $$

CREATE OR REPLACE TRIGGER t_generar_operacion
BEFORE INSERT ON operacion_aduanera
FOR EACH ROW
BEGIN
    DECLARE tieneProductos INT DEFAULT 0;
    DECLARE msg VARCHAR(250);

    -- Verificar que el cliente tenga al menos 1 paquete con productos registrados
    SELECT total_productos
    INTO tieneProductos
    FROM v_mercancia_cliente
    WHERE cliente = NEW.cliente;

    IF tieneProductos IS NULL OR tieneProductos = 0 THEN
        SET msg = CONCAT(
            'OPERACION BLOQUEADA: El cliente #', NEW.cliente,
            ' no tiene mercancia registrada en el sistema. ',
            'Registre al menos un paquete con productos antes de abrir una operacion aduanera.'
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;

    -- Crear el registro en bitácora para esta operación
    INSERT INTO bitacora (descripcion, fecha, hora, modulo, tipo_accion)
    VALUES (
        CONCAT(
            'Apertura de operacion aduanera – Cliente #', NEW.cliente,
            ', Tipo: ', NEW.tipo_operacion,
            ', Aduana: #', NEW.aduana, '.'
        ),
        CURDATE(),
        CURTIME(),
        'Operaciones',
        'Creación'
    );

    -- Vincular la bitácora recién creada a la operación (resuelve el FK automáticamente)
    SET NEW.bitacora = LAST_INSERT_ID();

END$$

DELIMITER ;

-- =============================================================================
-- TRIGGER 3
-- Nombre   : t_generar_pedimento
-- Evento   : BEFORE INSERT
-- Tabla principal  : pedimento
-- Tablas consultas : permiso (verificar vigencia),
--                    producto, paquete, operacion_aduanera (verificar mercancía),
--                    semaforo_fiscal (leer resultado rojo/verde)
-- Tablas afectadas : inspeccion (INSERT automático si semáforo es rojo)
-- Objetivo : Ser el guardián del documento oficial de despacho aduanero.
--            Antes de aceptar el pedimento verifica que el permiso regulatorio
--            adjunto esté vigente y que la operación tenga mercancía declarada.
--            Una vez validado, evalúa el resultado del semáforo fiscal asignado:
--            si es rojo genera automáticamente la orden de inspección física,
--            si es verde el pedimento queda liberado sin revisión adicional.
-- RFs      : RF40 – Generación del pedimento con información consolidada
--            RF33 – Validación de permiso y mercancía antes de procesar
--            RF51 – Control de permisos vencidos en operaciones aduaneras
--            RF55 – Registro automático de inspección al detectar semáforo rojo
--            RF35 – Registro del resultado del despacho (verde / rojo)
-- =============================================================================

DROP TRIGGER IF EXISTS t_generar_pedimento;

DELIMITER $$

CREATE OR REPLACE TRIGGER t_generar_pedimento
BEFORE INSERT ON pedimento
FOR EACH ROW
BEGIN
    DECLARE estatusPermiso VARCHAR(10);
    DECLARE tipoPerm VARCHAR(50);
    DECLARE vigenciaPermiso DATE;
    DECLARE tieneProductos INT DEFAULT 0;
    DECLARE resultadoSemaforo VARCHAR(100);
    DECLARE msg VARCHAR(250);

    -- 1. Verificar que el permiso vinculado al pedimento no esté vencido
    SELECT vigencia, tipo_permiso, estatus
    INTO vigenciaPermiso, tipoPerm, estatusPermiso
    FROM v_permisos_vigencia
    WHERE clave_numerica = NEW.permiso
    LIMIT 1;

    IF estatusPermiso = 'Vencido' THEN
        SET msg = CONCAT(
            'PEDIMENTO BLOQUEADO: El permiso ', NEW.permiso,
            ' (', tipoPerm, ') vencio el ', vigenciaPermiso,
            '. Renueve la autorizacion antes de generar el pedimento.'
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;

    -- 2. Verificar que la operacion tenga paquetes con productos declarados
    SELECT total_productos
    INTO tieneProductos
    FROM v_mercancia_cliente
    WHERE cliente = (
        SELECT cliente
        FROM operacion_aduanera
        WHERE ID_operacion = NEW.ope_aduanera
        LIMIT 1
    );

    IF tieneProductos IS NULL OR tieneProductos = 0 THEN
        SET msg = CONCAT(
            'PEDIMENTO BLOQUEADO: La operacion #', NEW.ope_aduanera,
            ' no tiene mercancia registrada. ',
            'Declare los paquetes y productos antes de generar el pedimento.'
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;

    -- 3. Evaluar el semáforo fiscal asignado al pedimento
    SELECT resultado INTO resultadoSemaforo
    FROM semaforo_fiscal
    WHERE ID = NEW.semaforo
    LIMIT 1;

    -- 4. Si el semáforo es rojo, crear automáticamente la orden de inspección física
    IF resultadoSemaforo LIKE '%Rojo%' THEN
        INSERT INTO inspeccion (fecha_inspeccion, hora_inicio, resultado, semaforo)
        VALUES (CURDATE(), CURTIME(), 'Pendiente', NEW.semaforo);
    END IF;

END$$

DELIMITER ;