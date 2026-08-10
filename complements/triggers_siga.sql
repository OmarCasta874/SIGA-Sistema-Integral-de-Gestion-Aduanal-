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

-- =============================================================================
-- TRIGGER 1
-- Nombre   : t_generar_folio_permiso
-- Evento   : BEFORE INSERT
-- Tabla principal  : permiso
-- Tablas consultas : permiso (lectura del contador global por autoridad)
-- Tablas afectadas : permiso (SET NEW.clave_numerica con el folio generado)
-- Objetivo : Automatizar la generación del folio oficial con la nomenclatura
--            PERM-[REGULADORA]-[AÑO]-[CONTADOR], donde el contador es global
--            por entidad reguladora (independiente por cliente).
--            Si el cliente ya tiene registrado un permiso de la misma entidad,
--            el trigger bloquea el INSERT e informa al sistema que debe
--            renovar el folio existente en lugar de crear uno duplicado.
-- RFs      : RF48 – Generación de permiso con tipo, vigencia y autoridad emisora
--            RF78 – Generación automática de folio de permiso (nuevo RF)
--            RF50 – Actualización de vigencia de permiso existente
--            RF51 – Control y alerta de permisos por entidad reguladora
-- =============================================================================

DELIMITER $$

CREATE OR REPLACE TRIGGER t_generar_folio_permiso
BEFORE INSERT ON permiso
FOR EACH ROW
BEGIN
    DECLARE folioExistente VARCHAR(30) DEFAULT NULL;
    DECLARE contador       INT         DEFAULT 0;
    DECLARE nuevoFolio     VARCHAR(30);
    DECLARE anio           CHAR(4);
    DECLARE msg            VARCHAR(250);

    -- Verificar si el cliente ya tiene un permiso de esta entidad reguladora
    SELECT clave_numerica
    INTO   folioExistente
    FROM   permiso
    WHERE  cliente = NEW.cliente
      AND  tipo_permiso = NEW.tipo_permiso
    LIMIT 1;

    IF folioExistente IS NOT NULL THEN
        -- El cliente ya tiene este permiso → indicar al sistema que renueve
        SET msg = CONCAT(
            'RENOVACION|', folioExistente,
            '|El cliente ya cuenta con el permiso ', folioExistente,
            ' (', NEW.tipo_permiso, '). ',
            'Actualice la vigencia y descripcion del folio existente.'
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;

    ELSE
        -- Calcular el siguiente número global para esta entidad en el año actual
        SET anio = CAST(YEAR(CURDATE()) AS CHAR);

        SELECT COUNT(*) + 1
        INTO   contador
        FROM   permiso
        WHERE  tipo_permiso = NEW.tipo_permiso
          AND  clave_numerica LIKE CONCAT('PERM-', NEW.tipo_permiso, '-', anio, '-%');

        -- Construir folio: PERM-[REGULADORA]-[AÑO]-[NNN]
        SET nuevoFolio = CONCAT(
            'PERM-', NEW.tipo_permiso, '-', anio, '-',
            LPAD(contador, 3, '0')
        );

        SET NEW.clave_numerica = nuevoFolio;
    END IF;

END$$

DELIMITER ;

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
    DECLARE msg            VARCHAR(250);

    -- Verificar que el cliente tenga al menos 1 paquete con productos registrados
    SELECT COUNT(*)
    INTO   tieneProductos
    FROM   producto pr
    JOIN   paquete  pa ON pr.paquete = pa.codigo
    WHERE  pa.cliente = NEW.cliente;

    IF tieneProductos = 0 THEN
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

DELIMITER $$

CREATE OR REPLACE TRIGGER t_generar_pedimento
BEFORE INSERT ON pedimento
FOR EACH ROW
BEGIN
    DECLARE vigenciaPermiso  DATE;
    DECLARE tipoPerm         VARCHAR(50);
    DECLARE tieneProductos   INT DEFAULT 0;
    DECLARE resultadoSemaforo VARCHAR(100);
    DECLARE msg              VARCHAR(250);

    -- 1. Verificar que el permiso vinculado al pedimento no esté vencido
    SELECT vigencia, tipo_permiso
    INTO   vigenciaPermiso, tipoPerm
    FROM   permiso
    WHERE  clave_numerica = NEW.permiso
    LIMIT  1;

    IF vigenciaPermiso < CURDATE() THEN
        SET msg = CONCAT(
            'PEDIMENTO BLOQUEADO: El permiso ', NEW.permiso,
            ' (', tipoPerm, ') vencio el ', vigenciaPermiso,
            '. Renueve la autorizacion antes de generar el pedimento.'
        );
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;

    -- 2. Verificar que la operacion tenga paquetes con productos declarados
    SELECT COUNT(*)
    INTO   tieneProductos
    FROM   producto pr
    INNER JOIN   paquete  pa ON pr.paquete = pa.codigo
    WHERE  pa.cliente = (
               SELECT cliente
               FROM   operacion_aduanera
               WHERE  ID_operacion = NEW.ope_aduanera
               LIMIT  1
           );

    IF tieneProductos = 0 THEN
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

-- =============================================================================
-- FIN DE TRIGGERS
-- Verificar: SHOW TRIGGERS FROM BaseDatosSIGA;
-- =============================================================================

-- =============================================================================
-- NUEVO REQUERIMIENTO FUNCIONAL – AGREGAR AL DOCUMENTO OFICIAL
-- Módulo    : Permisos
-- =============================================================================
--
-- Identificación del requerimiento : RF78
-- Nombre del requerimiento         : Generación automática de folio de permiso
-- Objetivo del requerimiento       : Garantizar que cada permiso generado
--                                    reciba un folio único e irrepetible
--                                    asignado automáticamente por el sistema.
-- Descripción del requerimiento    : El sistema generará automáticamente un
--                                    folio con la nomenclatura
--                                    PERM-[REGULADORA]-[AÑO]-[CONTADOR]
--                                    al asociar un permiso a un cliente.
--                                    El contador es global por entidad
--                                    reguladora, independiente por cliente:
--                                    si ya existe PERM-COFEPRIS-2026-001 en
--                                    el cliente B y el cliente A solicita un
--                                    permiso COFEPRIS, el sistema le asignará
--                                    PERM-COFEPRIS-2026-002.
--                                    Si el cliente ya tiene un permiso de la
--                                    misma entidad reguladora, el sistema no
--                                    generará un nuevo folio sino que
--                                    actualizará la vigencia y descripción
--                                    del permiso existente.
-- Requerimientos no funcionales    : RNF2, RNF3, RNF5, RNF6, RNF7, RNF8
-- Prioridad del requerimiento      : Alta
--
-- =============================================================================
