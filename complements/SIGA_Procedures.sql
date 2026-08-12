--PROCEDIMIENTOS ALMACENADOS SIGA

--2. SP2 - sp_resumen_operacion

-- Cuando se tiene una operación aduanera, por medio del ID/ver detalles de 
-- la operación (en el sistema), se mostrará la mayor parte de la información de
-- esta operación

DROP PROCEDURE IF EXISTS sp_resumen_operacion;

DELIMITER $$
CREATE PROCEDURE sp_resumen_operacion(IN p_operacion INT)
BEGIN
    SELECT DISTINCT
        Operacion,
        Cliente,
        RFC,
        TipoOperacion,
        EstadoOperacion,
        CodigoAduana,
        Aduana,
        Pedimento,
        ValorPedimento
    FROM v_desglose_operacion
    WHERE Operacion = p_operacion;
END$$
DELIMITER ;

CALL sp_resumen_operacion(4);


-- 4. SP4 - sp_consultar_vencimientos

-- Avisa al usuario el número de días que le restan a los permisos por vencer

DROP PROCEDURE IF EXISTS sp_consultar_vencimientos;

DELIMITER $$
CREATE PROCEDURE sp_consultar_vencimientos(IN p_dias INT)
BEGIN
    SELECT
        'Permiso' AS tipo_documento,
        v.clave_numerica AS identificador,
        v.vigencia AS fecha_vencimiento,
        v.dias_restantes,
        v.cliente AS referencia
    FROM v_permisos_vigencia v
    WHERE v.vigencia BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL p_dias DAY)
    UNION ALL
    SELECT
        'Pedimento' AS tipo_documento,
        pe.numero_pedimento AS identificador,
        DATE(pe.fecha_limite) AS fecha_vencimiento,
        DATEDIFF(DATE(pe.fecha_limite), CURDATE()) AS dias_restantes,
        pe.ope_aduanera AS referencia
    FROM pedimento pe
    WHERE pe.fecha_limite IS NOT NULL
      AND pe.fecha_limite BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL p_dias DAY)
    ORDER BY fecha_vencimiento ASC;
END$$
DELIMITER ;

CALL sp_consultar_vencimientos(30);