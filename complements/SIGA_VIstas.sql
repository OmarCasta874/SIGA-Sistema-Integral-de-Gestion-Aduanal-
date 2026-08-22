-- 1. Desglose completo de una operación aduanera
    -- Datos del cliente, RFC y estado de la operación
    -- Aduana y tipo de operación
    -- Pedimento asociado y su valor total
    -- Resultado del semáforo fiscal
    -- Pago y estado del pago

CREATE OR REPLACE VIEW v_desglose_operacion AS
SELECT
    oa.ID_operacion AS Operacion,
    oa.tipo_operacion AS TipoOperacion,
    oa.fecha_inicio AS FechaInicio,
    e.descripcion AS EstadoOperacion,
    c.numero AS CodigoCliente,
    CONCAT(c.nombre, ' ', c.primer_apell, ' ', IFNULL(c.seg_apell, '')) AS Cliente,
    c.RFC AS RFC,
    a.codigo AS CodigoAduana,
    a.nombre AS Aduana,
    p.numero_pedimento AS Pedimento,
    p.valor_total AS ValorPedimento,
    sf.resultado AS ResultadoSemaforo,
    pg.no_transaccion AS Transaccion,
    pg.monto AS MontoPago,
    ep.concepto AS EstadoPago
FROM operacion_aduanera oa
INNER JOIN cliente c ON c.numero = oa.cliente
INNER JOIN estado_opeaduanera e ON e.codigo = oa.estado_ope_aduanera
INNER JOIN aduana a ON a.codigo = oa.aduana
LEFT JOIN pedimento p ON p.ope_aduanera = oa.ID_operacion
LEFT JOIN semaforo_fiscal sf ON sf.ID = p.semaforo
LEFT JOIN pago pg ON pg.pedimento = p.numero_pedimento
LEFT JOIN estado_pago ep ON ep.codigo = pg.estado_pago;


-- 2. Mercancía registrada por cliente
    -- Total de paquetes por cliente
    -- Total de productos por cliente

CREATE OR REPLACE VIEW v_mercancia_cliente AS
SELECT
    pa.cliente,
    COUNT(DISTINCT pa.codigo) AS total_paquetes,
    COUNT(pr.codigo) AS total_productos
FROM paquete pa
LEFT JOIN producto pr ON pr.paquete = pa.codigo
GROUP BY pa.cliente;


-- 3. Vigencia de los permisos registrados
    -- Días restantes para el vencimiento
    -- Estatus del permiso (Vigente / Vencido)

CREATE OR REPLACE VIEW v_permisos_vigencia AS
SELECT
    clave_numerica,
    tipo_permiso,
    cliente,
    vigencia,
    DATEDIFF(vigencia, CURDATE()) AS dias_restantes,
    CASE WHEN vigencia < CURDATE() THEN 'Vencido' ELSE 'Vigente' END AS estatus
FROM permiso;