-- CONSULTAS AVANZADAS SIGA

-- CONSULTA AVANZADA #1

SELECT 
    c.numero AS numero_cliente,
    CONCAT(c.nombre, ' ', c.primer_apell, ' ', c.seg_apell) AS cliente,
    COUNT(p.clave_numerica) AS total_permisos,
    SUM(
        CASE 
            WHEN p.vigencia >= CURDATE() THEN 1
            ELSE 0
        END
    ) AS permisos_vigentes,
    SUM(
        CASE 
            WHEN p.vigencia < CURDATE() THEN 1
            ELSE 0
        END
    ) AS permisos_vencidos,
    MIN(
        CASE
            WHEN p.vigencia >= CURDATE() THEN p.vigencia
            ELSE NULL
        END
    ) AS proximo_vencimiento,
    CASE
        WHEN COUNT(p.clave_numerica) = 0 THEN 'SIN PERMISOS'
        WHEN SUM(
            CASE 
                WHEN p.vigencia >= CURDATE() THEN 1
                ELSE 0
            END
        ) = 0 THEN 'REQUIERE RENOVACION'
        WHEN MIN(
            CASE
                WHEN p.vigencia >= CURDATE() THEN p.vigencia
                ELSE NULL
            END
        ) <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
        THEN 'PROXIMO A VENCER'
        ELSE 'PERMISOS EN ORDEN'
    END AS estado_general
FROM cliente c
LEFT JOIN permiso p 
    ON p.cliente = c.numero
GROUP BY 
    c.numero,
    c.nombre,
    c.primer_apell,
    c.seg_apell
ORDER BY 
    estado_general,
    proximo_vencimiento;

SELECT * FROM permiso;

-- CONSULTA AVANZADA #2

SELECT
    tipo_permiso AS entidad_reguladora,
    YEAR(vigencia) AS anio,
    COUNT(*) AS total_permisos,
    MAX(
        CAST(
            SUBSTRING_INDEX(clave_numerica, '-', -1)
            AS UNSIGNED
        )
    ) AS ultimo_consecutivo,
    MAX(
        CAST(
            SUBSTRING_INDEX(clave_numerica, '-', -1)
            AS UNSIGNED
        )
    ) + 1 AS siguiente_consecutivo,
    CONCAT(
        'PERM-',
        tipo_permiso,
        '-',
        YEAR(vigencia),
        '-',
        LPAD(
            MAX(
                CAST(
                    SUBSTRING_INDEX(clave_numerica, '-', -1)
                    AS UNSIGNED
                )
            ) + 1,
            3,
            '0'
        )
    ) AS siguiente_folio
FROM permiso
GROUP BY
    tipo_permiso,
    YEAR(vigencia)
ORDER BY
    tipo_permiso,
    anio;

-- CONSULTA AVANZADA #3

SELECT
    oa.ID_operacion,
    pe.numero_pedimento,
    COUNT(DISTINCT pa.codigo) AS total_paquetes,
    COUNT(pr.codigo) AS total_productos,
    COALESCE(
        SUM(pr.valor_unitario * pr.cantidad),
        0
    ) AS valor_total,
    COALESCE(
        SUM(pr.valor_unitario * pr.cantidad) /
        NULLIF(COUNT(pr.codigo), 0),
        0
    ) AS valor_promedio_producto,
    COALESCE(
        SUM(pr.valor_unitario * pr.cantidad) /
        NULLIF(COUNT(DISTINCT pa.codigo), 0),
        0
    ) AS valor_promedio_paquete,
    CASE
        WHEN COALESCE(
            SUM(pr.valor_unitario * pr.cantidad),
            0
        ) = 0
            THEN 'SIN MERCANCIA'
        WHEN SUM(pr.valor_unitario * pr.cantidad) < 10000
            THEN 'VALOR BAJO'
        WHEN SUM(pr.valor_unitario * pr.cantidad) < 50000
            THEN 'VALOR MEDIO'
        ELSE 'VALOR ALTO'
    END AS clasificacion_valor
FROM operacion_aduanera oa
INNER JOIN pedimento pe
    ON pe.ope_aduanera = oa.ID_operacion
LEFT JOIN paquete pa
    ON pa.pedimento = pe.numero_pedimento
LEFT JOIN producto pr
    ON pr.paquete = pa.codigo
GROUP BY
    oa.ID_operacion,
    pe.numero_pedimento
ORDER BY
    valor_total DESC;