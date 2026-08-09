--PROCEDIMIENTOS ALMACENADOS SIGA

--1. SP1 - sp_calcular_valor_operacion

-- Al crear una operación aduanera, calculará la cantidad de paquetes, 
-- productos y su valor total.

DROP PROCEDURE IF EXISTS sp_calcular_valor_operacion;

DELIMITER $$

CREATE PROCEDURE sp_calcular_valor_operacion(
    IN p_operacion INT
)
BEGIN
    SELECT
        oa.ID_operacion,
        COUNT(DISTINCT pa.codigo) AS total_paquetes,
        COUNT(pr.codigo) AS total_productos,
        COALESCE(
            SUM(pr.valor_unitario * pr.cantidad),
            0
        ) AS valor_total
    FROM operacion_aduanera oa

    LEFT JOIN pedimento pe
        ON pe.ope_aduanera = oa.ID_operacion

    LEFT JOIN paquete pa
        ON pa.pedimento = pe.numero_pedimento

    LEFT JOIN producto pr
        ON pr.paquete = pa.codigo

    WHERE oa.ID_operacion = p_operacion

    GROUP BY oa.ID_operacion;
END $$

DELIMITER ;

CALL sp_calcular_valor_operacion(3);

--2. SP2 - sp_resumen_operacion

-- Cuando se tiene una operación aduanera, por medio del ID/ver detalles de 
-- la operación (en el sistema), se mostrará la mayor parte de la información de
-- esta operación

DELIMITER $$

CREATE PROCEDURE sp_resumen_operacion(
    IN p_operacion INT
)
BEGIN
    SELECT
        oa.ID_operacion,
        CONCAT(
            c.nombre, ' ',
            c.primer_apell, ' ',
            c.seg_apell
        ) AS cliente,
        c.RFC,
        oa.tipo_operacion,
        e.descripcion AS estado,
        a.codigo AS aduana,
        a.nombre AS nombre_aduana,
        p.numero_pedimento,
        p.valor_total
    FROM operacion_aduanera oa
    INNER JOIN cliente c
        ON c.numero = oa.cliente
    INNER JOIN estado_opeaduanera e
        ON e.codigo = oa.estado_ope_aduanera
    INNER JOIN aduana a
        ON a.codigo = oa.aduana
    LEFT JOIN pedimento p
        ON p.ope_aduanera = oa.ID_operacion
    WHERE oa.ID_operacion = p_operacion;

END $$
DELIMITER ;

CALL sp_resumen_operacion(4);

-- 3. SP3 - sp_resumen_financiero_cliente

-- Cuando se entra en el módulo de Pagos, y se quieren ver los detalles de 
-- un pago hecho por un cliente, se podrá ver el resumen de su situación financiera.

DELIMITER $$

CREATE PROCEDURE sp_resumen_financiero_cliente(
    IN p_cliente INT
)
BEGIN
    SELECT
        c.numero AS cliente,
        CONCAT(
            c.nombre, ' ',
            c.primer_apell, ' ',
            c.seg_apell
        ) AS nombre_cliente,
        COUNT(DISTINCT p.numero_pedimento) AS total_pedimentos,
        COUNT(
            DISTINCT CASE
                WHEN pg.estado_pago = 1
                THEN pg.no_transaccion
            END
        ) AS pagos_realizados,
        COUNT(
            DISTINCT CASE
                WHEN pg.estado_pago IN (2, 3, 4, 6, 8)
                THEN pg.no_transaccion
            END
        ) AS pagos_pendientes,
        COALESCE(
            SUM(
                CASE
                    WHEN pg.estado_pago = 1
                    THEN pg.monto
                    ELSE 0
                END
            ),
            0
        ) AS total_pagado,
        COALESCE(
            SUM(
                CASE
                    WHEN pg.estado_pago IN (2, 3, 4, 6, 8)
                    THEN pg.saldo_final
                    ELSE 0
                END
            ),
            0
        ) AS saldo_pendiente
    FROM cliente c
    LEFT JOIN operacion_aduanera oa
        ON oa.cliente = c.numero
    LEFT JOIN pedimento p
        ON p.ope_aduanera = oa.ID_operacion
    LEFT JOIN pago pg
        ON pg.pedimento = p.numero_pedimento
    WHERE c.numero = p_cliente
    GROUP BY
        c.numero,
        c.nombre,
        c.primer_apell,
        c.seg_apell;
END$$

DELIMITER ;

CALL sp_resumen_financiero_cliente(4);

-- 4. SP4 - sp_consultar_vencimientos

-- Avisa al usuario el número de días que le restan a los permisos por vencer

DELIMITER $$

CREATE PROCEDURE sp_consultar_vencimientos(
    IN p_dias INT
)
BEGIN
    SELECT
        'Permiso' AS tipo_documento,
        p.clave_numerica AS identificador,
        p.vigencia AS fecha_vencimiento,
        DATEDIFF(p.vigencia, CURDATE()) AS dias_restantes,
        p.cliente AS referencia
    FROM permiso p
    WHERE p.vigencia BETWEEN CURDATE()
                         AND DATE_ADD(CURDATE(), INTERVAL p_dias DAY)
    UNION ALL
    SELECT
        'Pedimento' AS tipo_documento,
        pe.numero_pedimento AS identificador,
        DATE(pe.fecha_limite) AS fecha_vencimiento,
        DATEDIFF(DATE(pe.fecha_limite), CURDATE()) AS dias_restantes,
        pe.ope_aduanera AS referencia
    FROM pedimento pe
    WHERE pe.fecha_limite IS NOT NULL
      AND pe.fecha_limite BETWEEN NOW()
                              AND DATE_ADD(NOW(), INTERVAL p_dias DAY)
    ORDER BY fecha_vencimiento ASC;
END$$

DELIMITER ;

CALL sp_consultar_vencimientos(30);

--5. SP5 - sp_estadisticas_aduana

-- Consulta la información general de una aduana, como sus operaciones, resultados del
-- semáforo fiscal, etc.

DELIMITER $$

CREATE PROCEDURE sp_estadisticas_aduana(
    IN p_aduana INT
)
BEGIN
    SELECT
        a.codigo AS aduana,
        a.nombre AS nombre_aduana,
        COUNT(DISTINCT oa.ID_operacion) AS total_operaciones,
        COUNT(
            DISTINCT CASE
                WHEN LOWER(oa.tipo_operacion) = 'importación'
                THEN oa.ID_operacion
            END
        ) AS importaciones,
        COUNT(
            DISTINCT CASE
                WHEN LOWER(oa.tipo_operacion) = 'exportación'
                THEN oa.ID_operacion
            END
        ) AS exportaciones,
        COUNT(DISTINCT p.numero_pedimento) AS total_pedimentos,
        COUNT(
            DISTINCT CASE
                WHEN sf.resultado LIKE 'Verde%'
                THEN p.numero_pedimento
            END
        ) AS semaforo_verde,
        COUNT(
            DISTINCT CASE
                WHEN sf.resultado LIKE 'Rojo%'
                THEN p.numero_pedimento
            END
        ) AS semaforo_rojo
    FROM aduana a
    LEFT JOIN operacion_aduanera oa
        ON oa.aduana = a.codigo
    LEFT JOIN pedimento p
        ON p.ope_aduanera = oa.ID_operacion
    LEFT JOIN semaforo_fiscal sf
        ON sf.ID = p.semaforo
    WHERE a.codigo = p_aduana
    GROUP BY
        a.codigo,
        a.nombre;
END$$

DELIMITER ;

CALL sp_estadisticas_aduana(4);