-- ================================================================
-- BASE DE DATOS: BaseDatosSIGA
-- Sistema Integral de Gestión Aduanal (SIGA)
-- ================================================================

DROP DATABASE IF EXISTS BaseDatosSIGA;
CREATE DATABASE BaseDatosSIGA
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_spanish_ci;
USE BaseDatosSIGA;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE cliente (
    numero       INT          NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(80)  NOT NULL,
    primer_apell VARCHAR(40)  NULL,
    seg_apell    VARCHAR(40)  NULL,
    tipo_persona VARCHAR(20)  NOT NULL,
    RFC          VARCHAR(13)  NOT NULL,
    curp         VARCHAR(18)  NULL,
    domicilio    VARCHAR(250) NULL,
    PRIMARY KEY (numero),
    UNIQUE KEY uq_cliente_rfc (RFC)
) ENGINE=InnoDB;

CREATE TABLE regimen_aduanero (
    num_regimen  INT          NOT NULL AUTO_INCREMENT,
    clave_oficial VARCHAR(10) NOT NULL,
    descripcion  VARCHAR(200) NOT NULL,
    PRIMARY KEY (num_regimen),
    UNIQUE KEY uq_regimen_clave (clave_oficial)
) ENGINE=InnoDB;

CREATE TABLE inspector_aduanero (
    matricula    VARCHAR(20) NOT NULL,
    no_gafete    VARCHAR(25) NOT NULL,
    nombre_pila  VARCHAR(40) NOT NULL,
    primer_apell VARCHAR(40) NOT NULL,
    seg_apell    VARCHAR(40) NULL,
    PRIMARY KEY (matricula),
    UNIQUE KEY uq_inspector_gafete (no_gafete)
) ENGINE=InnoDB;

CREATE TABLE tipo_exportaciones (
    tipo_exportacion INT         NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    descripcion      VARCHAR(200) NULL,
    PRIMARY KEY (tipo_exportacion)
) ENGINE=InnoDB;

CREATE TABLE tipo_importaciones (
    tipo_importacion INT         NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(50) NOT NULL,
    descripcion      VARCHAR(200) NULL,
    PRIMARY KEY (tipo_importacion)
) ENGINE=InnoDB;

CREATE TABLE aduana (
    codigo INT          NOT NULL AUTO_INCREMENT,
    ciudad VARCHAR(60)  NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (codigo)
) ENGINE=InnoDB;

CREATE TABLE bitacora (
    numero      INT          NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(250) NOT NULL,
    fecha       DATE         NOT NULL,
    hora        TIME         NOT NULL,
    PRIMARY KEY (numero)
) ENGINE=InnoDB;

CREATE TABLE semaforo_fiscal (
    ID       INT          NOT NULL AUTO_INCREMENT,
    hora     TIME         NOT NULL,
    resultado VARCHAR(100) NOT NULL,
    PRIMARY KEY (ID)
) ENGINE=InnoDB;

CREATE TABLE tipo_arancel (
    numero              INT         NOT NULL AUTO_INCREMENT,
    nombre              VARCHAR(50) NOT NULL,
    descripcion         VARCHAR(200) NULL,
    fecha_actualizacion DATE        NOT NULL,
    PRIMARY KEY (numero)
) ENGINE=InnoDB;

CREATE TABLE estado_pago (
    codigo      INT          NOT NULL AUTO_INCREMENT,
    concepto    VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NULL,
    PRIMARY KEY (codigo)
) ENGINE=InnoDB;

CREATE TABLE estado_opeaduanera (
    codigo      INT          NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(100) NOT NULL,
    PRIMARY KEY (codigo)
) ENGINE=InnoDB;

CREATE TABLE usuario (
    ID_usuario     INT          NOT NULL AUTO_INCREMENT,
    nombre_usuario VARCHAR(50) NOT NULL,
    nombre_pila    VARCHAR(40) NOT NULL,
    primer_apell   VARCHAR(40) NOT NULL,
    seg_apell      VARCHAR(40) NULL,
    fecha_alta     DATE        NOT NULL,
    correo         VARCHAR(80) NOT NULL,
    contrasena     VARCHAR(100) NOT NULL,
    last_login     DATETIME    NULL DEFAULT NULL,
    bitacora       INT         NOT NULL,
    PRIMARY KEY (ID_usuario),
    UNIQUE KEY uq_usuario_nombre (nombre_usuario),
    UNIQUE KEY uq_usuario_correo (correo),
    CONSTRAINT fk_usuario_bitacora FOREIGN KEY (bitacora) REFERENCES bitacora(numero)
) ENGINE=InnoDB;

CREATE TABLE telefono (
    numero      INT         NOT NULL AUTO_INCREMENT,
    numTelefono VARCHAR(20) NOT NULL,
    cliente     INT         NOT NULL,
    PRIMARY KEY (numero),
    CONSTRAINT fk_telefono_cliente FOREIGN KEY (cliente) REFERENCES cliente(numero)
) ENGINE=InnoDB;

CREATE TABLE correo_electronico (
    numero     INT         NOT NULL AUTO_INCREMENT,
    correoElec VARCHAR(80) NOT NULL,
    cliente    INT         NOT NULL,
    usuario    INT         NOT NULL,
    PRIMARY KEY (numero),
    CONSTRAINT fk_correo_cliente  FOREIGN KEY (cliente) REFERENCES cliente(numero),
    CONSTRAINT fk_correo_usuario  FOREIGN KEY (usuario) REFERENCES usuario(ID_usuario)
) ENGINE=InnoDB;

CREATE TABLE permiso (
    clave_numerica VARCHAR(30)  NOT NULL,
    tipo_permiso   VARCHAR(50)  NOT NULL,
    vigencia       DATE         NOT NULL,
    descripcion    VARCHAR(250) NULL,
    cliente        INT          NOT NULL,
    PRIMARY KEY (clave_numerica),
    CONSTRAINT fk_permiso_cliente FOREIGN KEY (cliente) REFERENCES cliente(numero)
) ENGINE=InnoDB;

CREATE TABLE tipo_permiso (
    id_tipo_permiso INT          NOT NULL AUTO_INCREMENT,
    tipo            VARCHAR(50)  NOT NULL,
    descripcion     VARCHAR(200) NULL,
    permiso         VARCHAR(30)  NOT NULL,
    PRIMARY KEY (id_tipo_permiso),
    CONSTRAINT fk_tipo_permiso_permiso FOREIGN KEY (permiso) REFERENCES permiso(clave_numerica)
) ENGINE=InnoDB;

CREATE TABLE inspeccion (
    numero           INT         NOT NULL AUTO_INCREMENT,
    fecha_inspeccion DATE        NOT NULL,
    hora_inicio      TIME        NOT NULL,
    resultado        VARCHAR(100) NULL,
    semaforo         INT         NOT NULL,
    PRIMARY KEY (numero),
    CONSTRAINT fk_inspeccion_semaforo FOREIGN KEY (semaforo) REFERENCES semaforo_fiscal(ID)
) ENGINE=InnoDB;

CREATE TABLE segunda_inspeccion (
    ID_revision      INT          NOT NULL AUTO_INCREMENT,
    fecha_inspeccion DATE         NOT NULL,
    hora_inicio      TIME         NOT NULL,
    resultado        VARCHAR(100) NULL,
    inspeccion       INT          NOT NULL,
    PRIMARY KEY (ID_revision),
    CONSTRAINT fk_segunda_inspeccion FOREIGN KEY (inspeccion) REFERENCES inspeccion(numero)
) ENGINE=InnoDB;

CREATE TABLE inspeccion_inspector (
    inspeccion    INT         NOT NULL,
    inspector_adu VARCHAR(20) NOT NULL,
    observaciones VARCHAR(250) NULL,
    PRIMARY KEY (inspeccion, inspector_adu),
    CONSTRAINT fk_ii_inspeccion FOREIGN KEY (inspeccion)    REFERENCES inspeccion(numero),
    CONSTRAINT fk_ii_inspector  FOREIGN KEY (inspector_adu) REFERENCES inspector_aduanero(matricula)
) ENGINE=InnoDB;

CREATE TABLE segunda_inspeccion_inspector (
    segunda_ins   INT         NOT NULL,
    inspector_adu VARCHAR(20) NOT NULL,
    observaciones VARCHAR(250) NULL,
    PRIMARY KEY (segunda_ins, inspector_adu),
    CONSTRAINT fk_sii_segunda   FOREIGN KEY (segunda_ins)   REFERENCES segunda_inspeccion(ID_revision),
    CONSTRAINT fk_sii_inspector FOREIGN KEY (inspector_adu) REFERENCES inspector_aduanero(matricula)
) ENGINE=InnoDB;

CREATE TABLE incidencia (
    codigo      INT          NOT NULL AUTO_INCREMENT,
    gravedad    VARCHAR(30)  NOT NULL,
    descripcion VARCHAR(250) NOT NULL,
    inspeccion  INT          NOT NULL,
    PRIMARY KEY (codigo),
    CONSTRAINT fk_incidencia_inspeccion FOREIGN KEY (inspeccion) REFERENCES inspeccion(numero)
) ENGINE=InnoDB;

CREATE TABLE sancion (
    num_sancion     INT          NOT NULL AUTO_INCREMENT,
    monto_multa     DECIMAL(12,2) NOT NULL,
    fundamento_legal VARCHAR(250) NOT NULL,
    incidencia      INT          NOT NULL,
    PRIMARY KEY (num_sancion),
    CONSTRAINT fk_sancion_incidencia FOREIGN KEY (incidencia) REFERENCES incidencia(codigo)
) ENGINE=InnoDB;

CREATE TABLE operacion_aduanera (
    ID_operacion       INT         NOT NULL AUTO_INCREMENT,
    fecha_inicio       DATE        NOT NULL,
    fecha_final        DATE        NULL,
    tipo_operacion     VARCHAR(20) NOT NULL,
    estado_ope_aduanera INT        NOT NULL,
    cliente            INT         NOT NULL,
    usuario            INT         NOT NULL,
    bitacora           INT         NOT NULL,
    aduana             INT         NOT NULL,
    PRIMARY KEY (ID_operacion),
    CONSTRAINT fk_oa_estado   FOREIGN KEY (estado_ope_aduanera) REFERENCES estado_opeaduanera(codigo),
    CONSTRAINT fk_oa_cliente  FOREIGN KEY (cliente)  REFERENCES cliente(numero),
    CONSTRAINT fk_oa_usuario  FOREIGN KEY (usuario)  REFERENCES usuario(ID_usuario),
    CONSTRAINT fk_oa_bitacora FOREIGN KEY (bitacora) REFERENCES bitacora(numero),
    CONSTRAINT fk_oa_aduana   FOREIGN KEY (aduana)   REFERENCES aduana(codigo)
) ENGINE=InnoDB;

CREATE TABLE pedimento (
    numero_pedimento VARCHAR(30)   NOT NULL,
    clave_pedimento  VARCHAR(10)   NOT NULL,
    fecha_registro   DATE          NOT NULL,
    valor_total      DECIMAL(12,2) NOT NULL,
    semaforo         INT           NULL,
    regimen_adu      INT           NOT NULL,
    permiso          VARCHAR(30)   NOT NULL,
    ope_aduanera     INT           NOT NULL,
    tipo_exportacion INT           NULL,
    tipo_importacion INT           NULL,
    PRIMARY KEY (numero_pedimento),
    CONSTRAINT fk_ped_semaforo  FOREIGN KEY (semaforo)         REFERENCES semaforo_fiscal(ID),
    CONSTRAINT fk_ped_regimen   FOREIGN KEY (regimen_adu)      REFERENCES regimen_aduanero(num_regimen),
    CONSTRAINT fk_ped_permiso   FOREIGN KEY (permiso)          REFERENCES permiso(clave_numerica),
    CONSTRAINT fk_ped_operacion FOREIGN KEY (ope_aduanera)     REFERENCES operacion_aduanera(ID_operacion),
    CONSTRAINT fk_ped_tipo_exp  FOREIGN KEY (tipo_exportacion) REFERENCES tipo_exportaciones(tipo_exportacion),
    CONSTRAINT fk_ped_tipo_imp  FOREIGN KEY (tipo_importacion) REFERENCES tipo_importaciones(tipo_importacion)
) ENGINE=InnoDB;

CREATE TABLE categoria_productos (
    numero                 INT          NOT NULL AUTO_INCREMENT,
    nombre                 VARCHAR(50)  NOT NULL,
    descripcion            VARCHAR(200) NULL,
    IGI                    DECIMAL(5,2) NOT NULL DEFAULT 0
        COMMENT 'Tasa del Impuesto General de Importación aplicable a esta categoría.',
    tipo_arancel           INT          NOT NULL,
    tipo_permiso_requerido VARCHAR(50)  NULL DEFAULT NULL
        COMMENT 'Tipo de permiso requerido para comercializar esta categoría. NULL = categoría libre.',
    PRIMARY KEY (numero),
    CONSTRAINT fk_categoria_tipo_arancel FOREIGN KEY (tipo_arancel) REFERENCES tipo_arancel(numero)
) ENGINE=InnoDB;

CREATE TABLE arancel (
    numero       INT           NOT NULL AUTO_INCREMENT,
    subtotal     DECIMAL(12,2) NOT NULL,
    descripcion  VARCHAR(200)  NULL,
    IGI          DECIMAL(5,2)  NOT NULL,
    tasa_interes DECIMAL(5,2)  NOT NULL,
    Tipo_Arancel INT           NOT NULL,
    pedimento    VARCHAR(30)   NOT NULL,
    categoria    INT           NOT NULL,
    PRIMARY KEY (numero),
    CONSTRAINT fk_arancel_tipo      FOREIGN KEY (Tipo_Arancel) REFERENCES tipo_arancel(numero),
    CONSTRAINT fk_arancel_pedimento FOREIGN KEY (pedimento)    REFERENCES pedimento(numero_pedimento),
    CONSTRAINT fk_arancel_categoria FOREIGN KEY (categoria)    REFERENCES categoria_productos(numero)
) ENGINE=InnoDB;

CREATE TABLE tipo_embalaje (
    id          INT           NOT NULL AUTO_INCREMENT,
    nombre      VARCHAR(50)   NOT NULL,
    peso_maximo DECIMAL(10,2) NOT NULL COMMENT 'Peso máximo permitido en kg',
    descripcion VARCHAR(200)  NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tipo_embalaje_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE paquete (
    codigo           INT           NOT NULL AUTO_INCREMENT,
    peso             DECIMAL(10,2) NOT NULL,
    tipo_embalaje_id INT           NOT NULL,
    dimensiones      VARCHAR(50)   NULL,
    cliente          INT           NOT NULL,
    pedimento        VARCHAR(30)   NULL,
    PRIMARY KEY (codigo),
    CONSTRAINT fk_paquete_cliente   FOREIGN KEY (cliente)          REFERENCES cliente(numero),
    CONSTRAINT fk_paquete_pedimento FOREIGN KEY (pedimento)        REFERENCES pedimento(numero_pedimento),
    CONSTRAINT fk_paquete_embalaje  FOREIGN KEY (tipo_embalaje_id) REFERENCES tipo_embalaje(id)
) ENGINE=InnoDB;

CREATE TABLE producto (
    codigo        INT           NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(100)  NOT NULL,
    descripcion   VARCHAR(200)  NULL,
    peso          DECIMAL(10,2) NOT NULL,
    valor_unitario DECIMAL(12,2) NOT NULL,
    cantidad      INT           NOT NULL DEFAULT 1,
    paquete       INT           NOT NULL,
    PRIMARY KEY (codigo),
    CONSTRAINT fk_producto_paquete FOREIGN KEY (paquete) REFERENCES paquete(codigo)
) ENGINE=InnoDB;

CREATE TABLE categorias_productos_rel (
    id         INT NOT NULL AUTO_INCREMENT,
    categorias INT NOT NULL,
    productos  INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_cat_prod (categorias, productos),
    CONSTRAINT fk_cpr_categoria FOREIGN KEY (categorias) REFERENCES categoria_productos(numero),
    CONSTRAINT fk_cpr_producto  FOREIGN KEY (productos)  REFERENCES producto(codigo)
) ENGINE=InnoDB;

CREATE TABLE categoria_embalaje (
    id               INT NOT NULL AUTO_INCREMENT,
    categoria_id     INT NOT NULL,
    tipo_embalaje_id INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_cat_emb (categoria_id, tipo_embalaje_id),
    CONSTRAINT fk_catemb_categoria  FOREIGN KEY (categoria_id)     REFERENCES categoria_productos(numero),
    CONSTRAINT fk_catemb_embalaje   FOREIGN KEY (tipo_embalaje_id) REFERENCES tipo_embalaje(id)
) ENGINE=InnoDB;

CREATE TABLE factura (
    codigo       INT           NOT NULL AUTO_INCREMENT,
    IVA          DECIMAL(12,2) NOT NULL,
    subtotal     DECIMAL(12,2) NOT NULL,
    total        DECIMAL(12,2) NOT NULL,
    folio_fiscal VARCHAR(50)   NOT NULL,
    fecha_factura DATE          NOT NULL,
    ID_operacion INT           NOT NULL,
    PRIMARY KEY (codigo),
    UNIQUE KEY uq_factura_folio (folio_fiscal),
    CONSTRAINT fk_factura_operacion FOREIGN KEY (ID_operacion) REFERENCES operacion_aduanera(ID_operacion)
) ENGINE=InnoDB;

CREATE TABLE pago (
    no_transaccion VARCHAR(50)   NOT NULL,
    numero_pago    INT           NOT NULL,
    concepto       VARCHAR(100)  NOT NULL,
    saldo_final    DECIMAL(12,2) NOT NULL,
    monto          DECIMAL(12,2) NOT NULL,
    fecha_pago     DATE          NOT NULL,
    pedimento      VARCHAR(30)   NULL,
    estado_pago    INT           NOT NULL,
    PRIMARY KEY (no_transaccion),
    CONSTRAINT fk_pago_pedimento   FOREIGN KEY (pedimento)   REFERENCES pedimento(numero_pedimento),
    CONSTRAINT fk_pago_estado_pago FOREIGN KEY (estado_pago) REFERENCES estado_pago(codigo)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- Complemento: columna de inspección en paquete
-- ================================================================
ALTER TABLE paquete
ADD COLUMN IF NOT EXISTS inspeccion INT NULL,
ADD CONSTRAINT fk_paquete_inspeccion FOREIGN KEY (inspeccion) REFERENCES inspeccion(numero);

-- ================================================================
-- Complemento: atributos faltantes en pedimento
-- Justificación: el pedimento aduanal real exige declarar el medio
-- de transporte, país de origen/destino, término de comercio e
-- tipo de cambio vigente al momento del despacho.
-- ================================================================
ALTER TABLE pedimento
  ADD COLUMN IF NOT EXISTS medio_transporte      VARCHAR(20)    NULL COMMENT 'Aéreo, Marítimo, Terrestre, Ferroviario',
  ADD COLUMN IF NOT EXISTS pais_origen_mercancia VARCHAR(60)    NULL COMMENT 'País de procedencia de las mercancías',
  ADD COLUMN IF NOT EXISTS pais_destino          VARCHAR(60)    NULL COMMENT 'País de destino (aplica en exportaciones)',
  ADD COLUMN IF NOT EXISTS incoterm              VARCHAR(10)    NULL COMMENT 'Término de comercio: FOB, CIF, EXW, DDP, etc.',
  ADD COLUMN IF NOT EXISTS tipo_cambio           DECIMAL(10,4)  NULL COMMENT 'Tipo de cambio USD/MXN vigente al despacho';

-- ================================================================
-- Complemento: fracción arancelaria TIGIE en categoría de productos
-- Justificación (problemática del proyecto): la clasificación
-- arancelaria errónea es uno de los tres problemas centrales de SIGA.
-- Cada categoría de productos debe estar identificada con su código
-- TIGIE de 10 dígitos (8 fracción arancelaria + 2 NICO) para
-- determinar aranceles, regulaciones y restricciones correctamente.
-- ================================================================
ALTER TABLE categoria_productos
  ADD COLUMN IF NOT EXISTS fraccion_arancelaria CHAR(10) NULL
    COMMENT 'Código TIGIE: 8 dígitos fracción arancelaria + 2 NICO. Ej: 8516500100';

-- Fracciones TIGIE por categoría (Sistema Armonizado + LIGIE + NICO)
UPDATE categoria_productos SET fraccion_arancelaria = '8516500100' WHERE numero = 1;  -- Electrodomésticos      (aparatos electrotérmicos)
UPDATE categoria_productos SET fraccion_arancelaria = '5208110100' WHERE numero = 2;  -- Textiles               (telas de algodón)
UPDATE categoria_productos SET fraccion_arancelaria = '3901100100' WHERE numero = 3;  -- Insumos Industriales   (polietileno gránulo)
UPDATE categoria_productos SET fraccion_arancelaria = '6401100100' WHERE numero = 4;  -- Calzado                (calzado impermeable)
UPDATE categoria_productos SET fraccion_arancelaria = '8457100100' WHERE numero = 5;  -- Maquinaria             (centros de mecanizado)
UPDATE categoria_productos SET fraccion_arancelaria = '8542310100' WHERE numero = 6;  -- Componentes Elect.     (circuitos integrados)
UPDATE categoria_productos SET fraccion_arancelaria = '2208300100' WHERE numero = 7;  -- Bebidas Alcohólicas    (whisky)
UPDATE categoria_productos SET fraccion_arancelaria = '7301200100' WHERE numero = 8;  -- Acero y Metales        (perfiles de acero)
UPDATE categoria_productos SET fraccion_arancelaria = '0709990100' WHERE numero = 9;  -- Productos Agropecuarios(hortalizas frescas)
UPDATE categoria_productos SET fraccion_arancelaria = '8703230100' WHERE numero = 10; -- Vehículos              (automóviles gasolina)
UPDATE categoria_productos SET fraccion_arancelaria = '3004900100' WHERE numero = 11; -- Productos Farmacéuticos(medicamentos)
UPDATE categoria_productos SET fraccion_arancelaria = '1602500100' WHERE numero = 12; -- Alimentos Procesados   (conservas de carne)
UPDATE categoria_productos SET fraccion_arancelaria = '2901100100' WHERE numero = 13; -- Químicos Industriales  (hidrocarburos acíclicos)
UPDATE categoria_productos SET fraccion_arancelaria = '8544420100' WHERE numero = 14; -- Material Eléctrico     (cables conductores)
UPDATE categoria_productos SET fraccion_arancelaria = '3920100100' WHERE numero = 15; -- Plásticos y Hules      (placas de polímeros)
UPDATE categoria_productos SET fraccion_arancelaria = '3303000100' WHERE numero = 16; -- Cosméticos y Perfumería(perfumes)
UPDATE categoria_productos SET fraccion_arancelaria = '2106900100' WHERE numero = 17; -- Suplementos Aliment.   (preparaciones alimenticias)
UPDATE categoria_productos SET fraccion_arancelaria = '9018190100' WHERE numero = 18; -- Equipos Médicos        (instrumentos médicos)
UPDATE categoria_productos SET fraccion_arancelaria = '9301900100' WHERE numero = 19; -- Material Bélico        (armas militares)
UPDATE categoria_productos SET fraccion_arancelaria = '9005800100' WHERE numero = 20; -- Equipo Óptico y Visión (binoculares)
UPDATE categoria_productos SET fraccion_arancelaria = '0101290100' WHERE numero = 21; -- Animales Vivos         (animales vivos)
UPDATE categoria_productos SET fraccion_arancelaria = '1001190100' WHERE numero = 22; -- Semillas y Granos      (trigo)
UPDATE categoria_productos SET fraccion_arancelaria = '9503000100' WHERE numero = 23; -- Juguetes y Art. Infant.(juguetes)
UPDATE categoria_productos SET fraccion_arancelaria = '5911900100' WHERE numero = 24; -- Textiles Técnicos      (textiles para uso técnico)
UPDATE categoria_productos SET fraccion_arancelaria = '3105200100' WHERE numero = 25; -- Fertilizantes/Agroquím.(fertilizantes minerales)
UPDATE categoria_productos SET fraccion_arancelaria = '2710120100' WHERE numero = 26; -- Combustibles y Lubric. (aceites de petróleo)
UPDATE categoria_productos SET fraccion_arancelaria = '4407100100' WHERE numero = 27; -- Madera y Prod. Forestales(madera aserrada)
UPDATE categoria_productos SET fraccion_arancelaria = '4804110100' WHERE numero = 28; -- Papel y Cartón         (papel kraft)
UPDATE categoria_productos SET fraccion_arancelaria = '9202900100' WHERE numero = 29; -- Instrumentos Musicales (instrumentos de cuerda)
UPDATE categoria_productos SET fraccion_arancelaria = '9506990100' WHERE numero = 30; -- Artículos Deportivos   (artículos deportivos)

-- cliente
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (1, 'Carlos', 'Martínez', 'López', 'Física', 'MALC850312HBC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (2, 'María', 'Rodríguez', 'Torres', 'Física', 'ROTM900615MDF');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (3, 'Importaciones del Norte SA de CV', NULL, NULL, 'Moral', 'INSA010101ABC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (4, 'José', 'Hernández', 'Ramírez', 'Física', 'HERJ780923HBC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (5, 'Logística Fronteriza SA de CV', NULL, NULL, 'Moral', 'LFSA150601XYZ');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (6, 'Ana', 'García', 'Soto', 'Física', 'GASA950204MBC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (7, 'Comercializadora Pacífico SC', NULL, NULL, 'Moral', 'CPSC200305DEF');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (8, 'Luis', 'Pérez', 'Méndez', 'Física', 'PEML820717HBC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (9, 'Grupo Aduanal del Sur SA', NULL, NULL, 'Moral', 'GASA110808GHI');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (10, 'Rosa', 'Fuentes', 'Castillo', 'Física', 'FUCR930930MBC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (11, 'José María', 'Ochoa', 'Velasco', 'Física', 'OCVJ980418HBC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (12, 'Arturo', 'Vallado', 'Ruiz', 'Física', 'VARA850204MDF');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (13, 'Aduanas Océano Pacífico', NULL, NULL, 'Moral', 'AOPA070601ABC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (14, 'Miguel', 'Salas', 'Echeverría', 'Física', 'SAEM950521HBC');
INSERT INTO cliente (numero, nombre, primer_apell, seg_apell, tipo_persona, RFC) VALUES (15, 'Industrias Alba Nueva & Asociados', NULL, NULL, 'Moral', 'IANA150609XYZ');

-- regimen_aduanero
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (1, 'IMP-DEF', 'Importación definitiva de mercancías al territorio nacional.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (2, 'EXP-DEF', 'Exportación definitiva de mercancías fuera del territorio nacional.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (3, 'IMP-TMP', 'Importación temporal para retorno en el mismo estado.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (4, 'EXP-TMP', 'Exportación temporal para reimportación posterior.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (5, 'IMMEX', 'Importación temporal para elaboración, transformación o reparación.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (6, 'DEPOSITO', 'Depósito fiscal en almacén general autorizado.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (7, 'TRANSITO', 'Tránsito de mercancías por territorio nacional.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (8, 'RECINTO', 'Recinto fiscalizado estratégico para manufactura.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (9, 'RETORNO', 'Retorno de mercancías exportadas temporalmente.');
INSERT INTO regimen_aduanero (num_regimen, clave_oficial, descripcion) VALUES (10, 'DRAWBACK', 'Devolución de aranceles por reexportación de insumos.');

-- inspector_aduanero
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-001', 'GAF-2024-0001', 'Jorge', 'Alvarado', 'Mendoza');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-002', 'GAF-2024-0002', 'Verónica', 'Soto', 'Ruiz');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-003', 'GAF-2024-0003', 'Ricardo', 'Montes', 'Aguilar');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-004', 'GAF-2024-0004', 'Diana', 'Serrano', 'Castro');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-005', 'GAF-2024-0005', 'Ernesto', 'Flores', 'Paredes');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-006', 'GAF-2024-0006', 'Carmen', 'Reyes', 'Molina');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-007', 'GAF-2024-0007', 'Alberto', 'Navarro', 'Guzmán');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-008', 'GAF-2024-0008', 'Mónica', 'Delgado', 'Herrera');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-009', 'GAF-2024-0009', 'Óscar', 'Vázquez', 'Rojas');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-010', 'GAF-2024-0010', 'Irene', 'Cortés', 'Medina');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-011', 'GAF-2024-0011', 'Bernardo', 'Cabrera', 'Valdez');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-012', 'GAF-2024-0012', 'Daniela', 'Álvarez', 'Soler');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-013', 'GAF-2024-0013', 'Ignacio', 'Gaytán', 'Torres');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-014', 'GAF-2024-0014', 'Efraín', 'Ruiz', 'Lombardo');
INSERT INTO inspector_aduanero (matricula, no_gafete, nombre_pila, primer_apell, seg_apell) VALUES ('INS-015', 'GAF-2024-0015', 'Leonardo', 'Osorio', 'Padilla');

-- tipo_exportaciones
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (1, 'Exportación Definitiva', 'Salida permanente de mercancías del territorio nacional.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (2, 'Exportación Temporal', 'Salida temporal con compromiso de retorno al país.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (3, 'Exportación IMMEX', 'Exportación de productos manufacturados bajo programa IMMEX.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (4, 'Exportación Agropecuaria', 'Exportación de productos del sector agropecuario.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (5, 'Exportación de Servicios', 'Prestación de servicios a residentes en el extranjero.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (6, 'Drawback', 'Reexportación con devolución de aranceles pagados.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (7, 'Exportación Urgente', 'Exportación de mercancías perecederas o de urgencia.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (8, 'Exportación Fronteriza', 'Exportación exclusiva para zonas fronterizas autorizadas.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (9, 'Exportación Maquiladora', 'Exportación de productos terminados de maquiladora.');
INSERT INTO tipo_exportaciones (tipo_exportacion, nombre, descripcion) VALUES (10, 'Exportación de Muestras', 'Exportación de muestras comerciales sin valor comercial.');

-- tipo_importaciones
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (1, 'Importación Definitiva', 'Ingreso permanente de mercancías al territorio nacional.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (2, 'Importación Temporal', 'Ingreso temporal con compromiso de retorno al extranjero.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (3, 'Importación IMMEX', 'Importación de insumos para producción bajo IMMEX.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (4, 'Importación Agropecuaria', 'Importación de productos del sector agropecuario.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (5, 'Importación de Urgencia', 'Importación de mercancías de primera necesidad.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (6, 'Importación Franquicia', 'Importación libre de arancel bajo convenio de franquicia.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (7, 'Importación Fronteriza', 'Importación exclusiva para franja y región fronteriza.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (8, 'Importación de Muestras', 'Importación de muestras comerciales sin valor comercial.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (9, 'Importación Exenta', 'Importación libre de aranceles por disposición legal.');
INSERT INTO tipo_importaciones (tipo_importacion, nombre, descripcion) VALUES (10, 'Importación de Uso Propio', 'Importación de bienes para uso personal del importador.');

-- aduana
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (1, 'Tijuana', 'Aduana de Tijuana');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (2, 'Ciudad Juárez', 'Aduana de Ciudad Juárez');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (3, 'Nuevo Laredo', 'Aduana de Nuevo Laredo');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (4, 'Manzanillo', 'Aduana de Manzanillo');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (5, 'Veracruz', 'Aduana de Veracruz');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (6, 'Lázaro Cárdenas', 'Aduana de Lázaro Cárdenas');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (7, 'Monterrey', 'Aduana de Monterrey (Aeropuerto)');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (8, 'Ciudad de México', 'Aduana del Aeropuerto Internacional AICM');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (9, 'Nogales', 'Aduana de Nogales');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (10, 'Matamoros', 'Aduana de Matamoros');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (11, 'San Luis Potosí', 'Aduana de San Luis Potosí');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (12, 'Sonora', 'Aduana de Sonora');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (13, 'Culiacán', 'Aduana de Culiacán');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (14, 'Puebla', 'Aduana de Puebla');
INSERT INTO aduana (codigo, ciudad, nombre) VALUES (15, 'La Paz', 'Aduana de La Paz');

-- bitacora
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (1, 'Inicio de sesión del usuario admin01 en el sistema.', '2024-01-10', '08:02:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (2, 'Registro de nueva operación aduanera OA-2024-001.', '2024-01-10', '08:15:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (3, 'Consulta del pedimento PED-2024-00001 por usuario oper01.', '2024-01-11', '09:30:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (4, 'Actualización de datos del cliente ID 3.', '2024-01-12', '10:45:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (5, 'Cierre de operación aduanera OA-2024-002.', '2024-01-13', '14:00:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (6, 'Generación de factura F-2024-0001 vinculada a operación OA-2024-001.', '2024-01-14', '11:20:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (7, 'Registro de pago transacción TXN-2024-0001.', '2024-01-15', '12:35:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (8, 'Inicio de sesión del usuario oper02 en el sistema.', '2024-01-16', '08:05:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (9, 'Modificación del semáforo fiscal ID 4.', '2024-01-17', '13:10:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (10, 'Cierre de sesión del usuario admin01.', '2024-01-17', '18:00:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (11, 'Registro de nueva operación aduanera OA-2024-003.', '2024-02-11', '09:10:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (12, 'Consulta del pedimento PED-2024-00003 por usuario oper05.', '2024-02-12', '10:25:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (13, 'Actualización de permiso PER-2024-003 por vencimiento próximo.', '2024-02-13', '11:40:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (14, 'Generación de factura F-2024-0004 vinculada a operación OA-2024-004.', '2024-02-14', '14:55:00');
INSERT INTO bitacora (numero, descripcion, fecha, hora) VALUES (15, 'Cierre de sesión del usuario oper03 tras revisión de expedientes.', '2024-02-15', '17:30:00');

-- semaforo_fiscal
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (1, '08:14:00', 'Verde – Despacho libre sin revisión física.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (2, '09:32:00', 'Rojo – Inspección física requerida.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (3, '10:05:00', 'Verde – Despacho libre sin revisión física.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (4, '11:20:00', 'Rojo – Inspección documental requerida.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (5, '12:47:00', 'Verde – Despacho libre sin revisión física.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (6, '13:58:00', 'Rojo – Inspección física requerida.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (7, '14:30:00', 'Verde – Despacho libre sin revisión física.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (8, '15:10:00', 'Rojo – Inspección física y documental requerida.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (9, '16:22:00', 'Verde – Despacho libre sin revisión física.');
INSERT INTO semaforo_fiscal (ID, hora, resultado) VALUES (10, '17:05:00', 'Rojo – Inspección documental requerida.');

-- tipo_arancel
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (1, 'Ad Valorem', 'Arancel calculado como porcentaje sobre el valor de la mercancía.', '2024-01-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (2, 'Específico', 'Arancel de cantidad fija por unidad de medida de la mercancía.', '2024-01-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (3, 'Mixto', 'Combinación de arancel Ad Valorem y Específico.', '2024-01-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (4, 'Arancel-Cupo', 'Tasa preferencial aplicable hasta cierto volumen de importación.', '2024-01-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (5, 'Arancel-Estacional', 'Tasa variable según la temporada del año para productos agropecuarios.', '2024-01-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (6, 'Cuota Compensatoria', 'Medida de defensa comercial por dumping o subsidio extranjero.', '2023-07-15');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (7, 'Arancel Preferencial TLC', 'Tasa reducida aplicable a mercancías bajo tratado comercial.', '2024-01-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (8, 'Arancel Cero', 'Exención total de arancel por acuerdo o disposición legal.', '2024-01-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (9, 'Arancel SGP', 'Tasa del Sistema Generalizado de Preferencias arancelarias.', '2023-10-01');
INSERT INTO tipo_arancel (numero, nombre, descripcion, fecha_actualizacion) VALUES (10, 'Arancel Anti-dumping', 'Arancel adicional para contrarrestar precios de dumping.', '2023-12-01');

-- estado_pago
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (1, 'Pagado', 'El monto ha sido liquidado en su totalidad.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (2, 'Pendiente', 'El pago aún no ha sido realizado.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (3, 'Parcial', 'Se ha realizado un pago parcial del adeudo.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (4, 'Vencido', 'El plazo de pago ha expirado sin liquidarse.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (5, 'Cancelado', 'El pago fue anulado por el sistema o el usuario.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (6, 'En revisión', 'El pago está siendo verificado por el área contable.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (7, 'Rechazado', 'El pago fue rechazado por la institución financiera.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (8, 'En proceso', 'El pago está siendo procesado por la institución financiera.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (9, 'Reembolsado', 'El monto fue devuelto al cliente por error o cancelación.');
INSERT INTO estado_pago (codigo, concepto, descripcion) VALUES (10, 'Exento', 'La operación quedó exenta del cobro correspondiente.');

-- estado_opeaduanera
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (1, 'En proceso');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (2, 'Completada');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (3, 'Cancelada');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (4, 'Pendiente de pago');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (5, 'En revisión');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (6, 'Retenida');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (7, 'En despacho');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (8, 'Cerrada');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (9, 'Anulada');
INSERT INTO estado_opeaduanera (codigo, descripcion) VALUES (10, 'En espera de documentos');

-- usuario
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (1, 'admin01', 'Roberto', 'Salinas', 'Cruz', '2023-01-15', 'rsalinas@siga.mx', '$2b$12$hQp1K...encriptado', 1);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (2, 'oper01', 'Laura', 'Vega', 'Ríos', '2023-02-20', 'lvega@siga.mx', '$2b$12$mNr2L...encriptado', 3);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (3, 'oper02', 'Miguel', 'Domínguez', 'Ponce', '2023-03-10', 'mdominguez@siga.mx', '$2b$12$kJt3P...encriptado', 8);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (4, 'super01', 'Claudia', 'Ibáñez', 'Mora', '2023-04-05', 'cibanez@siga.mx', '$2b$12$xWq4R...encriptado', 2);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (5, 'oper03', 'Andrés', 'Núñez', 'Lara', '2023-05-18', 'anunez@siga.mx', '$2b$12$yUo5S...encriptado', 5);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (6, 'oper04', 'Sofía', 'Cabrera', 'Jiménez', '2023-06-22', 'scabrera@siga.mx', '$2b$12$zVp6T...encriptado', 6);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (7, 'admin02', 'Fernando', 'Ríos', 'Peña', '2023-07-30', 'frios@siga.mx', '$2b$12$aQr7U...encriptado', 9);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (8, 'oper05', 'Gabriela', 'Mora', 'Suárez', '2023-08-14', 'gmora@siga.mx', '$2b$12$bSs8V...encriptado', 7);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (9, 'oper06', 'Héctor', 'Luna', 'Vargas', '2023-09-01', 'hluna@siga.mx', '$2b$12$cTt9W...encriptado', 4);
INSERT INTO usuario (ID_usuario, nombre_usuario, nombre_pila, primer_apell, seg_apell, fecha_alta, correo, contrasena, bitacora) VALUES (10, 'audit01', 'Patricia', 'Campos', 'Ortiz', '2023-10-11', 'pcampos@siga.mx', '$2b$12$dUu0X...encriptado', 10);

-- telefono
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (1, '6641234567', 1);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (2, '6649876543', 1);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (3, '6562345678', 2);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (4, '6641112233', 3);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (5, '8183334455', 4);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (6, '6645556677', 5);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (7, '6647778899', 6);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (8, '3318889900', 7);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (9, '6640001122', 8);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (10, '6643334455', 9);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (11, '6646667788', 10);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (12, '8182223344', 4);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (13, '6648889900', 7);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (14, '5561112233', 3);
INSERT INTO telefono (numero, numTelefono, cliente) VALUES (15, '6643335566', 6);

-- correo_electronico
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (1, 'cmartinez@correo.mx', 1, 2);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (2, 'mrodriguez@correo.mx', 2, 3);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (3, 'contacto@importnorte.mx', 3, 4);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (4, 'jhernandez@correo.mx', 4, 5);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (5, 'info@logisticafronteriza.mx', 5, 6);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (6, 'agarcia@correo.mx', 6, 7);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (7, 'ventas@comercpacif.mx', 7, 8);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (8, 'lperez@correo.mx', 8, 9);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (9, 'contacto@grupoaduanal.mx', 9, 10);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (10, 'rfuentes@correo.mx', 10, 1);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (11, 'rfuentes@gmail.com', 10, 3);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (12, 'jhernandez@outlook.com', 4, 5);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (13, 'ventas2@comerpacif.mx', 7, 8);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (14, 'contacto2@importnorte.mx', 3, 4);
INSERT INTO correo_electronico (numero, correoElec, cliente, usuario) VALUES (15, 'agarcia2@correo.mx', 6, 7);

-- permiso
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-COFEPRIS-2024-001', 'COFEPRIS', '2028-01-31', 'Permiso sanitario para importación de alimentos procesados.', 1);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-SADER-2024-001', 'SADER', '2028-03-15', 'Autorización fitosanitaria para importación de productos agrícolas.', 2);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-SEDENA-2024-001', 'SEDENA', '2028-12-31', 'Permiso para importación de materiales de uso restringido.', 3);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-SE-2024-001', 'SE', '2028-06-30', 'Permiso de importación de textiles con cupo arancelario.', 4);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-COFEPRIS-2024-002', 'COFEPRIS', '2028-02-28', 'Permiso para importación de dispositivos médicos.', 5);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-SADER-2024-002', 'SADER', '2028-04-20', 'Autorización zoosanitaria para importación de animales.', 6);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-SE-2024-002', 'SE', '2028-09-30', 'Permiso de exportación de productos siderúrgicos.', 7);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-COFEPRIS-2024-003', 'COFEPRIS', '2028-07-15', 'Permiso para exportación de productos farmacéuticos.', 8);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-SEDENA-2024-002', 'SEDENA', '2028-01-15', 'Autorización para exportación de material óptico.', 9);
INSERT INTO permiso (clave_numerica, tipo_permiso, vigencia, descripcion, cliente) VALUES ('PERM-SE-2024-003', 'SE', '2028-11-30', 'Permiso de importación de maquinaria industrial.', 10);

-- tipo_permiso
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (1, 'COFEPRIS', 'Control sanitario de alimentos, medicamentos y dispositivos médicos.', 'PERM-COFEPRIS-2024-001');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (2, 'SADER', 'Autorización fitosanitaria y zoosanitaria del sector agropecuario.', 'PERM-SADER-2024-001');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (3, 'SEDENA', 'Control de materiales de uso exclusivo del ejército y restringido.', 'PERM-SEDENA-2024-001');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (4, 'SE', 'Administración de cupos y permisos de comercio exterior.', 'PERM-SE-2024-001');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (5, 'COFEPRIS', 'Regulación de dispositivos médicos y equipos de salud.', 'PERM-COFEPRIS-2024-002');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (6, 'SADER', 'Autorización zoosanitaria para importación de animales vivos.', 'PERM-SADER-2024-002');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (7, 'SE', 'Permiso de exportación de acero y productos siderúrgicos.', 'PERM-SE-2024-002');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (8, 'COFEPRIS', 'Regulación de exportación de productos farmacéuticos controlados.', 'PERM-COFEPRIS-2024-003');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (9, 'SEDENA', 'Autorización de exportación de óptica y equipo de visión.', 'PERM-SEDENA-2024-002');
INSERT INTO tipo_permiso (id_tipo_permiso, tipo, descripcion, permiso) VALUES (10, 'SE', 'Permiso de importación de maquinaria bajo cupo arancelario.', 'PERM-SE-2024-003');

-- inspeccion
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (1, '2024-01-10', '09:00:00', 'Sin irregularidades', 2);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (2, '2024-01-13', '10:15:00', 'Documentación incompleta', 4);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (3, '2024-01-18', '11:30:00', 'Sin irregularidades', 6);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (4, '2024-01-22', '08:45:00', 'Irregularidad en etiquetado', 8);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (5, '2024-01-25', '13:00:00', 'Sin irregularidades', 2);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (6, '2024-01-28', '14:20:00', 'Exceso de peso declarado', 4);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (7, '2024-02-01', '09:50:00', 'Sin irregularidades', 6);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (8, '2024-02-05', '10:40:00', 'Mercancía no declarada detectada', 8);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (9, '2024-02-08', '12:10:00', 'Sin irregularidades', 2);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (10, '2024-02-12', '15:30:00', 'Discrepancia en valor declarado', 4);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (11, '2024-01-10', '09:30:00', 'Sin irregularidades', 6);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (12, '2024-01-13', '10:50:00', 'Exceso de peso declarado', 8);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (13, '2024-01-18', '11:15:00', 'Sin irregularidades', 2);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (14, '2024-01-22', '09:10:00', 'Irregularidad en etiquetado', 4);
INSERT INTO inspeccion (numero, fecha_inspeccion, hora_inicio, resultado, semaforo) VALUES (15, '2024-01-25', '12:45:00', 'Sin irregularidades', 6);

-- segunda_inspeccion
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (1, '2024-01-14', '09:00:00', 'Documentación presentada; irregularidad subsanada.', 2);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (2, '2024-01-23', '10:30:00', 'Etiquetado corregido; mercancía liberada.', 4);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (3, '2024-01-29', '11:00:00', 'Peso confirmado; se ajusta declaración.', 6);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (4, '2024-02-06', '08:30:00', 'Mercancía no declarada confiscada; proceso sancionatorio.', 8);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (5, '2024-02-13', '14:00:00', 'Valor corregido por importador; pedimento rectificado.', 10);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (6, '2024-01-15', '09:30:00', 'Revisión adicional; se confirma subsanación.', 2);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (7, '2024-01-24', '11:45:00', 'Segunda revisión sin nuevas observaciones.', 4);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (8, '2024-01-30', '13:15:00', 'Ajuste de declaración aceptado por aduana.', 6);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (9, '2024-02-07', '10:00:00', 'Acta levantada; caso turnado a autoridades.', 8);
INSERT INTO segunda_inspeccion (ID_revision, fecha_inspeccion, hora_inicio, resultado, inspeccion) VALUES (10, '2024-02-14', '15:00:00', 'Rectificación aprobada; expediente cerrado.', 10);

-- inspeccion_inspector
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (1, 'INS-001', 'Revisión documental completa, sin observaciones adicionales.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (2, 'INS-002', 'Falta factura comercial; se notificó al agente aduanal.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (3, 'INS-003', 'Revisión de contenedor completada sin hallazgos relevantes.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (4, 'INS-004', 'Etiquetado en idioma no permitido; requiere corrección.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (5, 'INS-005', 'Mercancía conforme, despacho autorizado.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (6, 'INS-006', 'Se detectó diferencia de 15 kg sobre lo declarado.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (7, 'INS-007', 'Revisión documental y física sin irregularidades.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (8, 'INS-008', 'Mercancía adicional no incluida en pedimento; levantamiento de acta.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (9, 'INS-009', 'Contenedor sellado y conforme al pedimento.');
INSERT INTO inspeccion_inspector (inspeccion, inspector_adu, observaciones) VALUES (10, 'INS-010', 'Valor factura difiere en USD 2,000 respecto al declarado.');

-- segunda_inspeccion_inspector
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (1, 'INS-002', 'Verificación de documentos presentados como subsanación.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (2, 'INS-004', 'Revisión de etiquetado corregido y conforme a norma.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (3, 'INS-006', 'Peso verificado con báscula certificada; ajuste aprobado.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (4, 'INS-008', 'Mercancía no declarada separada e inventariada.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (5, 'INS-010', 'Documentación de valor revisada con factura original.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (6, 'INS-001', 'Apoyo en segunda verificación documental.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (7, 'INS-003', 'Sin nuevas observaciones durante segunda revisión.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (8, 'INS-005', 'Declaración ajustada y sellada.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (9, 'INS-007', 'Acta complementaria anexada al expediente.');
INSERT INTO segunda_inspeccion_inspector (segunda_ins, inspector_adu, observaciones) VALUES (10, 'INS-009', 'Expediente verificado y listo para cierre.');

-- incidencia
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (1, 'Medio', 'Documentación incompleta: falta factura comercial original.', 2);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (2, 'Bajo', 'Etiquetado en idioma no permitido por normativa.', 4);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (3, 'Bajo', 'Diferencia de peso de 15 kg sobre lo declarado.', 6);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (4, 'Alto', 'Mercancía no declarada detectada durante revisión física.', 8);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (5, 'Medio', 'Discrepancia de USD 2,000 en valor declarado vs factura.', 10);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (6, 'Bajo', 'Embalaje en mal estado; riesgo de daño en tránsito.', 3);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (7, 'Medio', 'Número de bultos no coincide con el pedimento.', 5);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (8, 'Alto', 'Mercancía de importación prohibida detectada.', 7);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (9, 'Bajo', 'Descripción de mercancía incompleta en pedimento.', 1);
INSERT INTO incidencia (codigo, gravedad, descripcion, inspeccion) VALUES (10, 'Medio', 'Permiso vencido presentado como válido.', 9);

-- sancion
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (1, 5000, 'Art. 184 Ley Aduanera – omisión de documentación.', 1);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (2, 2500, 'Art. 176 Ley Aduanera – incumplimiento NOM de etiquetado.', 2);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (3, 3000, 'Art. 178 Ley Aduanera – inexactitud en declaración de peso.', 3);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (4, 80000, 'Art. 183 Ley Aduanera – contrabando de mercancías.', 4);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (5, 12000, 'Art. 178 Ley Aduanera – subvaluación de mercancías.', 5);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (6, 1500, 'Art. 176 Ley Aduanera – embalaje deficiente.', 6);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (7, 4500, 'Art. 184 Ley Aduanera – diferencia en número de bultos.', 7);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (8, 150000, 'Art. 183 Ley Aduanera – importación de mercancía prohibida.', 8);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (9, 2000, 'Art. 176 Ley Aduanera – descripción de mercancía incompleta.', 9);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (10, 18000, 'Art. 184 Ley Aduanera – uso de permiso vencido.', 10);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (11, 6500, 'Art. 184 Ley Aduanera – incumplimiento en declaración de origen.', 3);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (12, 35000, 'Art. 183 Ley Aduanera – introducción de mercancía prohibida.', 8);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (13, 4000, 'Art. 178 Ley Aduanera – inexactitud en descripción de mercancía.', 9);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (14, 22000, 'Art. 184 Ley Aduanera – presentación de documentación apócrifa.', 5);
INSERT INTO sancion (num_sancion, monto_multa, fundamento_legal, incidencia) VALUES (15, 9500, 'Art. 176 Ley Aduanera – omisión de datos obligatorios en pedimento.', 7);

-- operacion_aduanera
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (1, '2024-01-10', '2024-01-12', 'Importación', 2, 1, 2, 1, 1);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (2, '2024-01-13', '2024-01-15', 'Exportación', 2, 2, 3, 5, 2);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (3, '2024-01-15', NULL, 'Importación', 1, 3, 4, 2, 3);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (4, '2024-01-18', '2024-01-20', 'Importación', 2, 4, 5, 4, 4);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (5, '2024-01-22', '2024-01-24', 'Exportación', 2, 5, 6, 6, 5);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (6, '2024-01-25', NULL, 'Importación', 1, 6, 7, 3, 6);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (7, '2024-01-28', '2024-01-30', 'Exportación', 2, 7, 8, 7, 7);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (8, '2024-02-01', '2024-02-03', 'Importación', 2, 8, 9, 8, 8);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (9, '2024-02-05', NULL, 'Exportación', 1, 9, 10, 9, 9);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (10, '2024-02-08', '2024-02-10', 'Importación', 2, 10, 1, 10, 10);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (11, '2024-02-11', '2024-02-13', 'Importación', 2, 1, 2, 6, 1);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (12, '2024-02-12', '2024-02-14', 'Exportación', 2, 2, 3, 7, 2);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (13, '2024-02-15', NULL, 'Importación', 1, 3, 4, 8, 3);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (14, '2024-02-16', '2024-02-19', 'Importación', 2, 4, 5, 9, 4);
INSERT INTO operacion_aduanera (ID_operacion, fecha_inicio, fecha_final, tipo_operacion, estado_ope_aduanera, cliente, usuario, bitacora, aduana) VALUES (15, '2024-02-18', '2024-02-20', 'Exportación', 2, 5, 6, 10, 5);

-- pedimento
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 01 3991 4 000001', 'A1', '2024-01-10', 125000, 1, 1, 'PERM-COFEPRIS-2024-001', 1, NULL, 1);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 02 3991 4 000002', 'V1', '2024-01-13', 87500.5, 2, 2, 'PERM-SE-2024-002', 2, 1, NULL);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 03 3991 4 000003', 'A1', '2024-01-15', 340000, 3, 1, 'PERM-SADER-2024-001', 3, NULL, 3);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 04 3991 4 000004', 'A1', '2024-01-18', 210000.75, 4, 1, 'PERM-SE-2024-001', 4, NULL, 4);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 05 3991 4 000005', 'V1', '2024-01-22', 95000, 5, 2, 'PERM-COFEPRIS-2024-003', 5, 3, NULL);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 06 3991 4 000006', 'A1', '2024-01-25', 460000, 6, 5, 'PERM-SEDENA-2024-001', 6, NULL, 2);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 07 3991 4 000007', 'V1', '2024-01-28', 178000.25, 7, 2, 'PERM-SEDENA-2024-002', 7, 9, NULL);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 08 3991 4 000008', 'A1', '2024-02-01', 320000, 8, 1, 'PERM-COFEPRIS-2024-002', 8, NULL, 1);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 09 3991 4 000009', 'V1', '2024-02-05', 55000, 9, 2, 'PERM-SE-2024-003', 9, 1, NULL);
INSERT INTO pedimento (numero_pedimento, clave_pedimento, fecha_registro, valor_total, semaforo, regimen_adu, permiso, ope_aduanera, tipo_exportacion, tipo_importacion) VALUES ('24 10 3991 4 000010', 'A1', '2024-02-08', 740000, 10, 1, 'PERM-SADER-2024-002', 10, NULL, 7);

-- categoria_productos
-- IGI: tasa del Impuesto General de Importación propia de cada categoría
-- tipo_arancel: metodología arancelaria (1=Ad Valorem, 2=Específico, 3=Mixto, 4=Arancel-Cupo, 5=Estacional, 6=Cuota Compensatoria, 7=Preferencial TLC, 8=Arancel Cero)
-- tipo_permiso_requerido: NULL = categoría libre, valor = tipo de permiso obligatorio (COFEPRIS, SADER, SEDENA, SE)
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (1,  'Electrodomésticos',            'Aparatos eléctricos de uso doméstico importados.',                                15,   1, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (2,  'Textiles',                     'Telas, hilos y prendas de vestir para comercialización.',                         10,   3, 'SE');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (3,  'Insumos Industriales',         'Materias primas para procesos de manufactura.',                                    5,   7, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (4,  'Calzado',                      'Zapatos, botas y accesorios de calzado.',                                         25,   1, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (5,  'Maquinaria',                   'Equipos industriales y herramientas de producción.',                               0,   8, 'SE');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (6,  'Componentes Electrónicos',     'Circuitos, microprocesadores y partes electrónicas.',                              3,   4, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (7,  'Bebidas Alcohólicas',          'Vinos, licores y cervezas de importación.',                                       20,   2, 'COFEPRIS');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (8,  'Acero y Metales',              'Láminas, varillas y productos siderúrgicos.',                                     25,   6, 'SE');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (9,  'Productos Agropecuarios',      'Frutas, verduras y alimentos del campo.',                                          8,   5, 'SADER');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (10, 'Vehículos',                    'Automóviles, camiones y vehículos de carga.',                                     20,   1, 'SE');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (11, 'Productos Farmacéuticos',      'Medicamentos, vacunas y productos de uso médico controlado.',                      5,   7, 'COFEPRIS');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (12, 'Alimentos Procesados',         'Conservas, enlatados y alimentos con procesamiento industrial.',                  15,   1, 'COFEPRIS');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (13, 'Químicos Industriales',        'Solventes, ácidos y compuestos químicos para uso industrial.',                     3,   4, 'SEDENA');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (14, 'Material Eléctrico',           'Cables, transformadores y equipos de distribución eléctrica.',                     0,   8, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (15, 'Plásticos y Hules',            'Polímeros, resinas y materiales elastoméricos para manufactura.',                  5,   7, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (16, 'Cosméticos y Perfumería',      'Productos de belleza, fragancias y cuidado personal.',                            15,   1, 'COFEPRIS');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (17, 'Suplementos Alimenticios',     'Vitaminas, proteínas y complementos nutricionales.',                              15,   1, 'COFEPRIS');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (18, 'Equipos Médicos',              'Dispositivos, instrumental y equipos para uso clínico.',                           3,   4, 'COFEPRIS');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (19, 'Material Bélico',              'Armamento, munición y equipo de uso exclusivo militar.',                           5,   7, 'SEDENA');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (20, 'Equipo Óptico y de Visión',    'Lentes, binoculares, miras y equipo óptico especializado.',                        3,   4, 'SEDENA');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (21, 'Animales Vivos',               'Importación y exportación de animales con control zoosanitario.',                  8,   5, 'SADER');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (22, 'Semillas y Granos',            'Semillas agrícolas, cereales y granos con control fitosanitario.',                 8,   5, 'SADER');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (23, 'Juguetes y Artículos Infantiles','Juguetes, juegos didácticos y artículos de entretenimiento infantil.',           25,   1, 'SE');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (24, 'Textiles Técnicos',            'Telas de alto rendimiento para uso industrial, médico o militar.',                10,   3, 'SE');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (25, 'Fertilizantes y Agroquímicos', 'Pesticidas, herbicidas y fertilizantes de uso agrícola controlado.',               3,   4, 'SADER');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (26, 'Combustibles y Lubricantes',   'Derivados del petróleo, aceites industriales y lubricantes.',                     25,   6, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (27, 'Madera y Productos Forestales','Troncos, tablones y derivados de madera certificada.',                             8,   5, 'SADER');
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (28, 'Papel y Cartón',               'Rollos, hojas y empaques de papel para uso comercial e industrial.',              25,   1, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (29, 'Instrumentos Musicales',       'Instrumentos de cuerda, viento, percusión y sus accesorios.',                     25,   1, NULL);
INSERT INTO categoria_productos (numero, nombre, descripcion, IGI, tipo_arancel, tipo_permiso_requerido) VALUES (30, 'Artículos Deportivos',         'Equipos, ropa y accesorios para práctica deportiva.',                             25,   1, NULL);

-- arancel (un registro por pedimento+categoría; IGI es fotografía de la tasa vigente al momento del despacho)
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (1,  18750,    'Arancel Ad Valorem aplicado a electrodomésticos importados.',    15,   0,   1, '24 01 3991 4 000001', 1);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (2,  13125.08, 'Arancel mixto para textiles con cuota compensatoria.',           10,   2.5, 3, '24 02 3991 4 000002', 2);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (3,  34000,    'Arancel preferencial TLC para insumos de manufactura.',           5,   0,   7, '24 03 3991 4 000003', 3);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (4,  21000.75, 'Arancel Ad Valorem para calzado importado.',                    25,   0,   1, '24 04 3991 4 000004', 4);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (5,  9500,     'Arancel cero para maquinaria sin similar nacional.',              0,   0,   8, '24 05 3991 4 000005', 5);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (6,  46000,    'Arancel IMMEX para componentes electrónicos.',                    3,   0,   4, '24 06 3991 4 000006', 6);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (7,  17800.25, 'Arancel específico para bebidas alcohólicas importadas.',        20,   1.5, 2, '24 07 3991 4 000007', 7);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (8,  32000,    'Cuota compensatoria para acero importado de China.',             25,   0,   6, '24 08 3991 4 000008', 8);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (9,  5500,     'Arancel estacional para frutas de temporada.',                    8,   0,   5, '24 09 3991 4 000009', 9);
INSERT INTO arancel (numero, subtotal, descripcion, IGI, tasa_interes, Tipo_Arancel, pedimento, categoria) VALUES (10, 74000,    'Arancel Ad Valorem para vehículos importados.',                  20,   0,   1, '24 10 3991 4 000010', 10);

-- tipo_embalaje
INSERT INTO tipo_embalaje (id, nombre, peso_maximo, descripcion) VALUES
    (1, 'Caja',        100.00,   'Caja de cartón o madera; artículos de hasta 100 kg'),
    (2, 'Sobre',         3.00,   'Sobre acolchado o de burbuja; documentos y artículos ligeros'),
    (3, 'Paleta',     1500.00,   'Paleta de madera o plástico; cargas industriales paletizadas'),
    (4, 'Tambor',      250.00,   'Tambor metálico o plástico; líquidos y graneles'),
    (5, 'Contenedor', 28000.00,  "Contenedor marítimo 20'/40'/40'HC; cargas de gran volumen");

-- categoria_embalaje (embalajes compatibles por categoría de producto)
INSERT INTO categoria_embalaje (categoria_id, tipo_embalaje_id) VALUES
    (1,1),(1,3),(1,5),   -- Electrodomésticos: Caja, Paleta, Contenedor
    (2,1),(2,3),(2,5),   -- Textiles: Caja, Paleta, Contenedor
    (3,3),(3,4),(3,5),   -- Insumos Industriales: Paleta, Tambor, Contenedor
    (4,1),(4,3),(4,5),   -- Calzado: Caja, Paleta, Contenedor
    (5,3),(5,5),         -- Maquinaria: Paleta, Contenedor
    (6,1),(6,2),(6,3),(6,5),  -- Componentes Electrónicos: Caja, Sobre, Paleta, Contenedor
    (7,1),(7,3),(7,4),(7,5),  -- Bebidas Alcohólicas: Caja, Paleta, Tambor, Contenedor
    (8,3),(8,5),         -- Acero y Metales: Paleta, Contenedor
    (9,1),(9,3),(9,4),(9,5),  -- Productos Agropecuarios: Caja, Paleta, Tambor, Contenedor
    (10,5),              -- Vehículos: solo Contenedor
    (11,1),(11,2),(11,3),(11,5),  -- Productos Farmacéuticos: Caja, Sobre, Paleta, Contenedor
    (12,1),(12,3),(12,5),  -- Alimentos Procesados: Caja, Paleta, Contenedor
    (13,3),(13,4),(13,5),  -- Químicos Industriales: Paleta, Tambor, Contenedor
    (14,1),(14,3),(14,5),  -- Material Eléctrico: Caja, Paleta, Contenedor
    (15,1),(15,3),(15,4),(15,5),  -- Plásticos y Hules: Caja, Paleta, Tambor, Contenedor
    (16,1),(16,2),(16,3),(16,5),  -- Cosméticos y Perfumería: Caja, Sobre, Paleta, Contenedor
    (17,1),(17,2),(17,3),(17,5),  -- Suplementos Alimenticios: Caja, Sobre, Paleta, Contenedor
    (18,1),(18,3),(18,5),  -- Equipos Médicos: Caja, Paleta, Contenedor
    (19,1),(19,5),         -- Material Bélico: Caja, Contenedor
    (20,1),(20,2),(20,5),  -- Equipo Óptico y Visión: Caja, Sobre, Contenedor
    (21,5),              -- Animales Vivos: solo Contenedor
    (22,3),(22,4),(22,5),  -- Semillas y Granos: Paleta, Tambor, Contenedor
    (23,1),(23,3),(23,5),  -- Juguetes y Art. Infantil: Caja, Paleta, Contenedor
    (24,1),(24,3),(24,5),  -- Textiles Técnicos: Caja, Paleta, Contenedor
    (25,3),(25,4),(25,5),  -- Fertilizantes/Agroquímicos: Paleta, Tambor, Contenedor
    (26,4),(26,5),         -- Combustibles y Lubricantes: Tambor, Contenedor
    (27,3),(27,5),         -- Madera y Prod. Forestales: Paleta, Contenedor
    (28,1),(28,3),(28,5),  -- Papel y Cartón: Caja, Paleta, Contenedor
    (29,1),(29,5),         -- Instrumentos Musicales: Caja, Contenedor
    (30,1),(30,3),(30,5);  -- Artículos Deportivos: Caja, Paleta, Contenedor

-- paquete
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 1,  250.5, 5, '589x235x239 cm',   1, '24 01 3991 4 000001');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 2,   80.0, 3, '120x100x150 cm',   2, '24 02 3991 4 000002');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 3, 1200.0, 5, '1203x235x239 cm',  3, '24 03 3991 4 000003');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 4,  45.75, 1, '60x40x50 cm',      4, '24 04 3991 4 000004');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 5,  310.0, 3, '120x100x180 cm',   5, '24 05 3991 4 000005');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 6,  980.0, 5, '589x235x239 cm',   6, '24 06 3991 4 000006');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 7,   55.2, 1, '80x60x60 cm',      7, '24 07 3991 4 000007');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 8,  420.0, 3, '120x100x200 cm',   8, '24 08 3991 4 000008');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES ( 9,   15.0, 2, '40x30x5 cm',       9, '24 09 3991 4 000009');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES (10, 2100.0, 5, '1203x235x239 cm', 10, '24 10 3991 4 000010');
INSERT INTO paquete (codigo, peso, tipo_embalaje_id, dimensiones, cliente, pedimento) VALUES (11,  610.0, 5, '589x235x239 cm',  11, NULL);

-- producto
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (1, 'Refrigerador Samsung 20 pies', 'Refrigerador de dos puertas, eficiencia A++.', 85, 12500, 1);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (2, 'Tela denim 100% algodón', 'Tela de mezclilla en rollo de 50 metros.', 25, 350, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (3, 'Resina ABS industrial', 'Granulado de plástico ABS para inyección.', 500, 18.5, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (4, 'Bota de trabajo piel', 'Bota industrial con casquillo de acero talla 27.', 1.2, 890, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (5, 'Torno CNC horizontal', 'Torno de control numérico para mecanizado de precisión.', 3200, 285000, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (6, 'Microprocesador Intel i9', 'Procesador de décima generación 3.7 GHz.', 0.05, 9800, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (7, 'Whisky Escocés 12 años', 'Botella 750 ml, Scotch Single Malt.', 1.2, 1250, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (8, 'Lámina de acero galvanizada', 'Lámina de 1.22x2.44 m calibre 20.', 12, 480, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (9, 'Aguacate Hass', 'Caja de aguacates frescos 4 kg.', 4, 185, 9);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (10, 'Automóvil Toyota Corolla 2024', 'Sedan 4 puertas, motor 1.8L, transmisión CVT.', 1350, 380000, 10);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (11, 'Amoxicilina 500mg caja 100 cáps', 'Antibiótico de amplio espectro para uso humano.', 0.35, 420, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (12, 'Atún en lata 140g', 'Atún en agua, envasado herméticamente.', 0.14, 28.5, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (13, 'Acetona industrial litro', 'Solvente orgánico grado industrial para limpieza.', 0.79, 95, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (14, 'Cable THW calibre 12 rollo 100m', 'Cable de cobre con aislamiento termoplástico.', 8.5, 1850, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (15, 'Perfil de PVC rígido 6 metros', 'Perfil extruido de PVC para marcos y construcción.', 3.2, 310, 4);
-- Productos adicionales para categorías 1-15 (2 más por categoría)
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (16, 'Lavadora LG 18 kg carga frontal', 'Lavadora automática con vapor y AI DD.', 65, 14500, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (17, 'Aire Acondicionado Daikin 18000 BTU', 'Minisplit inverter frio/calor 220V.', 38, 18900, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (18, 'Hilo de poliéster 150D rollo 5000m', 'Hilo industrial de alta tenacidad color blanco.', 4.5, 820, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (19, 'Tela gabardina stretch 300m rollo', 'Tela de poliéster y elastano para ropa formal.', 28, 3200, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (20, 'Polipropileno granulado 25 kg saco', 'PP homopolímero grado inyección.', 25, 480, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (21, 'Masterbatch negro concentrado 5 kg', 'Aditivo colorante para plásticos.', 5, 650, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (22, 'Tenis deportivos running talla 27', 'Tenis con suela de EVA y upper de malla.', 0.7, 1250, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (23, 'Sandalia de hule TPR par talla 26', 'Sandalia ligera antideslizante.', 0.4, 380, 9);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (24, 'Fresadora vertical CNC 3 ejes', 'Centro de mecanizado vertical de alta precisión.', 4800, 520000, 10);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (25, 'Compresor de tornillo 100 HP', 'Compresor rotativo de tornillo lubricado.', 850, 185000, 11);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (26, 'Memoria RAM DDR5 32 GB', 'Módulo de memoria de alta velocidad 4800 MHz.', 0.03, 5800, 1);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (27, 'Disco SSD NVMe 2 TB', 'Unidad de estado sólido M.2 PCIe 4.0.', 0.01, 4200, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (28, 'Vino tinto Malbec reserva 750 ml', 'Vino argentino añada 2020.', 1.3, 890, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (29, 'Ron oscuro añejo 8 años 750 ml', 'Ron de melaza envejecido en barrica de roble.', 1.2, 1100, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (30, 'Varilla corrugada 3/8" barra 12 m', 'Varilla de acero grado 60 para construcción.', 11.2, 380, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (31, 'Tubo estructural rectangular 2x4"', 'Perfil de acero A36 longitud 6 metros.', 18, 680, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (32, 'Limón persa caja 20 kg', 'Limones frescos de primera selección.', 20, 340, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (33, 'Jitomate bola bandeja 10 kg', 'Jitomate hidropónico grado exportación.', 10, 280, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (34, 'Motocicleta Honda CB500F 2024', 'Moto naked 500cc ABS de doble disco.', 196, 98000, 9);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (35, 'Pickup Ford F-150 gasolina 2024', 'Pickup doble cabina 2.7L EcoBoost.', 1980, 680000, 10);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (36, 'Ibuprofeno 400 mg caja 50 tabs', 'Antiinflamatorio y analgésico no esteroideo.', 0.12, 180, 11);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (37, 'Vacuna influenza estacional dosis', 'Vial monodosis inactivada cuadrivalente.', 0.02, 285, 1);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (38, 'Leche en polvo entera 900 g', 'Leche deshidratada riquísima en calcio.', 0.9, 310, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (39, 'Mermelada de fresa 440 g frasco', 'Mermelada de fruta real sin conservadores.', 0.6, 95, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (40, 'Tolueno grado industrial balde 20 L', 'Disolvente orgánico aromático.', 17.4, 1850, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (41, 'Ácido sulfúrico 98% bidón 25 L', 'Ácido mineral concentrado grado técnico.', 46.5, 2100, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (42, 'Interruptor termomagnético 2P 40A', 'Breaker riel DIN curva C protección bifásica.', 0.5, 780, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (43, 'Panel solar policristalino 400 W', 'Módulo fotovoltaico 72 celdas MC4.', 22, 6800, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (44, 'Manguera de hule industrial 1" 50m', 'Manguera de alta presión 250 PSI roja.', 8.5, 1350, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (45, 'Film stretch transparente 500mm', 'Rollo de polietileno para embalaje 300 m.', 3.2, 420, 9);
-- Productos para categorías 16-30 (3 por categoría)
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (46, 'Perfume Chanel Nº5 EDP 100 ml', 'Eau de Parfum floral con notas de aldehídos.', 0.35, 4500, 10);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (47, 'Crema hidratante facial SPF 50 50ml', 'Protector solar con ácido hialurónico.', 0.1, 680, 11);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (48, 'Sérum vitamina C 30 ml', 'Antioxidante y luminosidad para rostro.', 0.08, 1200, 1);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (49, 'Proteína whey chocolate 2 lb', 'Proteína de suero con 24g por servicio.', 0.9, 1450, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (50, 'Multivitamínico diario 60 cápsulas', 'Complejo vitamínico-mineral para adultos.', 0.15, 580, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (51, 'Colágeno hidrolizado neutro 300 g', 'Péptidos de colágeno tipo I y III.', 0.35, 890, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (52, 'Electrocardiógrafo portátil 12 deriv', 'ECG digital con pantalla táctil e impresora.', 3.8, 28500, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (53, 'Tensiómetro digital de brazo', 'Monitor de presión arterial automático.', 0.35, 1850, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (54, 'Oxímetro de pulso digital', 'Sensor SpO2 y frecuencia cardiaca LED.', 0.06, 480, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (55, 'Rifle de asalto HK G36 cal. 5.56', 'Fusil de asalto para uso militar.', 3.6, 45000, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (56, 'Pistola Beretta M9 cal. 9 mm', 'Pistola semiautomática de uso reglamentario.', 0.95, 18500, 9);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (57, 'Chaleco antibalas nivel IIIA', 'Chaleco balístico Kevlar con placas laterales.', 4.2, 22000, 10);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (58, 'Binoculares militares 10x50 reticulo', 'Binoculares con retículo iluminado y brújula.', 1.6, 12500, 11);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (59, 'Mira telescópica 4-16x50 iluminada', 'Scope con retículo BDC para rifle.', 0.65, 8900, 1);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (60, 'Gafas visión nocturna Gen III', 'Intensificador de imagen generación III.', 0.72, 95000, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (61, 'Bovino lechero Holstein hembra', 'Vaca de ordeña primer parto certificada.', 620, 32000, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (62, 'Cerdo engorda raza Pietrain 90 kg', 'Cerdo finalizado con certificado zoosanitario.', 90, 6500, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (63, 'Gallina ponedora Leghorn blanca', 'Parvada certificada libre de enfermedades.', 1.8, 380, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (64, 'Semilla maíz híbrido DK7088 60 kg', 'Semilla de alto rendimiento certificada.', 60, 3800, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (65, 'Semilla trigo harinero 50 kg saco', 'Trigo cristalino grado primes certificado.', 50, 1250, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (66, 'Frijol negro certificado saco 50 kg', 'Semilla seleccionada libre de plagas.', 50, 980, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (67, 'Set construcción LEGO 1500 piezas', 'Juego de ensamblaje con instrucciones.', 1.2, 2800, 9);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (68, 'Muñeca articulada con accesorios', 'Muñeca 30 cm con 5 cambios de ropa.', 0.4, 650, 10);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (69, 'Auto control remoto 1:10 eléctrico', 'Carro RC con batería y cargador incluidos.', 1.1, 1200, 11);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (70, 'Tela ignífuga Nomex 200g/m2 50m', 'Tejido resistente a llama para overoles.', 12, 18500, 1);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (71, 'Geotextil no tejido 200g/m2 100m', 'Membrana para obras civiles y drenaje.', 28, 4200, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (72, 'Membrana PTFE microporosa 10m', 'Tejido técnico impermeable transpirable.', 3.5, 22000, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (73, 'Urea granulada 46% nitrógeno 50 kg', 'Fertilizante nitrogenado de liberación rápida.', 50, 780, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (74, 'Fungicida Kocide 2000 cúprico 1 kg', 'Fungicida-bactericida de contacto en polvo.', 1, 680, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (75, 'Herbicida glifosato 48% litro', 'Herbicida sistémico de amplio espectro.', 1.1, 320, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (76, 'Aceite motor sintético 5W30 4 L', 'Lubricante full-sintético para gasolina y diesel.', 3.6, 580, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (77, 'Grasa de litio multipropósito 400g', 'Lubricante para rodamientos y articulaciones.', 0.45, 180, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (78, 'Diesel agrícola bidón 200 L', 'Combustible destilado medio para maquinaria.', 170, 3200, 9);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (79, 'Triplay de pino 18mm hoja 1.22x2.44', 'Panel de contrachapado para construcción.', 28, 850, 10);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (80, 'Tablón de encino 2x8 barra 3m', 'Madera de hardwood seca en horno.', 12, 620, 11);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (81, 'Madera de pino cepillada 2x4 2.44m', 'Tabla cepillada para mueblería y construcción.', 4, 185, 1);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (82, 'Cartón corrugado doble pared 1.22m', 'Hoja corrugada tipo C/B para embalaje.', 2.8, 320, 2);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (83, 'Papel bond carta 75g caja 5000h', 'Papel blanco para impresión láser e inyección.', 24, 980, 3);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (84, 'Papel tissue jumbo roll 400m', 'Rollo de papel higiénico para dispensador.', 2.2, 420, 4);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (85, 'Guitarra eléctrica Fender Stratocaster', 'Guitarra sólida con pastillas Noiseless.', 3.8, 28000, 5);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (86, 'Saxofón alto King Super 20', 'Saxofón profesional con estuche rígido.', 2.5, 45000, 6);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (87, 'Batería acústica Pearl Export 5 piezas', 'Set completo con platillos Sabian B8.', 38, 18500, 7);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (88, 'Bicicleta montaña Trek Marlin 7', 'MTB 29" aluminio con frenos de disco hidráulico.', 14.5, 22000, 8);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (89, 'Raqueta tenis Wilson Pro Staff 97', 'Raqueta de grafito para jugador avanzado.', 0.32, 8500, 9);
INSERT INTO producto (codigo, nombre, descripcion, peso, valor_unitario, paquete) VALUES (90, 'Caminadora eléctrica NordicTrack T6', 'Caminadora plegable 3.5HP con pantalla.', 82, 28000, 10);

-- categorias_productos_rel
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, 12);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, 13);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, 14);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, 15);
-- Relaciones adicionales para categorías 1-15
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1,16),(1,17);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2,18),(2,19);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3,20),(3,21);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4,22),(4,23);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5,24),(5,25);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6,26),(6,27);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7,28),(7,29);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8,30),(8,31);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9,32),(9,33);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10,34),(10,35);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11,36),(11,37);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12,38),(12,39);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13,40),(13,41);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14,42),(14,43);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15,44),(15,45);
-- Relaciones para categorías 16-30
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16,46),(16,47),(16,48);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17,49),(17,50),(17,51);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18,52),(18,53),(18,54);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19,55),(19,56),(19,57);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20,58),(20,59),(20,60);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21,61),(21,62),(21,63);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22,64),(22,65),(22,66);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23,67),(23,68),(23,69);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24,70),(24,71),(24,72);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25,73),(25,74),(25,75);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26,76),(26,77),(26,78);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27,79),(27,80),(27,81);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28,82),(28,83),(28,84);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29,85),(29,86),(29,87);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30,88),(30,89),(30,90);

-- factura
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (1, 3000, 18750, 21750, 'UUID-2024-FAC-000001', '2024-01-12', 1);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (2, 2100.01, 13125.08, 15225.09, 'UUID-2024-FAC-000002', '2024-01-15', 2);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (3, 27200, 170000, 197200, 'UUID-2024-FAC-000003', '2024-01-17', 3);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (4, 6720.02, 42000.15, 48720.17, 'UUID-2024-FAC-000004', '2024-01-20', 4);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (5, 1520, 9500, 11020, 'UUID-2024-FAC-000005', '2024-01-24', 5);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (6, 11040, 69000, 80040, 'UUID-2024-FAC-000006', '2024-01-27', 6);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (7, 4272.01, 26700.04, 30972.05, 'UUID-2024-FAC-000007', '2024-01-30', 7);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (8, 7680, 48000, 55680, 'UUID-2024-FAC-000008', '2024-02-03', 8);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (9, 880, 5500, 6380, 'UUID-2024-FAC-000009', '2024-02-07', 9);
INSERT INTO factura (codigo, IVA, subtotal, total, folio_fiscal, fecha_factura, ID_operacion) VALUES (10, 17760, 111000, 128760, 'UUID-2024-FAC-000010', '2024-02-10', 10);

-- pago
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0001', 1, 'Pago de derechos de importación', 0, 18750, '2024-01-11', '24 01 3991 4 000001', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0002', 1, 'Pago de arancel e IGI', 0, 13125.08, '2024-01-14', '24 02 3991 4 000002', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0003', 1, 'Pago parcial derechos de importación', 170000, 170000, '2024-01-16', '24 03 3991 4 000003', 3);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0004', 1, 'Pago total derechos e IVA', 0, 42000.15, '2024-01-19', '24 04 3991 4 000004', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0005', 1, 'Pago de servicios de despacho', 0, 9500, '2024-01-23', '24 05 3991 4 000005', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0006', 1, 'Pago de derechos de importación IMMEX', 0, 69000, '2024-01-26', '24 06 3991 4 000006', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0007', 1, 'Pago de IGI y cuotas compensatorias', 0, 26700.04, '2024-01-29', '24 07 3991 4 000007', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0008', 1, 'Pago total de arancel', 0, 48000, '2024-02-02', '24 08 3991 4 000008', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0009', 1, 'Pago de derechos de exportación', 0, 5500, '2024-02-06', '24 09 3991 4 000009', 1);
INSERT INTO pago (no_transaccion, numero_pago, concepto, saldo_final, monto, fecha_pago, pedimento, estado_pago) VALUES ('TXN-2024-0010', 1, 'Pago de IGI y DTA', 0, 111000, '2024-02-09', '24 10 3991 4 000010', 2);

-- ================================================================
-- Complemento: productos reales adicionales por categoría (91 en adelante)
-- 40 productos reales y específicos por cada una de las 30 categorías
-- ================================================================

-- Electrodomésticos (categoria 1)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Horno de microondas Panasonic 1.2 pies inverter', 'Microondas con tecnología inverter para cocción uniforme.', 29.48, 5534.47, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Licuadora Oster clásica 600W', 'Licuadora de vaso de vidrio con 3 velocidades y pulso.', 58.76, 2813.54, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Horno eléctrico Black+Decker 42 L', 'Horno de sobremesa con función de convección y grill.', 48.46, 12989.41, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aspiradora Dyson V11 inalámbrica', 'Aspiradora ciclónica sin cable con pantalla LCD.', 5.69, 17908.02, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Plancha de vapor Rowenta Pro Master', 'Plancha con suela de acero inoxidable y golpe de vapor.', 3.86, 15347.51, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cafetera Nespresso Vertuo Next', 'Cafetera de cápsulas con tecnología de centrifugado.', 6.75, 3447.74, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Batidora KitchenAid Artisan 5 qt', 'Batidora de pie con tazón de acero inoxidable.', 38.49, 28991.77, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Freidora de aire Ninja Foodi 5.5 L', 'Freidora de aire caliente con canasta antiadherente.', 11.58, 8046.39, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tostadora Hamilton Beach 4 rebanadas', 'Tostadora con control de tostado ajustable y bandeja recogemigas.', 56.66, 33185.5, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ventilador de torre Honeywell QuietSet', 'Ventilador oscilante con 8 velocidades y control remoto.', 52.15, 14064.81, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Extractor de jugos Hamilton Beach Big Mouth', 'Extractor de jugos con tubo de alimentación ancho.', 87.87, 1916.42, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Calentador de agua Rheem 40 L', 'Boiler eléctrico de depósito con termostato regulable.', 77.33, 10349.44, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Secadora de ropa Whirlpool 7 kg', 'Secadora de tambor con sensor de humedad.', 13.41, 4387.39, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Congelador horizontal Mabe 300 L', 'Congelador de gran capacidad con canasta removible.', 28.11, 28619.58, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Purificador de agua EcoWater EC-15', 'Sistema de filtración por ósmosis inversa.', 16.68, 20481.53, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Robot aspirador iRobot Roomba i7+', 'Robot aspirador con vaciado automático y mapeo inteligente.', 57.68, 13222.19, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Horno de convección Oster 6 rebanadas', 'Horno tostador con función de aire caliente.', 49.52, 2478.78, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Deshumidificador Frigidaire 50 pintas', 'Deshumidificador portátil con depósito de 12.7 L.', 5.83, 7446.77, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Parrilla eléctrica George Foreman Grill', 'Parrilla de contacto antiadherente con bandeja de goteo.', 61.4, 15137.45, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Exprimidor de cítricos Breville Citrus Press', 'Exprimidor eléctrico con cono de acero inoxidable.', 28.62, 20619.0, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Máquina de coser Singer 4423 Heavy Duty', 'Máquina de coser de alta velocidad, 23 puntadas.', 41.06, 10701.91, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Plancha para el cabello GHD Platinum+', 'Plancha alisadora con placas de cerámica.', 71.6, 24555.11, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Secadora de pelo Dyson Supersonic', 'Secadora con motor digital de alta velocidad.', 22.35, 20232.5, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Humidificador Levoit Classic 300S', 'Humidificador ultrasónico de niebla fría con control por app.', 47.51, 30667.27, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Estufa de gas Mabe 6 quemadores', 'Estufa de piso con horno integrado y encendido eléctrico.', 65.79, 10291.44, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Campana extractora Whirlpool 90 cm', 'Campana de isla con filtros de aluminio lavables.', 88.23, 4396.88, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lavavajillas Bosch Serie 300', 'Lavavajillas empotrable con 3 canastas y secado por condensación.', 37.92, 26572.79, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Horno tostador Cuisinart TOB-260', 'Horno tostador de convección con bandeja para pizza.', 14.1, 17267.02, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Enfriador de vino NewAir 18 botellas', 'Vinoteca compacta con control de temperatura dual.', 4.01, 23487.09, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Procesador de alimentos Cuisinart 14 tazas', 'Procesador con disco rebanador y cuchilla de acero.', 68.93, 20184.0, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cafetera espresso De''Longhi Dedica', 'Cafetera espresso semiautomática con vaporizador de leche.', 78.86, 11187.04, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Waflera Cuisinart doble WAF-300', 'Waflera antiadherente con placas removibles.', 62.73, 20924.63, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Selladora al vacío FoodSaver V4400', 'Selladora al vacío automática con cortador integrado.', 52.4, 16130.32, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Olla de cocción lenta Crock-Pot 6 L', 'Olla de cocción lenta con 3 niveles de temperatura.', 75.68, 33080.43, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Freidora tradicional Hamilton Beach 2 canastas', 'Freidora eléctrica de aceite con canastas dobles.', 42.93, 23346.08, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Calentador de espacio De''Longhi TRD40615T', 'Radiador eléctrico de aceite con termostato ajustable.', 5.93, 24641.77, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aspiradora robot Roborock S7 MaxV', 'Robot aspirador y trapeador con detección de obstáculos.', 58.42, 34760.43, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Refrigerador de vinos Kalorik 18 botellas', 'Refrigerador vinotequero con puerta de vidrio templado.', 74.06, 10175.46, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mini refrigerador Frigidaire 4.5 pies', 'Refrigerador compacto con congelador independiente.', 35.03, 23502.25, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Batidora de inmersión Braun MultiQuick 9', 'Batidora de mano con accesorios picadora y batidor.', 2.52, 16320.83, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (1, LAST_INSERT_ID());

-- Textiles (categoria 2)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela mezclilla índigo 14 oz rollo 50m', 'Denim de alta densidad para prendas de trabajo.', 54.57, 1933.02, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela popelina 100% algodón rollo 100m', 'Tejido plano ligero para camisería.', 22.39, 11569.85, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela jersey de punto algodón/spandex', 'Tela elástica para playeras y ropa deportiva.', 43.16, 3864.7, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela franela de algodón cepillada', 'Tejido suave y cálido para pijamas y camisas.', 120.33, 13097.05, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela lino natural rollo 40m', 'Fibra natural transpirable para ropa de verano.', 28.77, 6847.97, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela microfibra impermeable 150 g/m2', 'Tejido técnico repelente al agua para chamarras.', 167.08, 13274.08, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela chiffon poliéster estampado', 'Tela ligera y fluida para vestidos de fiesta.', 246.69, 12986.97, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela sarga twill 8 oz', 'Tejido resistente para uniformes y pantalones de trabajo.', 87.13, 6346.39, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela satín de seda rollo 30m', 'Tela brillante de caída suave para lencería.', 110.84, 13286.05, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela lycra deportiva 4 direcciones', 'Tejido elástico de secado rápido para leggings.', 287.53, 2433.63, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela pique piqué para polos', 'Tejido texturizado transpirable para playeras tipo polo.', 56.98, 3632.96, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela franela escocesa a cuadros', 'Tejido de invierno estampado a cuadros clásicos.', 73.83, 7377.45, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela oxford para camisas', 'Tejido resistente de textura tramada visible.', 178.79, 4088.65, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela terciopelo elástico rollo 20m', 'Tela aterciopelada suave para vestuario de noche.', 6.21, 6400.41, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela impermeable oxford 600D', 'Tejido de nylon recubierto para mochilas y bolsas.', 113.93, 8581.85, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hilo de algodón mercerizado cono 3000m', 'Hilo resistente para costura industrial.', 286.16, 10419.31, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hilo de nylon para bordado', 'Hilo brillante multicolor para máquinas bordadoras.', 157.07, 9340.37, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Encaje de poliéster para lencería', 'Tela decorativa perforada para prendas íntimas.', 204.48, 999.09, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela sudadera French Terry', 'Tejido de punto afelpado para sudaderas.', 270.36, 11743.55, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de neopreno 3mm rollo 10m', 'Material elástico usado en trajes de buceo y fajas.', 262.98, 12008.52, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Elástico plano para cintura 5cm', 'Cinta elástica tejida para pretinas de ropa.', 120.75, 6104.89, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cierre de nylon No. 5 rollo 100m', 'Cremallera continua para confección de ropa y bolsas.', 35.54, 9587.49, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Botones de resina 4 agujeros mayoreo', 'Botones plásticos para camisas y blusas.', 23.36, 1196.74, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Entretela termoadhesiva rollo 50m', 'Refuerzo textil para cuellos y puños.', 66.59, 2602.09, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela polar antipilling 280 g/m2', 'Tejido cálido y ligero para chamarras polares.', 105.32, 978.12, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela gasa de algodón rollo 30m', 'Tela ligera y transparente para blusas de verano.', 5.07, 2438.72, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela dril industrial 12 oz', 'Tejido pesado y resistente para uniformes industriales.', 34.93, 5581.43, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela georgette estampada floral', 'Tela ligera con caída fluida para vestidos.', 12.52, 13140.12, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela toalla rizo de algodón', 'Tejido absorbente para toallas y batas.', 186.15, 2398.55, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela reflectante para seguridad', 'Tejido con cinta reflejante para chalecos de trabajo.', 79.42, 5341.37, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela antifluido para uniformes médicos', 'Tejido repelente a líquidos para batas quirúrgicas.', 112.43, 2018.07, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela mezclilla stretch 10 oz', 'Denim con elastano para pantalones ajustados.', 255.44, 14897.92, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cinta de sesgo poliéster rollo 100m', 'Cinta para acabado de bordes en confección.', 142.47, 7360.75, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela lona de algodón 12 oz', 'Tejido grueso para bolsas y calzado industrial.', 30.34, 1712.38, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela punto piqué antibacterial', 'Tejido tratado antimicrobiano para uniformes deportivos.', 106.08, 4118.4, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela seda charmeuse rollo 25m', 'Tela brillante y suave para prendas de gala.', 249.51, 2589.29, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela crepé de poliéster', 'Tela con textura arrugada para blusas formales.', 11.81, 14274.59, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de mezclilla denim rígido 16 oz', 'Denim de alto gramaje para ropa de trabajo pesado.', 160.84, 2369.72, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cinta elástica para tirantes', 'Elástico trenzado para tirantes de ropa deportiva.', 165.24, 600.23, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela algodón orgánico certificado GOTS', 'Tejido de algodón cultivado sin pesticidas.', 160.79, 14681.82, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (2, LAST_INSERT_ID());

-- Insumos Industriales (categoria 3)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Poliestireno de alto impacto (HIPS) saco 25kg', 'Resina termoplástica para inyección y termoformado.', 864.69, 27999.77, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Policarbonato en gránulo saco 25kg', 'Resina de alta resistencia al impacto y transparencia.', 268.5, 14984.64, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nylon 6.6 reforzado con fibra de vidrio', 'Polímero técnico para piezas de alta resistencia mecánica.', 175.37, 30991.55, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('PET reciclado en escamas saco 25kg', 'Materia prima reciclada para fabricación de envases.', 537.27, 31272.67, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aditivo antiestático para plásticos', 'Compuesto que reduce la acumulación de electricidad estática.', 336.37, 9310.15, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Colorante master batch azul concentrado', 'Pigmento concentrado para coloración de plásticos.', 813.4, 39404.58, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resina epóxica industrial bicomponente', 'Adhesivo estructural de alta resistencia química.', 854.1, 32340.1, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Silicona industrial RTV 25 kg', 'Elastómero de curado a temperatura ambiente para moldes.', 820.15, 29724.98, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fibra de vidrio tipo E rollo 45kg', 'Refuerzo textil para materiales compuestos.', 234.47, 20946.73, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resina poliéster insaturada tambor 200 L', 'Resina líquida para laminado de fibra de vidrio.', 362.01, 1644.72, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cera de parafina industrial 25 kg', 'Cera refinada para uso en velas y recubrimientos.', 37.66, 11537.03, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite hidráulico ISO 46 tambor 200 L', 'Fluido hidráulico para maquinaria industrial.', 266.58, 27854.62, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grafito en polvo industrial 25 kg', 'Lubricante sólido y aditivo conductor.', 956.95, 18165.49, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido esteárico industrial 25 kg', 'Materia prima para fabricación de jabones y plásticos.', 937.65, 39527.5, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bentonita sódica activada 25 kg', 'Arcilla industrial usada en fundición y perforación.', 955.45, 14903.12, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Silicato de sodio líquido tambor 200 L', 'Compuesto usado en detergentes y fundición.', 228.26, 9460.41, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espuma de poliuretano rígida en bloque', 'Material aislante térmico para construcción e industria.', 204.74, 8572.75, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caucho SBR en pacas 25 kg', 'Elastómero sintético para fabricación de llantas y bandas.', 627.83, 36062.18, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Adhesivo hot melt en barra', 'Pegamento termofusible para empaque industrial.', 842.03, 19439.2, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Talco industrial micronizado 25 kg', 'Carga mineral para plásticos, pinturas y cerámica.', 656.45, 32085.93, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Óxido de zinc industrial 25 kg', 'Aditivo vulcanizante para la industria del hule.', 93.93, 26593.13, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Carbonato de calcio precipitado 25 kg', 'Carga mineral usada en plásticos, pinturas y papel.', 910.68, 31400.96, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resina fenólica en polvo 25 kg', 'Resina termoestable para moldeo de piezas industriales.', 752.64, 19382.29, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Poliuretano líquido bicomponente tambor', 'Sistema de espuma rígida de dos componentes.', 186.74, 31670.85, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite dieléctrico para transformadores tambor 200L', 'Aceite mineral aislante para equipo eléctrico.', 339.19, 32132.53, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sellador de silicón industrial cartucho 300ml', 'Sellador estructural resistente a intemperie.', 971.94, 16135.62, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fibra de carbono en rollo 50 kg', 'Material compuesto de alta resistencia y bajo peso.', 407.37, 37898.48, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resina acrílica en emulsión tambor 200L', 'Base para pinturas y recubrimientos industriales.', 727.55, 7215.14, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cinta de teflón industrial rollo', 'Cinta selladora para uniones roscadas de tubería.', 135.77, 6470.45, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Poliestireno expandido (EPS) en bloque', 'Material aislante ligero usado en construcción y empaque.', 905.8, 32356.83, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resina de poliuretano para calzado', 'Materia prima para suelas y componentes de calzado.', 154.71, 33147.16, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite de corte soluble tambor 200L', 'Refrigerante lubricante para maquinado de metales.', 980.5, 26462.1, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nitrógeno líquido industrial contenedor Dewar', 'Gas criogénico para procesos industriales y de enfriamiento.', 356.9, 22172.07, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido cítrico industrial saco 25kg', 'Aditivo usado en la industria alimenticia y de limpieza.', 139.67, 1062.6, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sosa cáustica en escamas saco 25kg', 'Compuesto químico industrial usado en múltiples procesos.', 971.18, 26162.15, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resina de melamina en polvo 25 kg', 'Resina termoestable para laminados y vajillas.', 531.32, 37378.18, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cera microcristalina 25 kg', 'Cera de petróleo usada en recubrimientos y adhesivos.', 439.47, 34933.85, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('PVC rígido en polvo saco 25kg', 'Resina para fabricación de tubería y perfiles.', 827.89, 8836.17, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Látex de caucho natural tambor 200L', 'Materia prima para guantes y productos moldeados.', 259.32, 12072.18, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite lubricante para engranajes tambor 200L', 'Lubricante de alta viscosidad para reductores industriales.', 248.13, 23664.27, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (3, LAST_INSERT_ID());

-- Calzado (categoria 4)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tenis Nike Air Max 270', 'Calzado deportivo con amortiguación de aire visible.', 4.11, 2630.27, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tenis Adidas Ultraboost 22', 'Calzado running con entresuela Boost de alto retorno.', 2.23, 5478.1, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota industrial casquillo de acero', 'Calzado de seguridad con puntera de acero y suela antiderrapante.', 5.5, 2857.33, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato de vestir Florsheim piel', 'Calzado formal de piel genuina para caballero.', 8.88, 5444.92, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sandalia Birkenstock Arizona', 'Sandalia con plantilla de corcho anatómico.', 6.48, 5522.78, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota vaquera piel de res', 'Calzado tradicional con tacón cubano y bordado.', 7.67, 3284.58, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapatilla Converse Chuck Taylor All Star', 'Calzado casual de lona con suela de goma vulcanizada.', 8.0, 308.49, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato escolar Flexi piel negra', 'Calzado escolar resistente con agujetas.', 6.77, 1262.03, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota de montaña Merrell Moab 3', 'Calzado outdoor con membrana impermeable y suela Vibram.', 0.36, 4835.19, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato tipo Oxford piel charol', 'Calzado formal de vestir con cordones.', 2.83, 2946.26, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chancla PVC playa unisex', 'Calzado ligero de goma para uso en playa y alberca.', 10.96, 3427.56, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota de hule para lluvia', 'Calzado impermeable de PVC para trabajo agrícola.', 5.09, 3206.42, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato de seguridad dieléctrico', 'Calzado industrial sin partes metálicas para trabajo eléctrico.', 8.46, 4748.78, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tenis Skechers memory foam', 'Calzado casual con plantilla de espuma viscoelástica.', 1.86, 3449.72, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapatilla de ballet lona rosa', 'Calzado suave de práctica para danza clásica.', 3.95, 1806.12, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota táctica militar cordura', 'Calzado resistente para uso operativo y exteriores.', 11.65, 3144.74, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato Crocs Classic Clog', 'Calzado ligero de espuma Croslite antiderrapante.', 8.56, 4607.96, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato de golf FootJoy impermeable', 'Calzado deportivo con tacos para mejor tracción en pasto.', 13.71, 2770.84, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota para nieve Sorel Caribou', 'Calzado térmico impermeable para clima extremo.', 9.3, 3132.21, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Huarache artesanal piel trenzada', 'Calzado tradicional mexicano tejido a mano.', 7.83, 4217.84, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapatilla de futbol Puma Future Z', 'Calzado deportivo con tacos para superficie de pasto.', 6.95, 3293.06, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato ortopédico con plantilla removible', 'Calzado terapéutico para pie diabético o sensible.', 7.33, 5660.71, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota motociclista de piel reforzada', 'Calzado con protección de tobillo para motociclismo.', 10.58, 5283.91, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sandalia deportiva Teva con velcro', 'Calzado outdoor ajustable para senderismo ligero.', 14.15, 1705.64, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapatilla de baloncesto Jordan Retro', 'Calzado deportivo con amortiguación Air para impactos.', 8.52, 5670.95, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato mocasín de gamuza', 'Calzado casual sin agujetas de piel gamuza.', 12.65, 995.38, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota de trabajo con puntera compuesta', 'Calzado de seguridad no metálico apto para detectores.', 2.09, 2764.28, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tenis de skate Vans Old Skool', 'Calzado de lona con refuerzo lateral y suela waffle.', 1.37, 1595.7, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato bebé primeros pasos suela flexible', 'Calzado infantil antiderrapante para aprender a caminar.', 1.37, 4082.94, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota de esquí rígida con hebillas', 'Calzado técnico para deportes de nieve alpinos.', 11.82, 5402.75, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapatilla de yoga con suela antiderrapante', 'Calzado ligero y flexible para práctica de yoga.', 2.57, 4353.5, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato de charol para ceremonia', 'Calzado formal brillante para eventos y bodas.', 10.01, 1029.28, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota de trabajo impermeable Timberland Pro', 'Calzado industrial con membrana impermeable y aislamiento.', 13.28, 5811.76, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sandalia ortopédica con velcro ajustable', 'Calzado cómodo con soporte de arco plantar.', 3.53, 5724.52, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato tenis para correr trail Salomon', 'Calzado con suela de tracción agresiva para terreno irregular.', 6.15, 3026.11, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota de hule industrial antiderrapante', 'Calzado resistente a químicos para uso en plantas industriales.', 14.85, 5028.18, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapatilla de ciclismo con calas SPD', 'Calzado rígido compatible con pedales automáticos.', 2.67, 2702.83, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato náutico de piel Sperry', 'Calzado casual con suela de goma antiderrapante para embarcaciones.', 7.88, 2166.87, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bota militar desértica color arena', 'Calzado transpirable para climas cálidos y terreno árido.', 3.18, 2047.45, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zapato para niño con luces LED', 'Calzado infantil casual con suela luminosa al caminar.', 10.92, 313.0, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (4, LAST_INSERT_ID());

-- Maquinaria (categoria 5)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Soldadora inversora Lincoln Electric 200A', 'Equipo de soldadura MMA/TIG portátil de alta eficiencia.', 2792.55, 404805.42, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grúa hidráulica tipo pluma 5 toneladas', 'Grúa móvil para levantamiento de cargas industriales.', 139.51, 308375.63, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Montacargas eléctrico Toyota 3 toneladas', 'Vehículo industrial para manejo de materiales en almacén.', 3138.44, 468352.12, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Prensa hidráulica de banco 20 toneladas', 'Equipo para procesos de prensado y conformado de piezas.', 368.24, 886798.67, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sierra cinta industrial para metal', 'Máquina de corte continuo para perfiles metálicos.', 3952.4, 874950.92, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cortadora láser CNC de fibra 3kW', 'Equipo de corte de precisión para láminas metálicas.', 568.66, 250024.38, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Dobladora de lámina hidráulica CNC', 'Máquina para plegado de lámina metálica de precisión.', 245.96, 704412.73, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Robot soldador industrial de 6 ejes', 'Brazo robótico automatizado para soldadura en línea de producción.', 1388.71, 129656.67, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Generador diésel industrial 100 kVA', 'Planta de emergencia para respaldo eléctrico industrial.', 2140.16, 821601.23, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bomba centrífuga industrial 50 HP', 'Equipo de bombeo para procesos de agua y líquidos industriales.', 4103.95, 243868.98, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Torno paralelo convencional 2 metros', 'Máquina herramienta para mecanizado de piezas cilíndricas.', 789.37, 828466.79, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rectificadora cilíndrica de precisión', 'Equipo para acabado fino de superficies metálicas.', 2874.44, 634869.44, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Compresor de pistón industrial 15 HP', 'Equipo generador de aire comprimido para planta.', 492.84, 65910.96, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mezcladora industrial de concreto 1 m3', 'Equipo para preparación de mezclas de construcción.', 3456.62, 391405.58, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Excavadora hidráulica Caterpillar 320', 'Maquinaria pesada para movimiento de tierra.', 408.45, 845439.49, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Retroexcavadora John Deere 310L', 'Equipo versátil para excavación y carga.', 3190.48, 724441.3, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Elevador de tijera hidráulico 1 tonelada', 'Plataforma de elevación para mantenimiento industrial.', 464.53, 772762.34, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Banda transportadora modular 10 metros', 'Sistema de transporte continuo para línea de producción.', 379.78, 778555.85, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Máquina inyectora de plástico 250 ton', 'Equipo para moldeo por inyección de piezas plásticas.', 2296.18, 315149.32, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Torre de enfriamiento industrial 50 ton', 'Equipo para disipación de calor en procesos industriales.', 2787.67, 835102.32, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Extrusora de plástico monotornillo', 'Máquina para producción de perfiles y láminas plásticas.', 1375.91, 129363.95, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Empacadora al vacío industrial', 'Equipo automatizado para empaque hermético de productos.', 2658.23, 226016.01, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cortadora de plasma CNC industrial', 'Máquina de corte de precisión para lámina metálica.', 591.78, 157882.45, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Trituradora de mandíbula industrial', 'Equipo para reducción de tamaño de material sólido.', 299.38, 193564.9, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Autoclave industrial de vapor 500L', 'Equipo de esterilización a presión para uso industrial.', 1594.36, 284929.78, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Máquina dobladora de tubo CNC', 'Equipo de precisión para curvado de tubería metálica.', 3809.52, 271615.34, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Torre de perforación portátil', 'Equipo para perforación de pozos de agua o exploración.', 2525.44, 172441.4, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Granalladora industrial de cabina', 'Equipo de limpieza de superficies metálicas por abrasión.', 1767.66, 31074.35, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Máquina de coser industrial recta', 'Equipo de alta velocidad para confección en serie.', 1289.72, 28581.31, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cargador frontal Caterpillar 950', 'Maquinaria pesada para carga y movimiento de materiales.', 3678.75, 502678.48, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Torno CNC vertical de precisión', 'Máquina herramienta controlada numéricamente para piezas grandes.', 987.81, 435163.17, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bomba de vacío industrial rotativa', 'Equipo para generación de vacío en procesos industriales.', 4676.48, 109058.99, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Horno industrial de tratamiento térmico', 'Equipo para templado y revenido de piezas metálicas.', 4103.65, 397477.16, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sistema de riego por aspersión industrial', 'Equipo automatizado para riego agrícola de gran escala.', 2500.26, 753633.33, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grúa torre para construcción', 'Equipo de elevación fijo para obras de gran altura.', 1995.78, 463417.07, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Plataforma elevadora articulada 15 metros', 'Equipo de acceso para trabajo en altura.', 3454.32, 884459.88, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Compactadora vibratoria de suelo', 'Equipo para compactación de terracerías en construcción.', 1746.39, 751573.59, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Máquina de corte por chorro de agua', 'Equipo de precisión para corte de materiales diversos.', 3548.29, 577839.6, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cizalla hidráulica industrial para lámina', 'Equipo de corte recto para láminas metálicas gruesas.', 2053.25, 322583.68, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fresadora universal de banco', 'Máquina herramienta para fresado de piezas de precisión.', 319.22, 129889.44, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (5, LAST_INSERT_ID());

-- Componentes Electrónicos (categoria 6)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Microprocesador AMD Ryzen 9 7950X', 'Procesador de 16 núcleos para equipos de alto rendimiento.', 0.36, 18535.19, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tarjeta madre ASUS ROG Strix Z790', 'Placa base para procesadores Intel de última generación.', 1.29, 4123.0, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tarjeta gráfica NVIDIA RTX 4070', 'GPU dedicada para gaming y renderizado 3D.', 0.43, 21039.66, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Memoria RAM Corsair Vengeance 16GB DDR5', 'Módulo de memoria de alta velocidad para PC.', 4.35, 16780.06, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Disco duro Seagate Barracuda 4TB', 'Unidad de almacenamiento mecánico para uso general.', 1.42, 6093.21, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fuente de poder EVGA 750W 80 Plus Gold', 'Fuente de alimentación certificada de alta eficiencia.', 1.47, 11513.35, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chip controlador ARM Cortex-M4', 'Microcontrolador para aplicaciones embebidas de bajo consumo.', 0.8, 11173.32, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sensor de proximidad infrarrojo Sharp', 'Componente electrónico para detección de objetos cercanos.', 1.32, 24046.57, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Capacitor electrolítico 1000uF 25V', 'Componente pasivo para filtrado de corriente en circuitos.', 4.86, 13699.48, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resistencia de precisión 1% SMD', 'Componente pasivo de montaje superficial para circuitos.', 1.23, 24143.39, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Circuito integrado amplificador operacional LM358', 'Chip analógico para amplificación de señales.', 1.55, 8946.77, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Módulo Wi-Fi ESP32 para IoT', 'Módulo con conectividad Wi-Fi y Bluetooth integrada.', 0.02, 9571.58, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pantalla LCD táctil de 7 pulgadas', 'Módulo de visualización con controlador táctil capacitivo.', 2.38, 12593.96, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Transistor de potencia MOSFET IRF540', 'Semiconductor de conmutación para circuitos de potencia.', 1.01, 12643.15, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable flex FPC para pantallas de celular', 'Conector flexible para conexión de pantallas móviles.', 0.03, 6641.01, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Batería de litio 18650 recargable', 'Celda de litio recargable para dispositivos electrónicos.', 0.46, 10017.8, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa Arduino Uno R3', 'Plataforma de desarrollo de hardware libre para prototipos.', 0.22, 611.23, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa Raspberry Pi 5 8GB', 'Computadora de placa única para desarrollo y automatización.', 1.53, 5858.6, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Diodo rectificador de silicio 1N4007', 'Semiconductor para rectificación de corriente alterna.', 2.93, 13253.28, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Módulo relevador de 4 canales 5V', 'Módulo electromecánico para control de cargas de alta potencia.', 3.76, 16455.71, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cristal oscilador de cuarzo 16MHz', 'Componente de referencia de frecuencia para microcontroladores.', 3.58, 21983.31, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Conector USB tipo C hembra SMD', 'Componente de montaje superficial para carga y datos.', 1.95, 8187.06, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chip de memoria flash NAND 128GB', 'Circuito integrado de almacenamiento no volátil.', 4.92, 3779.11, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ventilador para CPU Noctua NF-A12x25', 'Ventilador de refrigeración silencioso para procesadores.', 3.62, 16098.33, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Disipador de calor de aluminio para CPU', 'Componente pasivo para disipación térmica en procesadores.', 0.23, 20890.47, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Módulo GPS NEO-6M', 'Receptor de posicionamiento satelital para proyectos embebidos.', 4.46, 15701.94, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable HDMI 2.1 de alta velocidad 2m', 'Cable de video digital para resolución 4K/8K.', 3.67, 20314.86, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tarjeta de sonido Creative Sound Blaster', 'Tarjeta de audio dedicada para PC de escritorio.', 0.71, 13117.74, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sensor de temperatura DS18B20', 'Sensor digital de temperatura resistente al agua.', 2.53, 20881.69, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Adaptador de red Ethernet Gigabit PCIe', 'Tarjeta de red para conexión cableada de alta velocidad.', 4.03, 20668.91, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Regulador de voltaje LM7805', 'Circuito integrado regulador de tensión fija de 5V.', 2.92, 22326.1, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pantalla OLED de 0.96 pulgadas I2C', 'Módulo de visualización pequeño para proyectos electrónicos.', 3.42, 17348.49, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Router inalámbrico TP-Link Archer AX55', 'Equipo de red Wi-Fi 6 para hogar y oficina.', 1.16, 827.46, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Módulo bluetooth HC-05', 'Módulo de comunicación inalámbrica de corto alcance.', 0.67, 9049.65, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Teclado mecánico Logitech G Pro X', 'Periférico de entrada con switches intercambiables.', 0.53, 20903.74, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mouse óptico Logitech MX Master 3', 'Periférico ergonómico de alta precisión para productividad.', 2.8, 15712.79, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara de módulo CSI para Raspberry Pi', 'Módulo de cámara compacto para visión embebida.', 3.13, 17032.57, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Switch de red Cisco Catalyst 24 puertos', 'Equipo de conmutación para redes empresariales.', 2.45, 132.69, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cargador USB-C GaN 65W', 'Cargador rápido de tecnología nitruro de galio.', 3.99, 18719.22, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chip controlador de motor paso a paso A4988', 'Driver electrónico para control de motores en impresoras 3D.', 2.52, 13403.24, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (6, LAST_INSERT_ID());

-- Bebidas Alcohólicas (categoria 7)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tequila Don Julio Reposado 750 ml', 'Tequila reposado añejado en barricas de roble americano.', 13.36, 1130.85, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vodka Absolut 750 ml', 'Vodka sueco destilado a partir de trigo.', 14.87, 3895.07, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ron Bacardí Carta Blanca 750 ml', 'Ron blanco filtrado con carbón para máxima suavidad.', 1.95, 4093.54, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Champagne Moët & Chandon Brut Impérial 750 ml', 'Champán francés con notas de frutas y brioche.', 14.72, 3197.48, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerveza artesanal IPA 6 pack 355 ml', 'Cerveza estilo India Pale Ale con notas cítricas.', 14.93, 14639.67, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Whisky Jack Daniel''s Old No. 7 750 ml', 'Whisky americano filtrado con carbón de arce.', 10.13, 5831.02, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino blanco Chardonnay reserva 750 ml', 'Vino blanco seco con notas de vainilla y roble.', 9.84, 10302.89, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gin Bombay Sapphire 750 ml', 'Ginebra premium destilada con 10 botánicos.', 15.46, 9312.06, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mezcal artesanal espadín 750 ml', 'Mezcal de agave espadín elaborado de forma tradicional.', 13.03, 1300.46, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Licor de café Kahlúa 750 ml', 'Licor mexicano de café con notas de vainilla y ron.', 3.37, 3921.01, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino tinto Cabernet Sauvignon reserva 750 ml', 'Vino tinto con cuerpo y taninos maduros.', 14.99, 4670.59, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerveza Corona Extra 24 pack 355 ml', 'Cerveza clara tipo lager de sabor suave.', 11.57, 335.17, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Brandy Torres 10 años 700 ml', 'Brandy español añejado en barricas de roble.', 1.68, 4141.28, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tequila Herradura Blanco 750 ml', 'Tequila blanco 100% agave de sabor herbal.', 13.6, 10428.95, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino espumoso Cava Freixenet 750 ml', 'Vino espumoso español elaborado por método tradicional.', 13.68, 4469.22, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Whisky escocés Glenfiddich 12 años 750 ml', 'Single malt escocés con notas de pera y roble.', 10.57, 7050.24, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ron Zacapa Centenario 23 años 750 ml', 'Ron guatemalteco añejado con sistema Solera.', 9.59, 1909.77, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino rosado Provenza 750 ml', 'Vino rosado francés seco y afrutado.', 17.93, 3108.86, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Licor de naranja Cointreau 700 ml', 'Licor triple seco elaborado con cáscaras de naranja.', 19.57, 14053.38, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerveza Guinness Stout lata 440 ml', 'Cerveza negra irlandesa cremosa tipo stout.', 0.84, 6965.72, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tequila Patrón Añejo 750 ml', 'Tequila añejo 100% agave con notas de caramelo.', 16.49, 14526.41, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino tinto Malbec Trapiche 750 ml', 'Vino argentino con notas de frutos rojos maduros.', 9.26, 4139.56, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vodka Grey Goose 750 ml', 'Vodka francés elaborado con trigo de invierno.', 4.59, 14191.97, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sidra de manzana Woodpecker 500 ml', 'Bebida fermentada de manzana con burbujas naturales.', 4.61, 8784.86, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ron Havana Club Añejo 7 años 750 ml', 'Ron cubano añejado con notas de vainilla y especias.', 3.26, 7932.38, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino blanco Sauvignon Blanc 750 ml', 'Vino blanco fresco con notas cítricas y herbales.', 19.08, 2119.19, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Whisky japonés Suntory Toki 700 ml', 'Whisky japonés suave, ideal para highball.', 16.49, 7704.85, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerveza Heineken 12 pack 355 ml', 'Cerveza lager premium de origen holandés.', 17.79, 10594.56, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Licor de menta Peppermint Schnapps 750 ml', 'Licor dulce con intenso sabor a menta.', 5.01, 13480.93, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino tinto Rioja Crianza 750 ml', 'Vino español envejecido en barrica y botella.', 9.98, 518.79, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aperitivo Aperol 750 ml', 'Aperitivo italiano de color naranja con notas cítricas.', 0.57, 7451.69, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tequila Cazadores Reposado 750 ml', 'Tequila reposado con notas suaves de agave cocido.', 9.29, 4633.97, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerveza Modelo Especial 24 pack 355 ml', 'Cerveza pilsner mexicana de sabor balanceado.', 3.24, 5257.81, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ginebra Hendrick''s 750 ml', 'Ginebra escocesa infusionada con pepino y rosas.', 6.66, 12627.43, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino espumoso Prosecco DOC 750 ml', 'Vino espumoso italiano ligero y afrutado.', 0.53, 11298.4, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Whisky Chivas Regal 18 años 750 ml', 'Blended scotch whisky de gran complejidad aromática.', 16.86, 1932.61, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Licor de almendra Amaretto Disaronno 750 ml', 'Licor italiano de sabor a almendra.', 18.56, 10738.4, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ron Bacardí Añejo 8 años 750 ml', 'Ron añejado con notas de roble y frutos secos.', 18.08, 4454.02, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vino tinto Pinot Noir 750 ml', 'Vino tinto ligero con notas de cereza y frambuesa.', 7.76, 5984.56, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerveza Stella Artois 12 pack 355 ml', 'Cerveza lager belga premium de sabor suave.', 19.98, 8899.27, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (7, LAST_INSERT_ID());

-- Acero y Metales (categoria 8)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de acero inoxidable 304 calibre 16', 'Lámina resistente a corrosión para uso industrial.', 1094.91, 38810.72, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo redondo de acero cédula 40 6 metros', 'Tubería metálica para estructuras y conducción.', 839.96, 4819.99, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfil PTR cuadrado 2x2 pulgadas 6m', 'Perfil tubular estructural para construcción metálica.', 323.1, 75203.5, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ángulo de acero 2x2x1/4 barra 6m', 'Perfil en L usado en estructuras metálicas.', 871.16, 84235.3, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa de acero al carbón 1/2 pulgada', 'Placa gruesa para fabricación de estructuras pesadas.', 762.99, 24282.66, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Alambre galvanizado calibre 12 rollo 25kg', 'Alambre resistente a corrosión para cercado.', 1542.67, 17491.49, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla ciclónica galvanizada 2 metros', 'Malla metálica para cercado perimetral.', 1132.58, 86076.79, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Solera de acero 2x1/4 pulgadas barra 6m', 'Perfil rectangular sólido para fabricación metálica.', 2655.11, 73170.62, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aluminio en lámina calibre 18', 'Lámina ligera y resistente a la corrosión.', 1900.07, 82251.44, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo cuadrado de aluminio 1x1 pulgada', 'Perfil de aluminio para estructuras ligeras.', 2823.28, 49655.92, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de cobre calibre 20', 'Material conductor usado en techado e instalaciones.', 2164.33, 4928.11, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Varilla de acero inoxidable 316L', 'Barra metálica resistente a ambientes corrosivos.', 2202.41, 40852.01, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa de bronce fosfórico', 'Aleación de cobre usada en componentes de fricción.', 2262.95, 58181.92, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo estructural rectangular 4x2 pulgadas', 'Perfil metálico para columnas y marcos estructurales.', 872.9, 4883.43, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina antiderrapante (diamantada) calibre 10', 'Lámina de acero con relieve para pisos industriales.', 2781.8, 11894.36, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfil canal C galvanizado 6 metros', 'Perfil estructural ligero para tabla roca y construcción.', 1427.11, 31257.83, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Barra redonda de acero 1020 lisa', 'Barra de acero al carbono para maquinado.', 907.36, 66643.41, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla electrosoldada 6x6 calibre 10', 'Malla de refuerzo para losas de concreto.', 2929.36, 23785.13, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina galvanizada acanalada calibre 26', 'Lámina para techado industrial y residencial.', 1974.87, 27424.85, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo cédula 40 galvanizado 3 pulgadas', 'Tubería resistente a corrosión para instalaciones hidráulicas.', 1680.82, 35795.92, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa antiderrapante de aluminio', 'Lámina texturizada para pisos y rampas.', 518.65, 14968.3, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfil tubular redondo de acero inoxidable', 'Tubo metálico decorativo y estructural resistente.', 639.46, 81583.41, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Alambrón de acero 5.5mm rollo', 'Materia prima para fabricación de clavos y alambre.', 1501.29, 20192.26, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de acero para troquelado calibre 20', 'Lámina metálica utilizada en procesos de estampado.', 2720.65, 89684.52, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfil de aluminio estructural serie 4080', 'Perfil extruido para estructuras modulares industriales.', 1360.88, 12993.85, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo galvanizado cédula 40 2 pulgadas', 'Tubería roscable para instalaciones de agua y gas.', 593.37, 8618.95, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Solera de aluminio 1x1/8 pulgadas', 'Perfil rectangular ligero para fabricación en general.', 1039.03, 8652.94, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa de acero A36 3/4 pulgada', 'Placa estructural para fabricación de maquinaria pesada.', 732.6, 23623.0, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Varilla roscada galvanizada 1/2 pulgada', 'Barra roscada para anclajes y fijaciones estructurales.', 1717.46, 79909.01, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfil IPR (viga I) 6 pulgadas', 'Viga estructural de acero para construcción de naves industriales.', 2253.98, 37443.96, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de zinc calibre 24', 'Lámina resistente a la corrosión para techado.', 1253.37, 47413.05, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tornillería industrial hexagonal grado 8', 'Tornillos de alta resistencia para uniones estructurales.', 1143.06, 30769.18, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo redondo de cobre tipo L', 'Tubería de cobre para instalaciones hidráulicas y de gas.', 204.94, 25337.71, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfil angular de acero galvanizado 3x3', 'Ángulo estructural resistente a la intemperie.', 2903.7, 11765.71, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa de acero para blindaje AR500', 'Placa de acero endurecido de alta resistencia balística.', 1520.12, 56851.61, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla de acero inoxidable tejida', 'Malla filtrante para procesos industriales.', 2591.33, 19828.7, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Barra cuadrada de acero 1 pulgada', 'Barra sólida para fabricación de piezas mecanizadas.', 827.64, 22736.6, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina rolada en frío calibre 18', 'Lámina de acero de alta precisión dimensional.', 1211.28, 40404.33, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo estructural redondo cédula 30', 'Perfil tubular para columnas y estructuras ligeras.', 2862.75, 76457.19, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Placa de titanio grado 5', 'Aleación de alta resistencia y ligereza para uso aeroespacial.', 2621.22, 2452.04, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (8, LAST_INSERT_ID());

-- Productos Agropecuarios (categoria 9)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mango Ataulfo caja 4 kg', 'Mango de pulpa suave y dulce, variedad de exportación.', 37.08, 10671.73, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papaya maradol caja 10 kg', 'Fruta tropical de pulpa naranja y sabor dulce.', 896.22, 7151.7, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fresa fresca charola 2 kg', 'Fresa de mesa fresca para consumo directo.', 589.24, 102.66, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cebolla blanca costal 25 kg', 'Hortaliza de bulbo para uso culinario general.', 394.56, 13909.73, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papa blanca costal 25 kg', 'Tubérculo de uso general para consumo y procesamiento.', 826.46, 12846.39, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zanahoria fresca costal 20 kg', 'Hortaliza de raíz rica en betacarotenos.', 972.38, 3802.13, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chile jalapeño caja 10 kg', 'Chile fresco picante usado en gastronomía mexicana.', 113.5, 2400.24, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pepino fresco caja 15 kg', 'Hortaliza fresca de alto contenido de agua.', 524.75, 10262.92, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Uva sin semilla caja 8.2 kg', 'Uva de mesa dulce para exportación.', 941.78, 10853.86, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Naranja Valencia costal 20 kg', 'Cítrico jugoso usado para consumo directo y jugo.', 649.11, 11495.53, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Brócoli fresco caja 9 kg', 'Hortaliza crucífera fresca para consumo en fresco.', 460.04, 8317.36, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espárrago verde caja 5 kg', 'Hortaliza fina de exportación de alto valor comercial.', 44.35, 11756.25, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Piña MD2 caja 12 kg', 'Fruta tropical dulce de pulpa amarilla.', 236.41, 13806.81, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sandía sin semilla caja 18 kg', 'Fruta de verano refrescante y de gran tamaño.', 647.28, 4626.36, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Plátano tabasco caja 18 kg', 'Fruta tropical de consumo diario, rica en potasio.', 132.33, 3851.73, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ajo blanco costal 10 kg', 'Bulbo aromático usado como condimento culinario.', 638.11, 10508.87, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lechuga romana caja 24 piezas', 'Hortaliza de hoja para ensaladas frescas.', 116.57, 1148.24, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Berenjena fresca caja 11 kg', 'Hortaliza de piel morada para uso culinario.', 526.81, 8785.08, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Calabacita italiana caja 10 kg', 'Hortaliza de verano de consistencia suave.', 391.14, 3431.39, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fresa congelada IQF bolsa 10 kg', 'Fruta congelada individualmente para uso industrial.', 603.06, 255.88, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Limón persa costal 20 kg', 'Cítrico ácido de exportación, sin semillas.', 305.01, 6964.29, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Manzana Golden Delicious caja 18 kg', 'Manzana de pulpa firme y sabor dulce.', 959.15, 9704.18, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Apio fresco caja 24 piezas', 'Hortaliza de tallo crujiente usado en cocina y jugos.', 884.36, 7182.03, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chile poblano caja 10 kg', 'Chile fresco de sabor suave usado en platillos tradicionales.', 238.59, 3781.17, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Coliflor fresca caja 12 piezas', 'Hortaliza crucífera de floretes blancos.', 960.81, 10599.34, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aguacate Hass caja 10 kg', 'Fruto cremoso de exportación con alto contenido de grasas saludables.', 310.86, 424.63, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Toronja roja costal 20 kg', 'Cítrico de pulpa rosada, ligeramente amargo.', 500.82, 10149.5, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Melón cantaloupe caja 9 piezas', 'Fruta dulce de verano con pulpa anaranjada.', 422.92, 3933.12, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espinaca fresca caja 4 kg', 'Hoja verde rica en hierro para consumo fresco.', 669.02, 13884.9, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nopal fresco sin espinas caja 20 kg', 'Verdura tradicional mexicana usada en múltiples platillos.', 230.65, 608.05, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Frijol pinto grano costal 25 kg', 'Leguminosa básica para consumo humano.', 341.36, 6366.3, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Maíz blanco en grano costal 40 kg', 'Grano base para producción de tortilla y nixtamal.', 684.15, 3051.39, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sorgo forrajero costal 40 kg', 'Grano usado como alimento para ganado.', 798.08, 11113.03, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Alfalfa achicalada paca 25 kg', 'Forraje seco de alto valor nutricional para ganado.', 507.35, 3157.76, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Café cereza recién cortado costal 45 kg', 'Fruto de café recién cosechado para beneficio.', 970.01, 4744.56, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cacao en baba costal 30 kg', 'Fruto de cacao fresco para proceso de fermentación.', 820.9, 3539.05, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Miel de abeja a granel tambor 300 kg', 'Miel natural sin procesar de producción apícola.', 225.34, 11431.01, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Huevo blanco caja 360 piezas', 'Huevo de gallina para consumo humano a granel.', 298.46, 14283.71, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Leche bronca a granel tanque 1000 L', 'Leche cruda de vaca para procesamiento industrial.', 498.29, 2890.97, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tomate saladette caja 15 kg', 'Jitomate de exportación usado en cocina y salsas.', 227.21, 6313.73, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (9, LAST_INSERT_ID());

-- Vehículos (categoria 10)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Honda Civic 2024', 'Sedán compacto con motor 2.0L y transmisión CVT.', 16665.83, 3323226.5, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Nissan Versa 2024', 'Sedán económico con buen rendimiento de combustible.', 3744.94, 1407436.92, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Mazda 3 2024', 'Sedán deportivo con diseño Kodo y motor Skyactiv.', 5402.43, 3410712.98, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta SUV Chevrolet Traverse 2024', 'SUV familiar de 7 pasajeros con motor V6.', 3633.59, 228849.87, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta pickup Chevrolet Silverado 2024', 'Pickup de trabajo pesado con caja de carga larga.', 1597.37, 1406959.85, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motocicleta Yamaha MT-07 2024', 'Motocicleta naked de doble cilindro para uso urbano.', 22464.37, 3098363.55, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motocicleta Kawasaki Ninja 400 2024', 'Motocicleta deportiva de entrada con carenado completo.', 18344.82, 3491477.83, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camión de carga Kenworth T680', 'Tractocamión para transporte de carga pesada de larga distancia.', 23296.73, 1185887.52, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Autobús urbano Mercedes-Benz OF 1721', 'Autobús de piso alto para transporte de pasajeros.', 4719.25, 3278791.35, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil eléctrico Tesla Model 3', 'Sedán eléctrico de alto rendimiento y autonomía extendida.', 18683.08, 160033.22, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta Toyota Hilux doble cabina', 'Pickup todo terreno con tracción 4x4.', 16644.3, 1356236.99, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Volkswagen Jetta 2024', 'Sedán compacto con motor turbo de 1.4L.', 9409.7, 1194356.34, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta Ford Explorer 2024', 'SUV de tamaño medio con capacidad para 7 pasajeros.', 4314.6, 59904.0, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motocicleta Harley-Davidson Sportster S', 'Motocicleta cruiser de motor V-twin Revolution Max.', 7067.18, 1262560.67, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camión de volteo Freightliner 114SD', 'Camión de trabajo pesado para transporte de materiales.', 23892.32, 476793.57, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Kia Forte 2024', 'Sedán compacto con equipamiento tecnológico completo.', 24110.35, 765538.39, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta RAM 1500 4x4', 'Pickup de trabajo con suspensión neumática y motor Hemi.', 8980.07, 2884428.98, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Autobús foráneo Volvo 9700', 'Autobús de lujo para viajes de larga distancia.', 20568.0, 1541950.2, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Hyundai Elantra 2024', 'Sedán compacto con diseño aerodinámico y motor eficiente.', 1326.51, 1683450.98, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motocicleta Honda CBR600RR', 'Motocicleta deportiva supersport de 4 cilindros.', 9380.59, 3222297.15, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta Jeep Grand Cherokee 2024', 'SUV todo terreno con capacidades off-road de serie.', 4906.35, 1306658.58, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tractocamión International LT Series', 'Vehículo pesado para arrastre de remolques de carga.', 22435.13, 154473.09, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Subaru Impreza 2024', 'Sedán compacto con tracción integral simétrica.', 10328.97, 2850794.62, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta GMC Sierra 1500', 'Pickup de trabajo con paquete todo terreno.', 19190.03, 190240.72, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motocicleta BMW R 1250 GS', 'Motocicleta de aventura para largas travesías.', 967.87, 265900.8, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Chevrolet Equinox 2024', 'SUV compacta con motor turbo eficiente.', 23009.91, 936705.04, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camión refrigerado Isuzu NPR', 'Camión de reparto con caja refrigerada para carga perecedera.', 18707.44, 3150003.67, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Mitsubishi Mirage 2024', 'Hatchback económico de bajo consumo de combustible.', 8542.83, 989485.59, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta Ford Ranger 2024', 'Pickup mediana con motor turbo diésel disponible.', 23946.47, 2178575.76, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Autobús escolar Blue Bird Vision', 'Autobús diseñado para transporte seguro de estudiantes.', 6628.09, 2522393.33, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Toyota Camry Hybrid 2024', 'Sedán mediano híbrido de bajo consumo.', 7980.44, 1000924.63, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta Nissan Frontier 2024', 'Pickup mediana con tracción 4x4 disponible.', 193.91, 2657000.69, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motocicleta Suzuki GSX-R750', 'Motocicleta deportiva de alto rendimiento en pista.', 22919.84, 2237231.15, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camión tolva Mack Granite', 'Camión pesado para transporte de materiales a granel.', 23586.93, 133685.63, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil Audi A4 2024', 'Sedán ejecutivo con tecnología quattro de tracción integral.', 5923.27, 1689402.25, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta Toyota 4Runner 2024', 'SUV robusta con chasis de largueros para todo terreno.', 23923.76, 3340991.5, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motocicleta Ducati Monster 937', 'Motocicleta naked italiana de alto desempeño.', 9724.22, 916111.53, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Automóvil BMW Serie 3 2024', 'Sedán de lujo con motor turbo y suspensión deportiva.', 10805.46, 1752484.76, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camión cisterna Peterbilt 579', 'Camión para transporte de líquidos a granel.', 23209.68, 681140.35, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camioneta Honda CR-V 2024', 'SUV compacta familiar con motor turbo eficiente.', 20083.95, 2597783.65, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (10, LAST_INSERT_ID());

-- Productos Farmacéuticos (categoria 11)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Paracetamol 500mg caja 100 tabs', 'Analgésico y antipirético de uso común.', 24.7, 11603.5, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Omeprazol 20mg caja 30 cáps', 'Inhibidor de bomba de protones para reflujo gástrico.', 18.26, 4950.61, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Losartán 50mg caja 30 tabs', 'Antihipertensivo antagonista de receptores de angiotensina II.', 9.65, 5459.78, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Metformina 850mg caja 50 tabs', 'Antidiabético oral para control de glucosa.', 23.49, 1231.27, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Azitromicina 500mg caja 3 tabs', 'Antibiótico macrólido de amplio espectro.', 6.0, 11305.64, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Loratadina 10mg caja 20 tabs', 'Antihistamínico para tratamiento de alergias.', 7.49, 1017.76, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Insulina glargina 100 U/ml pluma precargada', 'Insulina de acción prolongada para diabetes.', 1.11, 8311.29, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Salbutamol inhalador 100mcg', 'Broncodilatador para tratamiento de asma y EPOC.', 9.84, 14704.82, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Diclofenaco 100mg caja 20 tabs', 'Antiinflamatorio no esteroideo para dolor e inflamación.', 26.52, 14817.97, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cefalexina 500mg caja 20 cáps', 'Antibiótico cefalosporínico de primera generación.', 8.02, 1307.03, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido acetilsalicílico 100mg caja 30 tabs', 'Antiagregante plaquetario para prevención cardiovascular.', 2.98, 7502.21, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vacuna contra hepatitis B dosis', 'Biológico para inmunización contra hepatitis B.', 21.32, 6732.1, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vacuna neumocócica conjugada dosis', 'Biológico para prevención de infecciones neumocócicas.', 7.1, 6281.77, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fluoxetina 20mg caja 30 cáps', 'Antidepresivo inhibidor selectivo de recaptura de serotonina.', 18.65, 10127.92, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Levotiroxina 100mcg caja 50 tabs', 'Hormona tiroidea sintética para hipotiroidismo.', 22.46, 12712.46, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Amlodipino 5mg caja 30 tabs', 'Antihipertensivo bloqueador de canales de calcio.', 19.97, 1861.41, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ranitidina 150mg caja 30 tabs', 'Antagonista H2 para tratamiento de acidez estomacal.', 25.24, 4442.04, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Naproxeno 500mg caja 20 tabs', 'Antiinflamatorio no esteroideo de acción prolongada.', 17.05, 5625.92, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Clopidogrel 75mg caja 28 tabs', 'Antiagregante plaquetario usado tras eventos cardiovasculares.', 22.17, 3027.89, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Prednisona 5mg caja 20 tabs', 'Corticosteroide para tratamiento antiinflamatorio sistémico.', 7.5, 3717.84, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Simvastatina 20mg caja 30 tabs', 'Reductor de colesterol de la familia de las estatinas.', 4.68, 13268.31, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Complejo B inyectable caja 5 amp', 'Suplemento vitamínico del complejo B en ampolletas.', 17.39, 4928.75, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Dextrometorfano jarabe 120 ml', 'Antitusivo de uso común para tos seca.', 11.94, 14887.11, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Suero oral electrolitos sobre', 'Solución de rehidratación oral para deshidratación leve.', 15.27, 3509.15, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Eritropoyetina 4000 UI jeringa prellenada', 'Hormona usada en tratamiento de anemia renal.', 24.27, 9817.23, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Metoclopramida 10mg caja 30 tabs', 'Antiemético procinético para náuseas y vómito.', 29.73, 1579.87, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Warfarina 5mg caja 30 tabs', 'Anticoagulante oral antagonista de vitamina K.', 14.3, 12295.59, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Budesonida inhalador 200mcg', 'Corticosteroide inhalado para tratamiento de asma.', 25.23, 13719.91, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ciprofloxacino 500mg caja 14 tabs', 'Antibiótico quinolónico de amplio espectro.', 1.31, 4440.48, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ondansetrón 8mg caja 10 tabs', 'Antiemético usado en quimioterapia y postoperatorio.', 3.66, 2884.12, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Enoxaparina 40mg jeringa prellenada', 'Anticoagulante de bajo peso molecular inyectable.', 29.19, 8768.75, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Furosemida 40mg caja 20 tabs', 'Diurético de asa para tratamiento de edema.', 27.91, 5614.94, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vacuna antitetánica dosis', 'Biológico para inmunización contra el tétanos.', 26.0, 6764.25, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hidroclorotiazida 25mg caja 30 tabs', 'Diurético tiazídico para hipertensión arterial.', 7.87, 11677.76, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tramadol 50mg caja 10 cáps', 'Analgésico opioide para dolor moderado a severo.', 28.38, 1631.41, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vitamina D3 2000 UI caja 60 tabs', 'Suplemento vitamínico para salud ósea.', 17.92, 9318.22, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Salmeterol/Fluticasona inhalador combinado', 'Broncodilatador combinado con corticosteroide para EPOC.', 6.61, 5562.19, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Amoxicilina/Ácido clavulánico 875mg caja 14 tabs', 'Antibiótico de amplio espectro con inhibidor de betalactamasas.', 4.33, 3099.45, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Metronidazol 500mg caja 20 tabs', 'Antimicrobiano usado en infecciones anaerobias y parasitarias.', 7.72, 9011.38, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Insulina rápida 100 U/ml frasco ámpula', 'Insulina de acción corta para control glucémico postprandial.', 19.58, 3091.45, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (11, LAST_INSERT_ID());

-- Alimentos Procesados (categoria 12)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sopa instantánea Maruchan sabor camarón', 'Sopa deshidratada de preparación rápida en vaso.', 0.38, 995.2, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Puré de tomate enlatado 800g', 'Puré de tomate concentrado para uso culinario.', 16.99, 571.73, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chícharos y zanahorias en lata 400g', 'Verduras cocidas envasadas listas para consumir.', 7.87, 626.16, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Salsa cátsup Heinz 397g', 'Salsa de tomate condimentada para acompañar alimentos.', 19.9, 1653.17, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mayonesa McCormick 890g', 'Aderezo cremoso a base de aceite vegetal y huevo.', 1.68, 322.14, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chocolate en polvo Nesquik 700g', 'Bebida de chocolate soluble para preparar con leche.', 9.94, 1659.41, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cereal de maíz Corn Flakes 500g', 'Cereal de desayuno listo para consumir con leche.', 16.02, 291.63, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Galletas María Gamesa paquete 800g', 'Galletas dulces tradicionales para consumo directo.', 4.18, 2092.31, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pasta espagueti Barilla 500g', 'Pasta de trigo duro para preparación tradicional italiana.', 10.3, 864.24, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Salsa de soya Kikkoman 592ml', 'Condimento fermentado de soya para cocina asiática.', 7.76, 2860.5, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Puré de papa instantáneo 200g', 'Puré de papa deshidratado de preparación rápida.', 7.88, 1708.23, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chile chipotle en adobo lata 380g', 'Chile ahumado en salsa de adobo listo para usar.', 8.99, 1261.01, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Leche condensada La Lechera 397g', 'Leche endulzada concentrada para repostería.', 21.62, 2989.93, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sardinas en salsa de tomate lata 425g', 'Pescado enlatado en salsa lista para consumir.', 9.16, 607.66, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Frijoles refritos La Costeña 430g', 'Frijol procesado listo para consumir o acompañar platillos.', 18.23, 626.93, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Consomé de pollo en polvo Knorr 1kg', 'Sazonador concentrado para caldos y guisados.', 0.25, 2706.86, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite de oliva extra virgen 500ml', 'Aceite prensado en frío para uso culinario.', 10.65, 2464.7, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chocolate en barra Hershey''s 100g', 'Chocolate de leche listo para consumo directo.', 10.21, 2650.86, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Néctar de durazno Del Valle 1L', 'Bebida de fruta procesada lista para consumir.', 11.58, 504.38, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Puré de manzana para bebé 113g', 'Alimento infantil procesado en presentación individual.', 0.47, 1663.61, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Crema de cacahuate Skippy 462g', 'Untable cremoso a base de cacahuate tostado.', 16.05, 2731.19, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vinagre blanco destilado 1L', 'Condimento ácido para uso culinario y de limpieza.', 2.32, 1874.14, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Salsa Valentina picante 370ml', 'Salsa picante mexicana tradicional para acompañar alimentos.', 9.33, 1523.3, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Harina de trigo Gold Medal 2kg', 'Harina refinada para repostería y panificación.', 3.73, 864.22, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Azúcar refinada estándar bolsa 2kg', 'Endulzante procesado de uso doméstico e industrial.', 13.08, 2777.99, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chocolate para mesa Abuelita 540g', 'Tableta de chocolate para preparar bebida caliente tradicional.', 2.81, 1481.72, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aderezo ranch Hidden Valley 475ml', 'Aderezo cremoso para ensaladas y botanas.', 20.14, 2901.29, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Puré de calabaza enlatado 425g', 'Verdura procesada lista para repostería o guisados.', 5.01, 397.42, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Café soluble Nescafé Clásico 200g', 'Café instantáneo de preparación rápida.', 23.58, 2927.13, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Té helado en polvo Lipton 1kg', 'Bebida en polvo para preparar té frío.', 12.12, 179.06, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sopa de fideo Knorr Suiza 71g', 'Sopa deshidratada de preparación rápida en sobre.', 23.16, 1175.93, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mole poblano en pasta Doña María 235g', 'Salsa tradicional mexicana lista para preparar.', 22.62, 1868.62, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cátsup de tamarindo Tajín 425g', 'Condimento agridulce picante para botanas.', 20.63, 497.62, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Barra de granola Quaker 6 pack', 'Snack procesado a base de avena y frutos secos.', 19.67, 681.78, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Leche evaporada Carnation 410ml', 'Leche concentrada sin azúcar para uso culinario.', 10.17, 2542.13, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gelatina en polvo sabor fresa 170g', 'Postre en polvo de preparación rápida.', 20.75, 565.24, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Salsa BBQ Kraft 510g', 'Salsa dulce ahumada para acompañar carnes asadas.', 5.53, 1211.24, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cocoa en polvo Hershey''s 226g', 'Cacao en polvo para repostería y bebidas.', 13.0, 1163.06, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pan de caja Bimbo blanco grande', 'Pan de molde procesado para consumo diario.', 3.16, 756.24, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Salsa verde enlatada La Costeña 210g', 'Salsa de tomate verde lista para consumir.', 18.15, 2693.94, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (12, LAST_INSERT_ID());

-- Químicos Industriales (categoria 13)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hipoclorito de sodio 13% tambor 200L', 'Desinfectante industrial usado en tratamiento de agua.', 30.14, 33871.89, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido clorhídrico 33% bidón 25L', 'Ácido industrial usado en tratamiento de metales.', 381.16, 2576.28, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hidróxido de potasio en escamas 25kg', 'Base fuerte usada en fabricación de jabones.', 420.72, 7328.54, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Peróxido de hidrógeno 50% bidón 25L', 'Oxidante fuerte usado en blanqueo y desinfección.', 303.76, 33138.09, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Metanol grado industrial tambor 200L', 'Alcohol industrial usado como solvente y combustible.', 317.25, 18580.98, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Xileno grado industrial bidón 20L', 'Solvente aromático usado en pinturas y recubrimientos.', 215.84, 35082.69, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido fosfórico 85% bidón 25L', 'Ácido usado en fertilizantes y tratamiento de superficies.', 218.61, 39632.91, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hidróxido de calcio (cal hidratada) saco 25kg', 'Compuesto usado en tratamiento de agua y construcción.', 228.93, 26469.65, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Etilenglicol grado industrial tambor 200L', 'Anticongelante industrial usado en sistemas de enfriamiento.', 21.45, 37247.85, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cloruro férrico solución 40% bidón 25L', 'Coagulante usado en tratamiento de aguas residuales.', 249.86, 14344.48, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido nítrico 68% bidón 25L', 'Ácido fuerte usado en procesos de metalizado y explosivos.', 384.15, 46864.5, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sulfato de aluminio granulado saco 25kg', 'Coagulante usado en potabilización de agua.', 234.56, 11020.27, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Amoniaco industrial 25% bidón 25L', 'Compuesto usado en refrigeración y fabricación de fertilizantes.', 241.88, 6692.44, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Formaldehído solución 37% tambor 200L', 'Conservador y desinfectante usado en la industria química.', 72.94, 26006.76, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cloruro de calcio en escamas saco 25kg', 'Compuesto usado para control de polvo y deshielo.', 54.94, 26685.44, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido acético glacial bidón 25L', 'Ácido orgánico usado en procesos textiles y alimenticios.', 259.98, 2733.78, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Percloroetileno grado industrial tambor 200L', 'Solvente usado en tintorerías y desengrasado.', 321.85, 5209.79, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nitrato de amonio grado técnico saco 25kg', 'Compuesto usado en fertilizantes y explosivos industriales.', 369.41, 46724.87, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Isopropanol 99% tambor 200L', 'Alcohol industrial usado como solvente y desinfectante.', 260.63, 3539.62, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bisulfito de sodio grado industrial saco 25kg', 'Reductor químico usado en tratamiento de aguas.', 256.92, 22858.4, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido bórico grado técnico saco 25kg', 'Compuesto usado como retardante de flama y antiséptico.', 475.93, 8430.29, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hipoclorito de calcio granular tambor 45kg', 'Desinfectante sólido para tratamiento de agua de piscinas.', 429.96, 59768.61, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tolueno diisocianato (TDI) tambor 200L', 'Materia prima para fabricación de espuma de poliuretano.', 368.72, 48954.87, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Silicato de potasio líquido tambor 200L', 'Compuesto usado en recubrimientos y aditivos de cemento.', 104.92, 58909.17, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido oxálico grado técnico saco 25kg', 'Compuesto usado para limpieza de metales y blanqueo.', 251.02, 57411.37, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bicarbonato de sodio grado industrial saco 25kg', 'Compuesto alcalino usado en múltiples procesos industriales.', 458.86, 10157.16, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cianuro de sodio grado industrial tambor', 'Compuesto usado en minería para lixiviación de oro.', 396.31, 55855.83, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nonilfenol etoxilado (surfactante) tambor 200L', 'Agente tensoactivo usado en detergentes industriales.', 42.1, 21248.57, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido sulfámico grado técnico saco 25kg', 'Compuesto usado en limpieza de incrustaciones minerales.', 380.53, 9778.42, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Dióxido de titanio pigmento saco 25kg', 'Pigmento blanco usado en pinturas y plásticos.', 449.3, 16717.06, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Glicerina grado industrial tambor 200L', 'Compuesto usado en cosmética, farmacéutica y alimentos.', 409.66, 8871.27, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido tricloroisocianúrico granular tambor', 'Desinfectante clorado usado en tratamiento de agua.', 256.09, 55218.5, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sulfato de cobre pentahidratado saco 25kg', 'Compuesto usado como fungicida y en tratamiento de agua.', 112.08, 15993.2, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Éter de petróleo grado industrial bidón 20L', 'Solvente usado en extracción y procesos de limpieza.', 257.94, 19348.93, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Carbonato de sodio (sosa Solvay) saco 25kg', 'Compuesto usado en fabricación de vidrio y detergentes.', 28.05, 11171.15, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Butilglicol grado industrial tambor 200L', 'Solvente usado en pinturas y productos de limpieza.', 89.0, 56203.3, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido fluorhídrico 40% bidón 25L', 'Ácido altamente corrosivo usado en grabado de vidrio y metales.', 343.04, 53756.16, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Poliacrilamida floculante en polvo saco 25kg', 'Compuesto usado en tratamiento de aguas residuales.', 92.68, 47156.7, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Dicromato de potasio grado técnico saco 25kg', 'Oxidante fuerte usado en procesos de curtiduría.', 66.39, 31984.06, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido sulfónico lineal (LABSA) tambor 200L', 'Materia prima activa para fabricación de detergentes.', 321.8, 21778.81, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (13, LAST_INSERT_ID());

-- Material Eléctrico (categoria 14)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable THHN calibre 10 rollo 100m', 'Conductor eléctrico de cobre para instalaciones industriales.', 436.6, 33333.05, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable de cobre desnudo calibre 8 rollo 50m', 'Conductor para sistemas de tierra física.', 290.44, 52957.97, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Interruptor termomagnético 3P 100A', 'Dispositivo de protección para circuitos trifásicos.', 53.2, 59577.63, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Centro de carga 24 espacios QO', 'Tablero de distribución eléctrica residencial.', 315.26, 23685.67, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Transformador de distribución 75 kVA', 'Equipo para transformación de voltaje en media tensión.', 399.04, 15922.01, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Contactor eléctrico 3 polos 40A', 'Dispositivo de conmutación para arranque de motores.', 495.26, 34662.76, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Relevador de sobrecarga térmica 25-40A', 'Dispositivo de protección para motores eléctricos.', 180.77, 45890.12, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámpara LED industrial tipo campana 150W', 'Luminaria de alta eficiencia para naves industriales.', 221.7, 10646.53, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Poste de concreto para alumbrado 9m', 'Estructura para soporte de luminarias públicas.', 372.05, 2945.07, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aislador de porcelana tipo carrete', 'Componente para líneas de distribución eléctrica.', 410.09, 15256.47, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable de cobre THW calibre 6 rollo 100m', 'Conductor eléctrico para instalaciones de mayor amperaje.', 319.98, 59044.11, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Panel solar monocristalino 550W', 'Módulo fotovoltaico de alta eficiencia para generación solar.', 293.35, 39838.73, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Inversor de corriente solar híbrido 5kW', 'Equipo para conversión de energía solar a corriente alterna.', 157.01, 157.37, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Batería de ciclo profundo 12V 200Ah', 'Batería para almacenamiento de energía en sistemas solares.', 17.86, 9004.42, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tablero de control eléctrico industrial', 'Gabinete para alojar dispositivos de control y protección.', 308.41, 25962.36, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable subterráneo XLPE calibre 4/0', 'Conductor aislado para instalaciones eléctricas subterráneas.', 256.83, 53737.77, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Arrancador suave (soft starter) 50HP', 'Dispositivo para arranque controlado de motores eléctricos.', 66.88, 13674.22, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Variador de frecuencia 10 HP', 'Equipo para control de velocidad de motores trifásicos.', 326.9, 1386.26, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fusible de cuchilla 100A tipo NH', 'Dispositivo de protección contra sobrecorriente.', 2.31, 21330.01, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable de control multiconductor 12x18AWG', 'Cable para sistemas de instrumentación y control.', 54.07, 21461.24, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Luminaria led para alumbrado público 100W', 'Luminaria de vía pública de alta eficiencia energética.', 112.91, 35036.28, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Transformador de control 220V/24V 500VA', 'Equipo para reducción de voltaje en circuitos de control.', 294.96, 12290.85, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Barra de cobre para tablero eléctrico', 'Componente conductor para distribución en gabinetes eléctricos.', 312.34, 28520.36, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Multímetro digital Fluke 117', 'Instrumento de medición eléctrica de precisión.', 68.24, 56198.63, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cinta aislante eléctrica 3M Scotch 33+', 'Cinta para aislamiento de empalmes eléctricos.', 122.55, 9001.32, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Conector de compresión bimetálico', 'Componente para unión de conductores de cobre y aluminio.', 48.81, 38310.7, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Generador eléctrico portátil 5000W', 'Equipo generador de energía para uso de emergencia.', 435.77, 46940.26, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo conduit metálico galvanizado 1 pulgada', 'Tubería para protección de cableado eléctrico.', 201.57, 15891.18, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Charola portacables tipo escalera 6 metros', 'Sistema de soporte para distribución de cableado industrial.', 6.74, 38714.59, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Regulador de voltaje automático 5kVA', 'Equipo de protección contra variaciones de voltaje.', 281.6, 21052.45, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('UPS de respaldo interactivo 1500VA', 'Sistema de energía ininterrumpida para equipos críticos.', 323.16, 26653.07, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Motor eléctrico trifásico 10 HP', 'Motor de inducción para aplicaciones industriales.', 468.64, 44024.67, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable de fibra óptica monomodo 24 hilos', 'Medio de transmisión de datos de alta velocidad.', 125.0, 54215.03, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Detector de tensión sin contacto', 'Instrumento para verificación segura de circuitos energizados.', 22.96, 31915.07, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caja de conexiones eléctricas IP65', 'Gabinete resistente a la intemperie para conexiones.', 203.59, 14298.24, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Seccionador de cuchillas 3 polos 200A', 'Dispositivo de desconexión visible para mantenimiento.', 30.13, 46743.39, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Banco de capacitores para corrección de FP', 'Equipo para mejora del factor de potencia industrial.', 7.16, 33077.83, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cable coaxial RG6 rollo 100m', 'Cable para transmisión de señal de video y datos.', 470.52, 8578.88, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Foco LED 15W luz de día', 'Lámpara de bajo consumo para iluminación general.', 100.56, 36504.57, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Regleta de conexión eléctrica 12 vías', 'Componente para distribución de conductores en tableros.', 253.97, 38512.12, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (14, LAST_INSERT_ID());

-- Plásticos y Hules (categoria 15)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo de PVC hidráulico cédula 40 6 pulgadas', 'Tubería para conducción de agua a presión.', 407.62, 5404.26, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Manguera de hule para jardín 5/8 pulgada', 'Manguera flexible resistente a la intemperie.', 158.14, 9147.93, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de polietileno negro calibre 720', 'Film plástico para uso agrícola y construcción.', 29.0, 26702.7, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Contenedor plástico industrial 1000L IBC', 'Tanque plástico para almacenamiento y transporte de líquidos.', 392.57, 21518.88, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tarima plástica reforzada 1.2x1.0m', 'Plataforma de manejo de carga resistente y reutilizable.', 8.14, 25364.09, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Manguera hidráulica trenzada 1/2 pulgada', 'Manguera de alta presión para sistemas hidráulicos.', 373.87, 14064.91, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfil de hule para sello de puertas', 'Empaque flexible para hermeticidad en construcción.', 372.17, 13684.12, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de acrílico transparente 4x8 pies', 'Material plástico rígido usado en señalización y protección.', 116.84, 3337.39, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo corrugado de polietileno 4 pulgadas', 'Tubería flexible para drenaje pluvial y agrícola.', 119.99, 1356.76, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('O-ring de nitrilo (NBR) surtido', 'Sello circular de hule para juntas hidráulicas.', 171.08, 22539.69, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Banda transportadora de hule 3 capas', 'Banda industrial para transporte de materiales a granel.', 349.08, 25390.93, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bolsa de polietileno industrial calibre 200', 'Bolsa plástica resistente para empaque industrial.', 357.28, 8126.43, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tinaco de polietileno rotomoldeado 1100L', 'Tanque para almacenamiento doméstico de agua potable.', 279.12, 13194.37, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Manguera de PVC cristal 1/2 pulgada', 'Manguera transparente para uso alimenticio e industrial.', 395.28, 15792.69, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Empaque de hule EPDM para ventanería', 'Sello flexible resistente a rayos UV e intemperie.', 136.32, 19331.69, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tapete de hule antifatiga industrial', 'Tapete ergonómico para estaciones de trabajo de pie.', 482.74, 6666.47, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cubeta plástica industrial 19 litros', 'Recipiente plástico resistente para uso industrial y comercial.', 440.62, 653.79, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de policarbonato alveolar 10mm', 'Panel translúcido resistente a impactos para techado.', 133.88, 7236.06, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Manguera de aire comprimido poliuretano', 'Manguera flexible ligera para herramientas neumáticas.', 373.22, 28352.0, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo flexible reforzado para alberca', 'Manguera resistente para sistemas de filtración de albercas.', 374.34, 9940.77, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Junta de expansión de hule para tubería', 'Componente flexible para absorber vibraciones en tuberías.', 440.68, 9990.9, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Charola plástica apilable para almacén', 'Contenedor reutilizable para organización de inventario.', 123.39, 27245.54, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de hule negro para piso industrial', 'Recubrimiento antiderrapante para pisos de trabajo.', 317.19, 20846.72, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Manguera de riego por goteo rollo 100m', 'Manguera perforada para sistemas de riego agrícola.', 334.29, 29374.6, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tapón de hule cónico surtido', 'Sello removible para tuberías y pruebas hidrostáticas.', 237.4, 25223.4, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cinta de hule autofundente eléctrica', 'Cinta aislante para sellado de empalmes eléctricos.', 350.32, 25754.18, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo de polipropileno termofusión 1 pulgada', 'Tubería para instalaciones de agua caliente y fría.', 221.42, 21793.78, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla plástica sombra 90% rollo 4x100m', 'Malla para reducción de luz solar en invernaderos.', 287.32, 9370.97, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Envase plástico PET para bebidas 600ml', 'Envase liviano usado en la industria de bebidas.', 109.92, 18754.14, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bidón plástico industrial 20 litros', 'Recipiente con tapa para almacenamiento de líquidos.', 43.51, 27341.53, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cople de PVC hidráulico 2 pulgadas', 'Conector para unión de tubería de PVC a presión.', 76.57, 1001.7, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de hule vulcanizado 3mm', 'Material de hule usado en sellos y aislamiento industrial.', 57.81, 27882.68, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rodillo de hule para banda transportadora', 'Componente de soporte y guía para sistemas de transporte.', 175.71, 4426.88, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de PVC para lonas rollo 50m', 'Material impermeable usado en toldos y cubiertas.', 19.22, 1441.15, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guante de nitrilo desechable caja 100pz', 'Guante resistente a químicos para uso industrial.', 347.85, 19089.57, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo flexible corrugado para conduit eléctrico', 'Tubería flexible para protección de cableado.', 350.02, 22156.2, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sello mecánico de hule para bomba centrífuga', 'Componente para evitar fugas en equipos de bombeo.', 37.55, 17796.09, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámina de espuma de poliuretano flexible', 'Material acolchado usado en muebles y colchones.', 184.89, 24563.34, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Manguera de gas LP flexible 1/2 pulgada', 'Manguera certificada para conexión de gas doméstico.', 410.68, 26760.15, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Envase de polipropileno para alimentos 500ml', 'Recipiente plástico apto para microondas y congelador.', 37.64, 26060.21, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (15, LAST_INSERT_ID());

-- Cosméticos y Perfumería (categoria 16)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfume Dior Sauvage EDT 100 ml', 'Fragancia masculina con notas amaderadas y especiadas.', 4.58, 7560.17, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfume Carolina Herrera 212 VIP 80 ml', 'Fragancia femenina floral y frutal de larga duración.', 0.58, 1725.21, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Base de maquillaje Maybelline Fit Me', 'Base líquida de cobertura media para todo tipo de piel.', 0.6, 371.97, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Labial mate MAC Ruby Woo', 'Labial de acabado mate color rojo icónico.', 4.25, 6514.95, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rímel L''Oréal Voluminous', 'Máscara de pestañas para volumen y definición.', 3.19, 6617.98, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Crema antiarrugas Olay Regenerist', 'Crema facial nocturna con péptidos y ácido hialurónico.', 3.18, 2370.18, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Protector solar Neutrogena SPF 50', 'Bloqueador solar de amplio espectro resistente al agua.', 0.54, 873.11, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Shampoo Pantene Pro-V reparación', 'Shampoo para cabello dañado con fórmula reparadora.', 3.8, 1719.45, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Acondicionador Tresemmé Keratin Smooth', 'Acondicionador con keratina para cabello liso y brillante.', 1.63, 3447.75, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sombra de ojos paleta Urban Decay Naked', 'Paleta de sombras neutras de alta pigmentación.', 0.15, 2127.95, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Delineador líquido Kat Von D Tattoo Liner', 'Delineador de precisión y larga duración.', 1.45, 5754.52, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Crema corporal Nivea hidratante 400ml', 'Crema humectante para todo tipo de piel.', 1.87, 2634.54, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Esmalte de uñas OPI color rojo clásico', 'Esmalte de larga duración con acabado brillante.', 4.82, 4079.52, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Colonia Jean Paul Gaultier Le Male 125ml', 'Fragancia masculina oriental amaderada.', 4.26, 4984.38, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rubor en polvo NARS Orgasm', 'Rubor iluminador de tono durazno rosado.', 0.2, 3362.08, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gel para peinar Got2b Ultra Glued', 'Gel fijador extremo para peinados de larga duración.', 2.21, 6206.9, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Crema depilatoria Veet piel sensible', 'Crema para remoción de vello corporal sin cuchilla.', 1.77, 5666.81, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Jabón facial CeraVe piel sensible', 'Limpiador suave con ceramidas para el rostro.', 2.71, 1810.94, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfume Yves Saint Laurent Black Opium 90ml', 'Fragancia femenina gourmand con notas de café y vainilla.', 4.32, 818.03, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Corrector de ojeras Tarte Shape Tape', 'Corrector de alta cobertura de larga duración.', 4.11, 1445.93, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite corporal Bio-Oil 200ml', 'Aceite para cicatrices y estrías de uso diario.', 0.06, 1696.08, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Polvo compacto Maybelline Fit Me Matte', 'Polvo facial para control de brillo y acabado natural.', 3.82, 7825.14, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bálsamo labial Burt''s Bees original', 'Bálsamo hidratante con cera de abeja.', 0.07, 3977.5, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Spray fijador de maquillaje Urban Decay All Nighter', 'Fijador de maquillaje de larga duración.', 2.48, 6394.5, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Loción para después de afeitar Nivea Men', 'Loción calmante para piel post afeitado.', 0.96, 4007.2, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Kit de brochas de maquillaje profesional 12 piezas', 'Set de brochas para aplicación de maquillaje.', 1.77, 6671.5, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mascarilla facial de arcilla L''Oréal Pure Clay', 'Mascarilla purificante para pieles grasas.', 1.34, 7556.57, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Exfoliante corporal St. Ives coco y café', 'Exfoliante corporal con partículas naturales.', 1.45, 1796.24, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfume Chanel Coco Mademoiselle 100ml', 'Fragancia femenina oriental floral de firma.', 3.51, 4036.69, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Talco corporal Johnson''s Baby 400g', 'Polvo absorbente para el cuidado de la piel.', 0.59, 5128.6, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Crema para manos L''Occitane Karité 150ml', 'Crema hidratante intensiva con manteca de karité.', 0.45, 6324.52, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Delineador de labios NYX de larga duración', 'Lápiz delineador para contorno de labios preciso.', 3.5, 6316.77, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite esencial de lavanda 30ml', 'Aceite aromático para uso en aromaterapia y cosmética.', 3.16, 2909.37, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tinte para cabello L''Oréal Excellence Creme', 'Tinte permanente de fórmula nutritiva para el cabello.', 2.04, 3217.34, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Iluminador facial Becca Shimmering Skin Perfector', 'Iluminador líquido para un acabado radiante.', 4.46, 780.77, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gel de baño Dove hidratante 500ml', 'Gel de ducha con crema hidratante para piel suave.', 4.45, 298.87, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espuma limpiadora Neutrogena Deep Clean', 'Limpiador facial en espuma para piel grasa.', 1.07, 2179.24, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de pinceles para labios y ojos', 'Herramientas de precisión para aplicación de maquillaje.', 4.51, 4059.4, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perfume Versace Eros EDT 100ml', 'Fragancia masculina fresca y amaderada.', 1.93, 7083.43, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Crema contorno de ojos Clinique All About Eyes', 'Crema específica para reducir bolsas y ojeras.', 1.21, 3741.17, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (16, LAST_INSERT_ID());

-- Suplementos Alimenticios (categoria 17)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Creatina monohidratada Optimum Nutrition 300g', 'Suplemento para incremento de fuerza y masa muscular.', 2.7, 3809.21, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('BCAA en polvo sabor sandía 400g', 'Aminoácidos de cadena ramificada para recuperación muscular.', 3.79, 3284.55, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Omega 3 aceite de pescado 120 cáps', 'Suplemento de ácidos grasos esenciales EPA y DHA.', 1.81, 1734.3, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Multivitamínico para mujer Centrum 100 tabs', 'Complejo vitamínico diseñado para necesidades femeninas.', 0.86, 4239.06, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Glutamina en polvo 300g', 'Aminoácido para recuperación y salud intestinal.', 3.34, 3748.64, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Proteína vegana de guisante sabor vainilla', 'Proteína vegetal de alta digestibilidad.', 0.93, 2278.17, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pre-entreno C4 Original 30 servicios', 'Suplemento estimulante para energía en el entrenamiento.', 3.89, 2958.97, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido fólico 400mcg caja 90 tabs', 'Suplemento vitamínico recomendado en el embarazo.', 0.72, 2390.79, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zinc quelado 50mg 100 cáps', 'Mineral esencial para el sistema inmunológico.', 4.44, 1304.01, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Magnesio quelado 400mg 90 cáps', 'Suplemento mineral para función muscular y nerviosa.', 1.04, 1612.31, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Colágeno hidrolizado con vitamina C 300g', 'Suplemento para salud de piel, cabello y articulaciones.', 3.55, 4241.76, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Melatonina 5mg 60 tabs', 'Suplemento para regulación del ciclo de sueño.', 0.86, 906.53, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vitamina C 1000mg 100 tabs', 'Suplemento antioxidante para el sistema inmune.', 1.31, 1733.83, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite de krill 500mg 60 cáps', 'Suplemento de omega 3 de origen marino.', 2.66, 930.48, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Proteína de suero isolate sabor chocolate', 'Proteína de rápida absorción y bajo contenido graso.', 1.71, 1067.98, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Probióticos multiespecie 50 mil millones UFC', 'Suplemento para salud digestiva e inmunológica.', 4.88, 3684.35, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('L-carnitina líquida 500ml', 'Suplemento usado en procesos de oxidación de grasas.', 0.6, 4817.57, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cúrcuma con pimienta negra 500mg 90 cáps', 'Suplemento antiinflamatorio natural.', 0.6, 2013.53, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espirulina en tabletas 500mg 200 tabs', 'Superalimento rico en proteína y antioxidantes.', 4.92, 4005.21, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ashwagandha KSM-66 600mg 60 cáps', 'Adaptógeno usado para manejo del estrés.', 3.69, 2259.38, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Hierro quelado 25mg 90 tabs', 'Suplemento mineral para prevención de anemia.', 1.06, 3244.21, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vitamina E 400 UI 100 cáps', 'Suplemento antioxidante liposoluble.', 0.62, 1151.25, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácidos grasos CLA 1000mg 90 cáps', 'Suplemento usado en definición de composición corporal.', 2.0, 314.57, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Proteína de caseína micelar sabor vainilla', 'Proteína de digestión lenta ideal para consumo nocturno.', 2.06, 3986.37, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Té verde en extracto 500mg 100 cáps', 'Suplemento con catequinas de acción antioxidante.', 3.5, 2577.36, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Electrolitos en polvo para hidratación', 'Suplemento para reposición de minerales durante ejercicio.', 3.2, 2396.9, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vitamina D3 + K2 60 cáps', 'Suplemento combinado para salud ósea y cardiovascular.', 0.79, 3077.99, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Barra de proteína sabor chocolate caja 12', 'Snack proteico conveniente post entrenamiento.', 2.08, 3743.59, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aminoácidos esenciales EAA sabor mango', 'Suplemento de aminoácidos completos para síntesis muscular.', 4.55, 2235.64, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Complejo de enzimas digestivas 90 cáps', 'Suplemento para mejorar la digestión de macronutrientes.', 2.91, 3783.14, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ginseng coreano 500mg 100 cáps', 'Suplemento adaptógeno usado para energía y vitalidad.', 2.16, 1258.54, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Colágeno tipo II para articulaciones', 'Suplemento específico para salud de cartílago articular.', 3.64, 4418.37, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Levadura de cerveza en tabletas 500g', 'Suplemento fuente natural de complejo B.', 3.89, 3545.38, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Quitosano 500mg 90 cáps', 'Suplemento de fibra usado en control de peso.', 4.28, 3446.04, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Resveratrol 500mg 60 cáps', 'Suplemento antioxidante derivado de la uva.', 3.24, 2351.43, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Proteína de huevo albúmina en polvo', 'Proteína de alto valor biológico libre de lactosa.', 1.63, 3197.14, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Biotina 10000mcg 120 cáps', 'Suplemento vitamínico para cabello, piel y uñas.', 0.58, 2184.96, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fibra soluble psyllium plantago 500g', 'Suplemento de fibra para tránsito intestinal.', 3.93, 3608.78, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Coenzima Q10 100mg 90 cáps', 'Suplemento antioxidante para salud cardiovascular.', 3.19, 1362.8, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite MCT (triglicéridos de cadena media) 500ml', 'Suplemento energético de rápida absorción.', 2.18, 2357.69, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (17, LAST_INSERT_ID());

-- Equipos Médicos (categoria 18)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ventilador mecánico de terapia intensiva', 'Equipo para soporte respiratorio en pacientes críticos.', 310.86, 327771.06, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Monitor de signos vitales multiparámetro', 'Equipo para monitoreo continuo de constantes vitales.', 337.69, 744192.8, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Desfibrilador automático externo (DEA)', 'Equipo de emergencia para reanimación cardiaca.', 91.69, 523764.51, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ultrasonido diagnóstico portátil', 'Equipo de imagenología para diagnóstico por ultrasonido.', 389.13, 311272.39, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camilla hospitalaria eléctrica ajustable', 'Cama de hospital con ajuste eléctrico de posición.', 245.02, 779708.34, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Silla de ruedas plegable de aluminio', 'Equipo de movilidad para pacientes con discapacidad.', 19.27, 434916.25, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bomba de infusión volumétrica', 'Equipo para administración controlada de soluciones intravenosas.', 80.59, 625542.47, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Autoclave de mesa para esterilización', 'Equipo para esterilización de instrumental médico.', 470.31, 415616.37, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rayos X portátil digital', 'Equipo de radiología móvil para diagnóstico por imagen.', 50.72, 459861.12, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Incubadora neonatal de cuidados intensivos', 'Equipo para cuidado de recién nacidos prematuros.', 270.61, 573978.23, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Electrocardiógrafo de 12 derivaciones', 'Equipo para registro de actividad eléctrica cardiaca.', 256.19, 511589.4, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámpara quirúrgica LED de techo', 'Equipo de iluminación para quirófano.', 414.53, 417589.77, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mesa de exploración clínica ajustable', 'Mobiliario médico para exploración de pacientes.', 205.29, 758404.11, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nebulizador ultrasónico portátil', 'Equipo para administración de medicamento en aerosol.', 105.2, 547646.04, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aspirador de secreciones portátil', 'Equipo médico para succión de fluidos corporales.', 196.37, 610279.96, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Concentrador de oxígeno portátil 5L', 'Equipo para suministro continuo de oxígeno medicinal.', 61.37, 787582.44, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grúa hidráulica para transferencia de pacientes', 'Equipo de movilidad para traslado de pacientes con discapacidad.', 177.87, 45766.33, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Torre de laparoscopía completa', 'Sistema de video quirúrgico para cirugía mínimamente invasiva.', 137.32, 320047.5, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Báscula clínica con estadímetro', 'Equipo para medición de peso y talla en consultorio.', 6.85, 335156.71, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Refrigerador para vacunas de laboratorio', 'Equipo especializado para conservación de biológicos.', 210.39, 558753.05, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Analizador de gases en sangre portátil', 'Equipo de diagnóstico para valores de gasometría.', 176.19, 212493.4, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Doppler fetal portátil', 'Equipo para monitoreo de frecuencia cardiaca fetal.', 112.37, 593305.76, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Microscopio óptico binocular de laboratorio', 'Equipo óptico para análisis clínico e investigación.', 469.98, 421897.62, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Centrífuga de laboratorio clínico', 'Equipo para separación de componentes sanguíneos.', 109.61, 641289.14, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Andadera ortopédica plegable', 'Equipo de apoyo para movilidad y rehabilitación.', 196.1, 170004.21, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Muleta axilar ajustable de aluminio par', 'Equipo de apoyo para movilidad temporal.', 64.82, 621397.7, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bomba de circulación extracorpórea', 'Equipo especializado para cirugía cardiovascular.', 404.82, 507621.61, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Colposcopio para ginecología', 'Equipo óptico para exploración cervical.', 234.69, 449862.11, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Endoscopio flexible de fibra óptica', 'Equipo médico para exploración interna mínimamente invasiva.', 113.15, 771109.43, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espirómetro digital de diagnóstico', 'Equipo para medición de función pulmonar.', 176.7, 511217.79, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Torre de anestesia con ventilador integrado', 'Equipo completo para administración de anestesia general.', 409.41, 653035.24, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de instrumental quirúrgico general', 'Conjunto de herramientas para procedimientos quirúrgicos.', 234.16, 235826.69, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cama hospitalaria manual de 2 movimientos', 'Mobiliario médico ajustable para cuidado de pacientes.', 274.22, 100570.28, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Analizador de glucosa de laboratorio', 'Equipo para diagnóstico bioquímico de glucosa en sangre.', 416.91, 284119.56, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tensiómetro de columna de mercurio', 'Equipo tradicional para medición de presión arterial.', 425.36, 214305.88, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Desfibrilador manual bifásico hospitalario', 'Equipo avanzado de reanimación para uso hospitalario.', 188.2, 203212.55, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lámpara de fototerapia neonatal', 'Equipo para tratamiento de ictericia en recién nacidos.', 213.17, 149118.83, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Equipo de rayos X dental panorámico', 'Equipo de imagenología especializado en odontología.', 1.55, 577570.63, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Congelador ultra bajo -80°C de laboratorio', 'Equipo de conservación de muestras biológicas críticas.', 140.75, 196351.3, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Unidad dental completa con sillón', 'Equipo integral para consultorio de odontología.', 151.05, 383900.27, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (18, LAST_INSERT_ID());

-- Material Bélico (categoria 19)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fusil de asalto M4A1 cal. 5.56mm', 'Arma de fuego militar de uso exclusivo del Ejército.', 857.27, 320464.09, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pistola Glock 17 cal. 9mm', 'Arma corta semiautomática de uso reglamentario.', 1318.7, 184403.64, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ametralladora ligera FN Minimi cal. 5.56mm', 'Arma de apoyo automática de infantería.', 1857.49, 427950.5, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fusil de precisión Barrett M107 cal. .50', 'Rifle de francotirador de largo alcance.', 114.6, 414810.44, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lanzagranadas M203 acoplable', 'Arma de apoyo para lanzamiento de granadas de 40mm.', 1811.66, 393099.02, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chaleco antibalas nivel IV con placas', 'Equipo de protección balística de alto nivel.', 281.23, 416507.36, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Casco balístico tipo combate', 'Equipo de protección craneal para uso militar.', 1266.51, 12417.99, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Granada de fragmentación M67', 'Munición explosiva de uso exclusivo militar.', 23.45, 476125.45, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Munición cal. 7.62x51mm caja 500 cartuchos', 'Munición de fusil para uso militar reglamentario.', 1312.09, 128763.15, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mira telescópica militar 6-24x50', 'Óptica de precisión para armamento de largo alcance.', 203.47, 75652.61, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Radio táctica militar cifrada', 'Equipo de comunicación segura para operaciones militares.', 467.67, 389271.26, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Explosivo plástico C-4 uso militar', 'Material explosivo de uso exclusivo de fuerzas armadas.', 693.21, 80572.59, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Detonador eléctrico para cargas militares', 'Dispositivo de iniciación para material explosivo controlado.', 1808.22, 396878.8, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fusil francotirador Dragunov SVD cal. 7.62mm', 'Rifle semiautomático de precisión militar.', 336.24, 446112.0, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Subfusil MP5 cal. 9mm', 'Arma corta automática de uso táctico especializado.', 1216.93, 391734.32, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vehículo blindado ligero MRAP', 'Vehículo militar con protección contra minas y emboscadas.', 1337.08, 447486.7, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cohete antitanque RPG-7', 'Arma de apoyo contra blindaje de uso militar.', 1576.25, 420207.49, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mortero de 81mm con base', 'Arma de apoyo de fuego indirecto de infantería.', 395.14, 347932.39, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Escudo balístico portátil nivel IIIA', 'Equipo de protección personal para unidades tácticas.', 1061.83, 372246.41, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Traje de desactivación de explosivos (EOD)', 'Equipo especializado de protección contra explosivos.', 877.45, 441927.82, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ametralladora pesada Browning M2 cal. .50', 'Arma de apoyo de alto calibre para uso militar.', 1110.35, 135924.69, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sistema de visión térmica militar', 'Equipo óptico para detección en condiciones de oscuridad.', 468.73, 73972.44, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fusil de asalto AK-103 cal. 7.62mm', 'Arma de fuego automática de uso militar exclusivo.', 986.41, 33934.96, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cargador de alta capacidad 5.56mm 100 tiros', 'Accesorio para incrementar capacidad de munición.', 934.45, 76488.31, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Granada de humo M18', 'Dispositivo militar para señalización y ocultamiento táctico.', 983.0, 251596.95, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Silenciador supresor de sonido cal. 9mm', 'Accesorio de reducción acústica para armamento corto.', 1079.32, 432124.46, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Torreta blindada para vehículo militar', 'Componente de defensa montado en vehículos tácticos.', 13.71, 421179.92, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sistema de misiles portátil Stinger', 'Arma antiaérea portátil de defensa de corto alcance.', 936.19, 283471.65, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bayoneta táctica para fusil de asalto', 'Accesorio de combate cuerpo a cuerpo militar.', 1330.77, 421080.11, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Dron militar de reconocimiento táctico', 'Vehículo aéreo no tripulado para vigilancia militar.', 750.23, 212314.32, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Blindaje reactivo explosivo para tanque', 'Componente de protección adicional para vehículos blindados.', 1921.25, 42321.18, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fusil sin retroceso Carl Gustaf 84mm', 'Arma antitanque portátil de infantería.', 1274.26, 319882.43, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chaleco portaplacas táctico modular', 'Equipo de carga y protección para uso militar.', 57.54, 306789.29, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sistema de comunicación satelital militar', 'Equipo de enlace seguro para operaciones remotas.', 1365.33, 466089.05, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Minas antitanque de uso militar controlado', 'Dispositivo explosivo defensivo de uso exclusivo militar.', 661.25, 490947.76, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lanzacohetes múltiple BM-21 (componentes)', 'Sistema de artillería de cohetes de uso militar.', 1021.5, 244914.4, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Traje de camuflaje ghillie táctico', 'Equipo de camuflaje para operaciones de reconocimiento.', 1795.17, 21779.01, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sistema de puntería láser táctico', 'Accesorio de designación de blanco para armamento corto.', 1436.51, 314512.54, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Obús remolcado de 155mm (componentes)', 'Pieza de artillería pesada de uso militar.', 677.54, 431536.56, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Munición perforante cal. .50 caja 100 cartuchos', 'Munición especializada de alto poder de penetración.', 732.63, 239894.1, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (19, LAST_INSERT_ID());

-- Equipo Óptico y de Visión (categoria 20)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Binoculares Steiner Military 10x50', 'Binoculares de alto contraste para uso táctico.', 10.56, 115700.87, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Telescopio Celestron NexStar 8SE', 'Telescopio computarizado para observación astronómica.', 4.29, 65560.84, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mira réflex Aimpoint T2', 'Mira de punto rojo para armamento táctico.', 8.51, 83327.13, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gafas de visión nocturna monocular Gen 3', 'Equipo óptico para visión en condiciones de baja luz.', 16.55, 44285.98, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara termográfica FLIR portátil', 'Equipo para detección de radiación infrarroja.', 16.57, 60857.59, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Microscopio estereoscópico de laboratorio', 'Equipo óptico para observación tridimensional de muestras.', 10.12, 41118.84, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Telémetro láser Bushnell 1600 yardas', 'Equipo óptico para medición de distancia de precisión.', 10.18, 146261.84, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lentes de sol polarizados Ray-Ban Aviator', 'Lentes con protección UV y filtro polarizado.', 13.13, 118896.69, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara de vigilancia con visión nocturna IP', 'Equipo de seguridad con sensor infrarrojo integrado.', 6.68, 47905.55, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Prismáticos Nikon Monarch 8x42', 'Binoculares de alto rendimiento óptico para observación.', 6.05, 88174.45, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mira telescópica Leupold VX-3HD 4.5-14x40', 'Óptica de precisión para tiro deportivo y caza.', 12.73, 117740.23, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lupa de precisión con luz LED 10x', 'Instrumento óptico de aumento para trabajo detallado.', 0.9, 108540.14, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Proyector láser de alta definición Epson', 'Equipo de proyección para presentaciones profesionales.', 17.72, 82037.47, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara endoscópica industrial con cable', 'Equipo óptico para inspección de espacios confinados.', 1.09, 45410.76, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gafas de realidad virtual Meta Quest 3', 'Dispositivo óptico para experiencias inmersivas digitales.', 0.22, 28896.15, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Colimador láser para armamento deportivo', 'Accesorio óptico de ajuste de mira táctica.', 18.44, 91498.5, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Periscopio óptico portátil plegable', 'Instrumento óptico para observación indirecta.', 13.19, 118459.53, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara réflex Canon EOS R6 con lente', 'Cámara digital profesional para fotografía de alta resolución.', 18.21, 91955.14, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lentes oftálmicos progresivos antirreflejantes', 'Lentes graduados con tratamiento antirreflejante.', 12.37, 94208.73, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Monocular Vortex Solo 10x36', 'Instrumento óptico compacto para observación a distancia.', 13.96, 89648.08, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara de visión nocturna para vehículo', 'Sistema óptico para asistencia de conducción nocturna.', 13.65, 32268.96, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espejo de inspección telescópico con luz LED', 'Herramienta óptica para revisión de áreas de difícil acceso.', 13.37, 68952.96, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Filtro polarizador circular para lente de cámara', 'Accesorio óptico para reducción de reflejos en fotografía.', 15.28, 15653.56, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gafas de protección láser clase 4', 'Equipo de seguridad óptica para trabajo con láser industrial.', 3.71, 6028.16, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mira holográfica EOTech 512', 'Sistema óptico de puntería para armamento táctico.', 15.51, 137155.39, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Telescopio refractor Sky-Watcher 90mm', 'Instrumento óptico para observación astronómica de entrada.', 13.15, 55645.96, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara térmica para caza Pulsar Helion', 'Equipo óptico de visión térmica portátil de largo alcance.', 16.47, 118087.74, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de lentes intercambiables para dron DJI', 'Accesorios ópticos para fotografía aérea profesional.', 11.29, 39071.41, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Binoculares de rango de golf con láser', 'Equipo óptico especializado para medición de distancia deportiva.', 6.11, 63556.81, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lupa de mesa con soporte y luz LED', 'Instrumento óptico para trabajo de precisión en banco.', 6.44, 64885.92, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara de seguridad PTZ con zoom óptico 30x', 'Equipo de videovigilancia con movimiento motorizado.', 12.87, 140111.85, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Microscopio digital USB portátil 1000x', 'Equipo óptico digital para inspección y educación.', 1.19, 85342.35, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gafas 3D pasivas para cine en casa', 'Accesorio óptico para visualización de contenido tridimensional.', 0.88, 18267.62, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Visor nocturno para rifle de caza', 'Equipo óptico especializado para observación en oscuridad.', 16.23, 86510.54, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara de acción GoPro Hero 12', 'Cámara compacta resistente para grabación de actividades extremas.', 18.38, 67247.52, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Espectroscopio de laboratorio óptico', 'Instrumento para análisis espectral de muestras.', 0.38, 58377.85, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lentes de contacto de uso diario', 'Lentes ópticos correctivos de uso oftálmico.', 11.88, 140689.05, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cámara de termografía industrial FLIR E8', 'Equipo para inspección térmica de instalaciones eléctricas.', 19.62, 71579.54, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Prismático marino con brújula 7x50', 'Binocular resistente al agua para navegación.', 8.31, 15755.46, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sistema de mira nocturna digital day/night', 'Equipo óptico dual para uso diurno y nocturno.', 12.93, 32235.4, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (20, LAST_INSERT_ID());

-- Animales Vivos (categoria 21)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Becerro Angus para engorda', 'Bovino de raza Angus destinado a producción de carne.', 121.45, 1594.6, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vaquilla Brahman registrada', 'Bovino de raza cebú para reproducción y pie de cría.', 3.88, 61601.74, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Toro Charolais reproductor', 'Bovino semental de raza Charolais para mejora genética.', 97.38, 86978.09, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caballo cuarto de milla registrado', 'Equino de silla para trabajo de rancho y deporte.', 70.56, 78285.51, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Yegua pura sangre para cría', 'Equino registrado destinado a reproducción.', 103.22, 1796.38, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerdo pie de cría Yorkshire', 'Porcino reproductor de línea genética mejorada.', 575.49, 21955.88, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Lechón destetado Landrace', 'Porcino joven destinado a engorda comercial.', 586.86, 17029.45, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Oveja Pelibuey para reproducción', 'Ovino de raza tropical resistente para pie de cría.', 40.16, 69707.27, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Carnero Dorper reproductor', 'Ovino semental de raza cárnica de rápido crecimiento.', 570.86, 77023.46, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cabra Boer para engorda', 'Caprino de raza cárnica de alto rendimiento.', 583.79, 7769.21, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gallina ponedora Rhode Island Red', 'Ave de postura para producción comercial de huevo.', 502.92, 63889.32, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pollo de engorda de un día Cobb 500', 'Ave de línea genética para producción de carne.', 368.49, 83924.73, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pavo doméstico Broad Breasted White', 'Ave destinada a producción de carne de pavo.', 203.28, 86795.52, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pato Pekín para engorda', 'Ave acuática destinada a producción cárnica.', 573.78, 1223.81, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Codorniz japonesa para postura', 'Ave pequeña destinada a producción de huevo y carne.', 11.83, 58632.63, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Conejo Nueva Zelanda Blanco para engorda', 'Mamífero de rápido crecimiento para producción cárnica.', 653.88, 7355.32, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Abeja reina Apis mellifera certificada', 'Insecto reproductor para renovación de colmenas apícolas.', 248.88, 65703.88, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tilapia alevín para acuacultura', 'Pez de agua dulce destinado a cultivo comercial.', 132.84, 77514.89, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camarón blanco postlarva para cultivo', 'Crustáceo juvenil destinado a granjas acuícolas.', 389.09, 5568.16, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Trucha arcoíris alevín', 'Pez de agua fría destinado a piscicultura.', 294.08, 51831.7, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Perro pastor alemán con pedigrí', 'Canino de raza destinado a compañía o trabajo.', 351.01, 60983.78, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gato persa con pedigrí', 'Felino de raza destinado a compañía y exhibición.', 115.97, 71803.0, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caballo percherón de tiro', 'Equino de gran tamaño usado para trabajo de tiro.', 290.64, 58111.01, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Búfalo de agua para producción lechera', 'Bovino asiático destinado a producción de leche.', 503.78, 37733.23, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ganso blanco para ornato y engorda', 'Ave acuática usada en producción avícola y ornato.', 308.62, 70804.56, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chinchilla doméstica para peletería', 'Roedor pequeño destinado a producción de piel.', 755.94, 70659.25, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Avestruz juvenil para engorda', 'Ave corredora destinada a producción de carne y piel.', 453.47, 26456.47, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Faisán dorado para ornato', 'Ave exótica destinada a exhibición y ornato.', 48.56, 87660.82, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Burro criollo de trabajo', 'Equino usado en labores de carga rural.', 562.63, 74501.3, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mula de trabajo mestiza', 'Híbrido equino usado en labores de carga y transporte.', 265.67, 54602.91, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vaca lechera Holstein en producción', 'Bovino especializado en producción láctea de alto rendimiento.', 781.96, 74849.7, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ternera Jersey para reemplazo lechero', 'Bovino joven destinado a reposición de hato lechero.', 480.93, 27912.08, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cerdo Duroc para pie de cría', 'Porcino de raza cárnica con alta calidad de carne.', 342.88, 79953.54, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gallo de pelea criollo (exhibición deportiva regulada)', 'Ave usada en actividades reguladas de exhibición rural.', 301.37, 61697.01, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Codorniz Coturnix para exhibición', 'Ave pequeña usada en granjas de traspatio.', 481.45, 80671.21, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caracol Helix aspersa para helicicultura', 'Molusco terrestre destinado a producción alimenticia.', 645.99, 25641.18, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rana toro para acuacultura', 'Anfibio destinado a producción de carne especializada.', 1.4, 23821.4, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Langostino de río postlarva', 'Crustáceo de agua dulce destinado a cultivo comercial.', 338.03, 52880.54, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bagre de canal alevín', 'Pez destinado a sistemas de acuacultura intensiva.', 652.8, 79891.67, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Paloma mensajera de carreras', 'Ave entrenada para actividades de colombofilia deportiva.', 33.89, 75024.14, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (21, LAST_INSERT_ID());

-- Semillas y Granos (categoria 22)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de maíz híbrido Pioneer P4082', 'Semilla mejorada de alto rendimiento para grano.', 812.69, 17370.66, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de sorgo forrajero certificada', 'Semilla para producción de forraje de alta digestibilidad.', 574.05, 5622.2, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de soya Roundup Ready saco 40kg', 'Semilla genéticamente mejorada tolerante a herbicida.', 851.93, 16179.25, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de arroz certificada saco 40kg', 'Semilla para cultivo de grano de alta calidad.', 686.22, 18292.24, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de cebada maltera certificada', 'Semilla especializada para producción de malta cervecera.', 350.12, 1884.26, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de avena forrajera saco 40kg', 'Semilla para producción de forraje y grano.', 555.91, 15988.29, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de girasol híbrida para aceite', 'Semilla especializada para extracción de aceite vegetal.', 204.43, 15053.65, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de canola híbrida certificada', 'Semilla oleaginosa para producción de aceite y forraje.', 932.06, 4833.84, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de algodón deslintada certificada', 'Semilla tratada para siembra mecanizada de algodón.', 608.86, 13617.71, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de alfalfa certificada saco 25kg', 'Semilla forrajera perenne de alto valor nutricional.', 468.0, 4290.4, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de tomate híbrido saladette', 'Semilla mejorada para producción comercial de tomate.', 258.46, 15072.44, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de chile jalapeño mejorado', 'Semilla híbrida para producción de chile de exportación.', 792.71, 9302.41, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de cebolla amarilla certificada', 'Semilla para producción comercial de bulbo.', 92.26, 16170.18, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de zanahoria híbrida Nantes', 'Semilla mejorada para producción de raíz comercial.', 773.31, 4810.76, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de lechuga romana certificada', 'Semilla para producción de hortaliza de hoja.', 581.69, 17959.2, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de brócoli híbrido Marathon', 'Semilla mejorada para producción de brócoli comercial.', 885.67, 10532.8, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de pepino híbrido para exportación', 'Semilla especializada para producción de pepino de mesa.', 479.2, 11868.71, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de calabacita italiana híbrida', 'Semilla mejorada para producción de hortaliza de verano.', 193.21, 4007.82, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de espárrago para trasplante', 'Semilla especializada para establecimiento de espárrago.', 184.79, 14081.07, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de trigo cristalino certificado', 'Semilla especializada para producción de pasta y sémola.', 366.01, 11375.73, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de garbanzo blanco certificado', 'Semilla de leguminosa para consumo humano.', 405.48, 10440.9, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de lenteja certificada saco 40kg', 'Semilla de leguminosa de ciclo corto.', 153.26, 1082.97, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de haba certificada saco 40kg', 'Semilla de leguminosa para consumo fresco y seco.', 997.16, 7606.0, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de ajonjolí certificada saco 25kg', 'Semilla oleaginosa usada en la industria alimenticia.', 110.59, 12728.3, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de cacahuate Virginia certificada', 'Semilla mejorada para producción de cacahuate comercial.', 788.41, 3291.87, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de pastizal Rye grass perenne', 'Semilla forrajera para establecimiento de praderas.', 599.23, 7029.45, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de pasto Bermuda para forraje', 'Semilla forrajera resistente a sequía.', 521.86, 607.29, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grano de maíz amarillo para forraje costal 40kg', 'Grano usado como base para alimento balanceado animal.', 38.41, 19810.01, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grano de trigo panificable costal 40kg', 'Grano usado en la industria de la panificación.', 866.75, 9829.05, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grano de cebada cervecera costal 40kg', 'Grano usado en producción de malta y cerveza.', 569.35, 5379.62, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grano de arroz palay costal 40kg', 'Grano de arroz sin descascarar recién cosechado.', 780.29, 8633.81, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Frijol negro semilla certificada saco 40kg', 'Semilla mejorada para producción de leguminosa.', 946.77, 15391.53, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de amaranto certificada saco 25kg', 'Semilla de pseudocereal para consumo humano.', 819.74, 19276.67, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de quinoa certificada saco 25kg', 'Semilla de pseudocereal de alto valor nutricional.', 257.73, 949.84, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de linaza certificada saco 25kg', 'Semilla oleaginosa usada en alimentación humana y animal.', 204.98, 3778.56, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de mostaza para condimento', 'Semilla oleaginosa usada en la industria alimenticia.', 88.24, 1209.75, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grano de sorgo blanco para consumo animal', 'Grano usado como componente de alimento balanceado.', 559.59, 17439.2, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de betabel híbrida certificada', 'Semilla mejorada para producción de raíz comercial.', 460.99, 18954.66, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de rábano certificada saco 25kg', 'Semilla de ciclo corto para producción de hortaliza.', 910.37, 1470.88, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Semilla de melón cantaloupe híbrido', 'Semilla especializada para producción de fruta de exportación.', 600.08, 8068.45, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (22, LAST_INSERT_ID());

-- Juguetes y Artículos Infantiles (categoria 23)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de bloques de construcción Mega Bloks', 'Juguete de ensamblaje para desarrollo motriz infantil.', 2.44, 7678.44, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Muñeca Barbie Dreamhouse edición especial', 'Muñeca articulada con accesorios de casa de ensueño.', 5.18, 4559.36, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Carro de control remoto Hot Wheels RC', 'Vehículo a escala con control remoto para niños.', 12.83, 7655.72, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Peluche de felpa oso panda 40cm', 'Juguete suave de peluche para niños pequeños.', 13.41, 3205.63, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rompecabezas 1000 piezas paisaje', 'Juego de armado para desarrollo cognitivo y concentración.', 8.99, 1361.85, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Triciclo infantil con barra de empuje', 'Vehículo de paseo para niños de 1 a 3 años.', 19.32, 7934.55, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de cocina de juguete con accesorios', 'Juguete de simulación para juego de roles infantil.', 4.47, 405.19, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Robot transformable Optimus Prime', 'Figura de acción transformable de la franquicia Transformers.', 5.15, 2880.89, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pista de carreras Hot Wheels Track Set', 'Juguete de pista con loops y rampas para autos.', 18.06, 7246.12, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Muñeco de acción Marvel Spider-Man articulado', 'Figura coleccionable con articulaciones móviles.', 16.75, 471.63, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de té de porcelana de juguete', 'Juego de simulación para actividades de rol infantil.', 15.74, 5705.91, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Patineta infantil con luces LED en ruedas', 'Tabla de deslizamiento con ruedas luminosas.', 12.95, 7884.87, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Casa de muñecas de madera 3 pisos', 'Juguete de construcción para juego imaginativo.', 1.16, 1243.9, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de arte y manualidades Crayola 100 piezas', 'Kit creativo con crayones, plumones y accesorios.', 15.11, 7521.11, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Juego de mesa Monopoly edición clásica', 'Juego de estrategia y economía para toda la familia.', 13.55, 2460.46, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Muñeco de peluche interactivo con sonidos', 'Juguete de peluche con funciones de audio para bebés.', 11.85, 6087.39, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de bloques magnéticos de construcción', 'Juguete educativo para desarrollo de habilidades espaciales.', 2.15, 2658.96, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bicicleta infantil rodada 16 con rueditas', 'Bicicleta con llantas de entrenamiento para niños pequeños.', 5.18, 1080.73, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de dinosaurios de plástico articulados', 'Figuras de juguete para juego imaginativo prehistórico.', 9.65, 1431.76, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Muñeca bebé llorona interactiva', 'Muñeco de simulación con funciones de sonido y movimiento.', 4.81, 1230.88, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Carrito de bebé para muñecas', 'Juguete de simulación de cuidado infantil tipo carreola.', 13.57, 199.65, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de disfraz de superhéroe infantil', 'Vestuario temático para juego de roles imaginativo.', 14.36, 1641.32, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pizarra mágica de dibujo Etch A Sketch', 'Juguete de dibujo mecánico reutilizable para niños.', 0.77, 7428.66, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de instrumentos musicales infantiles', 'Kit de instrumentos de juguete para estimulación musical.', 4.45, 7478.42, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Kit de ciencia experimentos para niños', 'Set educativo para experimentos científicos sencillos.', 17.34, 7120.79, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Camión de bomberos de juguete con sonido', 'Vehículo de juguete con luces y efectos de sonido.', 2.84, 3633.24, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de figuras de acción Jurassic World', 'Colección de figuras temáticas de dinosaurios.', 1.98, 7437.35, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Muñeco Baby Alive que come de verdad', 'Muñeca interactiva de simulación de alimentación.', 16.85, 5064.13, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de bloques Lego Classic 500 piezas', 'Set de construcción creativa de bloques interconectables.', 9.07, 2784.25, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Andadera saltarina para bebé', 'Juguete de estimulación motriz para bebés en desarrollo.', 16.47, 3872.55, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de figuras de acción de lucha libre', 'Muñecos articulados de personajes de lucha libre.', 12.58, 1227.87, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Consola de videojuegos portátil infantil', 'Dispositivo electrónico de juegos para niños.', 4.47, 548.14, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de disfraz de princesa con accesorios', 'Vestuario temático de fantasía para juego de roles.', 14.29, 4471.66, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Móvil musical para cuna', 'Juguete giratorio con música para estimulación de bebés.', 2.94, 6978.71, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de figuras coleccionables Pokémon', 'Colección de figuras miniatura de la franquicia Pokémon.', 5.36, 3353.08, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cochecito de juguete a control remoto monster truck', 'Vehículo todo terreno a escala con control remoto.', 3.16, 2241.75, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de plastilina Play-Doh con moldes', 'Kit de masa moldeable para actividades creativas.', 16.8, 2742.62, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Casa de juegos inflable para exterior', 'Estructura inflable para actividades recreativas al aire libre.', 3.4, 3978.95, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de bloques de madera didácticos', 'Juguete educativo de formas geométricas apilables.', 6.4, 7235.03, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Kit de robótica educativa para niños LEGO Mindstorms', 'Set de construcción programable para aprendizaje STEM.', 2.33, 7831.11, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (23, LAST_INSERT_ID());

-- Textiles Técnicos (categoria 24)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela Kevlar para chalecos balísticos rollo 20m', 'Tejido de aramida de alta resistencia al impacto.', 33.14, 35853.99, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela ignífuga aluminizada para trajes de bombero', 'Tejido reflectante resistente a altas temperaturas.', 335.8, 8840.76, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Geomembrana HDPE 1.5mm rollo', 'Membrana impermeable para obras de contención civil.', 241.34, 11806.21, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela antiestática para salas limpias', 'Tejido técnico que disipa cargas electrostáticas.', 132.61, 8464.06, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla de fibra de carbono para refuerzo estructural', 'Tejido técnico usado en refuerzo de estructuras de concreto.', 185.32, 39645.33, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela filtrante para procesos industriales', 'Tejido técnico usado en filtros prensa industriales.', 499.05, 37040.65, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela para airbag automotriz recubierta', 'Tejido técnico de alta resistencia para sistemas de seguridad.', 53.29, 11932.43, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela Gore-Tex impermeable transpirable', 'Membrana técnica para ropa outdoor de alto desempeño.', 448.62, 2770.55, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Geotextil tejido de alta resistencia 300g/m2', 'Tejido técnico para estabilización de suelos en obra civil.', 364.6, 12094.21, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de fibra de vidrio para aislamiento térmico', 'Tejido técnico resistente al calor para aislamiento industrial.', 489.42, 1133.13, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela para velas náuticas Dacron', 'Tejido técnico de alta resistencia para embarcaciones.', 404.48, 13965.79, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de neopreno laminado para trajes técnicos', 'Tejido técnico usado en equipo de buceo profesional.', 74.37, 575.96, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla antigranizo para uso agrícola técnico', 'Tejido técnico de protección de cultivos contra granizo.', 416.96, 21300.17, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela para paracaídas de nylon ripstop', 'Tejido técnico ligero y resistente al desgarre.', 96.98, 17692.35, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de fibra de aramida para guantes de corte', 'Tejido técnico resistente a cortes para uso industrial.', 456.43, 9121.46, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Membrana textil para techos tensados PVC', 'Tejido técnico usado en estructuras arquitectónicas tensadas.', 287.81, 5953.94, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela para filtros de aire industrial HEPA', 'Tejido técnico de alta eficiencia para filtración de partículas.', 94.16, 30932.61, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela técnica para trajes de carreras Nomex', 'Tejido resistente al fuego para pilotos de automovilismo.', 357.25, 8270.1, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela reforzada para mangueras contra incendio', 'Tejido técnico de alta resistencia a presión y calor.', 44.24, 3953.13, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de fibra de vidrio para moldes náuticos', 'Tejido técnico usado en fabricación de cascos de embarcaciones.', 306.24, 20071.47, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla técnica para invernaderos anti-insectos', 'Tejido técnico usado en protección de cultivos protegidos.', 140.57, 8638.26, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de poliéster recubierta para lonas industriales', 'Tejido técnico impermeable para cubiertas y toldos pesados.', 308.15, 28456.43, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela conductora para blindaje electromagnético', 'Tejido técnico que atenúa interferencia electromagnética.', 406.73, 23525.86, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela técnica para trajes de motociclismo con protecciones', 'Tejido de alta abrasión para uso en motociclismo deportivo.', 105.13, 3094.96, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela filtrante de polipropileno para mascarillas industriales', 'Tejido técnico usado en fabricación de equipo de protección respiratoria.', 367.69, 16620.86, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla técnica de acero inoxidable tejida', 'Tejido metálico técnico para filtración industrial de alta precisión.', 362.22, 2687.19, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela para bolsas de aire de rescate (cojines neumáticos)', 'Tejido técnico de alta resistencia para equipos de rescate.', 406.27, 13741.17, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de fibra aramida para mangas de protección térmica', 'Tejido técnico resistente al calor para uso industrial.', 421.74, 34647.96, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela técnica para trajes espaciales de entrenamiento', 'Tejido especializado multicapa para simulación aeroespacial.', 249.04, 1110.08, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Geored de refuerzo para taludes', 'Material textil técnico para estabilización de pendientes.', 455.56, 19326.27, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela técnica antiestática para salas de servidores', 'Tejido técnico que previene descargas electrostáticas en centros de datos.', 436.65, 11017.25, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de fibra de vidrio tejida para aislamiento eléctrico', 'Tejido técnico dieléctrico usado en transformadores.', 97.1, 33349.1, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Membrana textil impermeabilizante para azoteas', 'Tejido técnico usado en sistemas de impermeabilización de techos.', 186.71, 6957.78, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela técnica para redes de pesca de alta resistencia', 'Tejido técnico usado en la industria pesquera comercial.', 188.73, 23998.35, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela para trajes de protección química nivel A', 'Tejido técnico impermeable a agentes químicos peligrosos.', 7.3, 21033.01, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Malla técnica de titanio para prótesis textiles', 'Material técnico biocompatible usado en dispositivos médicos.', 225.65, 20867.2, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de carbono para refuerzo de palos de golf', 'Tejido técnico ligero usado en artículos deportivos de alto rendimiento.', 64.78, 28726.3, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela técnica reflectante para señalización vial', 'Tejido técnico de alta visibilidad para uso en carreteras.', 409.19, 34686.14, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela de fibra de vidrio para tableros de circuitos', 'Tejido técnico usado como sustrato en placas electrónicas.', 163.88, 28591.86, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tela antimicrobiana técnica para uniformes hospitalarios', 'Tejido técnico tratado para reducir proliferación bacteriana.', 193.79, 30176.98, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (24, LAST_INSERT_ID());

-- Fertilizantes y Agroquímicos (categoria 25)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante NPK 17-17-17 saco 50kg', 'Fertilizante compuesto de liberación balanceada para cultivos.', 62.15, 21832.8, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sulfato de amonio granulado saco 50kg', 'Fertilizante nitrogenado con aporte de azufre.', 954.1, 12420.61, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fosfato diamónico (DAP) saco 50kg', 'Fertilizante fosfatado de alta concentración.', 513.8, 13309.71, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cloruro de potasio (KCl) saco 50kg', 'Fertilizante potásico para desarrollo radicular y frutos.', 537.79, 615.13, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante foliar rico en micronutrientes 1L', 'Producto líquido para aplicación foliar de nutrientes.', 967.46, 5670.1, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nitrato de calcio granulado saco 25kg', 'Fertilizante usado para prevención de deficiencias de calcio.', 183.21, 2656.62, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sulfato de magnesio (sal de epsom) saco 25kg', 'Fertilizante para corrección de deficiencias de magnesio.', 251.21, 20447.13, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante orgánico composta saco 40kg', 'Abono orgánico para mejora de estructura del suelo.', 31.04, 2502.14, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ácido húmico concentrado para suelos 1L', 'Bioestimulante para mejora de absorción de nutrientes.', 699.27, 4957.61, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Herbicida 2,4-D amina litro', 'Herbicida selectivo para control de malezas de hoja ancha.', 18.67, 15025.02, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Insecticida clorpirifos 48% litro', 'Insecticida organofosforado de amplio espectro.', 576.91, 13120.49, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fungicida azoxistrobina 25% litro', 'Fungicida sistémico de amplio espectro para cultivos.', 702.94, 2661.33, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Herbicida paraquat 20% litro', 'Herbicida de contacto no selectivo.', 869.66, 17955.74, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Insecticida imidacloprid 35% litro', 'Insecticida sistémico neonicotinoide para control de plagas chupadoras.', 46.13, 3163.92, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fungicida mancozeb 80% saco 20kg', 'Fungicida de contacto de amplio espectro protectante.', 494.1, 12568.81, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Regulador de crecimiento vegetal ácido giberélico', 'Producto para modificación del desarrollo vegetal.', 280.34, 3138.73, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nematicida fenamifos 40% litro', 'Producto para control de nematodos en el suelo.', 406.24, 3510.17, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante líquido rico en potasio 20L', 'Fertilizante concentrado para etapa de fructificación.', 592.22, 21541.15, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bioestimulante a base de algas marinas 1L', 'Producto orgánico para fortalecimiento de plantas.', 148.07, 14363.75, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante de liberación controlada Osmocote saco 25kg', 'Fertilizante granulado de liberación gradual.', 746.83, 4191.64, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Herbicida glufosinato de amonio litro', 'Herbicida no selectivo de amplio espectro de acción.', 826.19, 23445.77, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fungicida cúprico oxicloruro de cobre saco 25kg', 'Fungicida-bactericida de contacto para cultivos.', 389.36, 10570.05, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Insecticida piretroide cipermetrina 25% litro', 'Insecticida de contacto para control de plagas foliares.', 839.88, 13187.82, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante para césped rico en nitrógeno saco 20kg', 'Fertilizante granulado especializado para pastos ornamentales.', 396.24, 23538.17, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Molibdato de sodio micronutriente saco 25kg', 'Fertilizante especializado para corrección de deficiencias de molibdeno.', 777.13, 8529.86, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Zinc quelado agrícola EDTA litro', 'Micronutriente quelatado para corrección de deficiencias en cultivos.', 241.14, 8443.56, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante hidrosoluble 20-20-20 saco 25kg', 'Fertilizante completo para fertirrigación.', 436.15, 24532.4, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Coadyuvante agrícola surfactante 1L', 'Producto que mejora la adherencia de agroquímicos foliares.', 804.57, 22827.99, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bactericida agrícola a base de estreptomicina', 'Producto para control de enfermedades bacterianas en cultivos.', 815.23, 21206.0, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rodenticida anticoagulante para uso agrícola', 'Producto para control de roedores en almacenes agrícolas.', 54.5, 12982.62, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante para hidroponía fórmula base saco 25kg', 'Fertilizante especializado para sistemas de cultivo sin suelo.', 957.9, 23364.89, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fungicida sistémico tebuconazol 25% litro', 'Fungicida triazol de amplio espectro para cultivos extensivos.', 250.04, 10611.19, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Herbicida preemergente atrazina 90% saco 25kg', 'Herbicida selectivo para control de malezas en maíz y sorgo.', 633.06, 9174.36, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Acaricida abamectina 1.8% litro', 'Producto para control de ácaros en cultivos frutícolas.', 531.27, 1824.68, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante boro soluble agrícola saco 25kg', 'Micronutriente esencial para desarrollo floral y de frutos.', 433.61, 12668.89, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Insecticida biológico Bacillus thuringiensis litro', 'Bioinsecticida para control de larvas de lepidópteros.', 21.81, 3571.23, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante para cítricos fórmula especial saco 40kg', 'Fertilizante balanceado específico para producción citrícola.', 969.73, 19436.83, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Herbicida sulfosato 62% litro', 'Herbicida sistémico no selectivo de amplio espectro.', 937.0, 15866.97, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fungicida biológico Trichoderma harzianum saco 5kg', 'Biofungicida usado en control biológico de patógenos del suelo.', 809.46, 22120.89, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fertilizante granulado para hortalizas 15-15-15 saco 50kg', 'Fertilizante balanceado para producción de hortalizas comerciales.', 884.76, 955.9, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (25, LAST_INSERT_ID());

-- Combustibles y Lubricantes (categoria 26)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gasolina Magna a granel pipa 20000L', 'Combustible automotriz de octanaje regular.', 3209.66, 16019.74, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gasolina Premium a granel pipa 20000L', 'Combustible automotriz de alto octanaje.', 3393.8, 16478.64, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Diésel automotriz a granel pipa 20000L', 'Combustible para motores de combustión diésel.', 2713.56, 55470.58, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gas LP a granel tanque estacionario 500L', 'Combustible gaseoso para uso doméstico e industrial.', 3108.18, 15109.81, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Turbosina para aviación bidón 200L', 'Combustible especializado para turbinas de aeronaves.', 2603.92, 26078.11, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite lubricante 15W40 para diésel tambor 200L', 'Lubricante para motores diésel de alto desempeño.', 4754.57, 17322.62, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite de motor sintético 0W20 tambor 200L', 'Lubricante de alto rendimiento para motores modernos.', 1530.53, 38886.45, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grasa multiusos de calcio cubeta 17kg', 'Lubricante espeso para partes móviles industriales.', 606.3, 35697.92, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite hidráulico AW 68 tambor 200L', 'Fluido hidráulico para maquinaria industrial pesada.', 4780.64, 30875.35, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para transmisión automática ATF tambor 200L', 'Lubricante especializado para cajas automáticas.', 1345.72, 28038.4, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Combustóleo industrial pesado a granel', 'Combustible residual para calderas industriales.', 2671.49, 8989.6, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para engranajes SAE 90 tambor 200L', 'Lubricante para sistemas de transmisión de alta carga.', 623.98, 7969.02, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Petróleo crudo ligero a granel (para refinación)', 'Materia prima para procesos de refinación petroquímica.', 1471.53, 24451.99, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite dieléctrico mineral para transformadores tambor 200L', 'Aceite aislante para equipos eléctricos de potencia.', 1445.09, 14679.7, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grasa de litio complejo para rodamientos cubeta 17kg', 'Lubricante de alta temperatura para uso industrial.', 443.8, 32824.24, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Etanol anhidro combustible tambor 200L', 'Biocombustible usado como aditivo de gasolinas.', 4199.54, 36636.16, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Biodiésel B100 tambor 200L', 'Combustible renovable derivado de aceites vegetales.', 2853.05, 39056.41, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite base parafínico tambor 200L', 'Materia prima para formulación de lubricantes.', 1009.95, 42650.55, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grasa de silicona para sellos cubeta 5kg', 'Lubricante especializado resistente a altas temperaturas.', 2307.11, 32926.98, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para compresores de tornillo tambor 200L', 'Lubricante especializado para equipos de aire comprimido.', 3065.93, 28191.04, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Queroseno de uso industrial tambor 200L', 'Combustible destilado medio para uso en quemadores.', 1555.97, 14611.04, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Coque de petróleo a granel', 'Subproducto de refinación usado como combustible industrial.', 1111.8, 30795.73, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para motores marinos 2 tiempos tambor 200L', 'Lubricante especializado para motores fuera de borda.', 1918.94, 35182.43, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grasa grafitada para cadenas cubeta 17kg', 'Lubricante especializado para transmisiones por cadena.', 64.33, 21223.91, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para amortiguadores hidráulicos tambor 200L', 'Fluido especializado para sistemas de suspensión.', 4310.02, 14388.63, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gas natural comprimido (GNC) a granel', 'Combustible gaseoso para vehículos de transporte.', 2785.48, 29535.3, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite base nafténico tambor 200L', 'Materia prima especializada para lubricantes industriales.', 1427.68, 59251.88, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cera parafina para vela tipo combustible sólido', 'Producto derivado del petróleo para combustión controlada.', 1481.04, 46350.5, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para transmisiones manuales GL-5 tambor 200L', 'Lubricante para cajas de velocidades manuales de alta carga.', 797.04, 4101.25, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grasa anticorrosiva marina cubeta 17kg', 'Lubricante protector para equipo expuesto a ambiente salino.', 4357.01, 26455.17, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Diésel marino (MGO) a granel para embarcaciones', 'Combustible especializado para motores navales.', 314.77, 23334.44, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para motores de dos tiempos jardinería litro', 'Lubricante mezclable para herramientas de jardín.', 2202.29, 44151.24, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Nafta industrial solvente tambor 200L', 'Combustible ligero usado como disolvente industrial.', 550.68, 13587.51, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grasa para rodamientos de alta velocidad cubeta 5kg', 'Lubricante especializado para husillos y maquinaria de precisión.', 4796.73, 44344.37, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite para transformadores tipo inhibido tambor 200L', 'Aceite dieléctrico con aditivos antioxidantes.', 776.84, 20287.24, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Combustible de aviación Jet A-1 bidón 200L', 'Combustible especializado para motores de reacción.', 1765.51, 40553.1, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite de motor para motocicletas 10W40 tambor 200L', 'Lubricante especializado para motores de dos ruedas.', 3083.4, 51014.56, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Grasa de bisulfuro de molibdeno cubeta 17kg', 'Lubricante de alta presión para cargas extremas.', 4106.86, 31114.34, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Propano industrial a granel tanque estacionario', 'Gas combustible usado en procesos industriales de calor.', 3695.14, 44622.41, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aceite base sintética para compresores tambor 200L', 'Lubricante de alta duración para equipos de aire comprimido.', 3799.67, 28566.78, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (26, LAST_INSERT_ID());

-- Madera y Productos Forestales (categoria 27)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de pino radiata 1x6 3 metros', 'Madera aserrada para uso general en construcción.', 1570.96, 35485.89, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tablón de cedro rojo 2x10 4 metros', 'Madera resistente a la humedad para exteriores.', 1829.84, 6538.18, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Duela de encino para piso 1.2m2', 'Madera dura para acabado de pisos residenciales.', 1742.3, 415.33, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Triplay marino 18mm hoja 1.22x2.44', 'Panel de madera resistente al agua para uso náutico.', 1532.53, 29374.56, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('MDF (tablero de fibra) 15mm hoja 1.83x2.44', 'Tablero de fibra de densidad media para mueblería.', 998.28, 48144.57, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aglomerado de partículas 18mm hoja 1.83x2.44', 'Tablero para fabricación de muebles económicos.', 1146.06, 21011.92, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Poste de madera tratada para cerca 2.5m', 'Madera tratada con creosota para uso exterior.', 1568.45, 43663.51, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Viga de madera laminada estructural 6m', 'Elemento estructural de madera para construcción.', 1216.63, 19102.2, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tarima de madera estándar para paletizado', 'Plataforma de madera para manejo de carga industrial.', 907.31, 23003.54, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chapa de madera de nogal para enchapado', 'Lámina delgada decorativa de madera fina.', 1447.51, 14787.36, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Leña de mezquite para asador saco 20kg', 'Madera combustible para uso en parrillas y hornos.', 784.42, 27856.51, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Carbón vegetal en trozo saco 20kg', 'Combustible sólido derivado de carbonización de madera.', 772.08, 16235.29, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aserrín de pino a granel tonelada', 'Subproducto de aserradero usado en múltiples industrias.', 1575.22, 42508.4, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de cedro blanco para closet 1x8', 'Madera aromática usada en carpintería de interiores.', 1001.6, 22312.74, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Viga de madera de pino 4x4 3 metros', 'Madera estructural para construcción residencial.', 372.5, 15340.83, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Panel OSB (tablero de hebra orientada) 11mm', 'Tablero estructural para construcción y techado.', 294.26, 28856.55, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Duela de bambú prensado para piso 1.2m2', 'Material sostenible de alta dureza para pisos.', 1165.26, 4578.9, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Corcho aglomerado en rollo para aislamiento', 'Material forestal renovable usado como aislante.', 1840.72, 16328.57, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de caoba para ebanistería 1x10', 'Madera fina de alta calidad para muebles de lujo.', 1687.56, 41940.01, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Palo de escoba de madera torneada', 'Producto de madera para manufactura de utensilios de limpieza.', 1917.73, 10374.61, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Estacas de madera para construcción 1x2 60cm', 'Madera de uso temporal para trazo en obra civil.', 855.76, 45546.55, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Barrote de pino para andamio 4x4 3m', 'Madera estructural para soporte temporal en construcción.', 26.33, 2562.62, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Contrachapado de pino para encofrado 18mm', 'Panel de madera reutilizable para moldes de concreto.', 1132.04, 24967.4, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tablero de partículas resistente a humedad 18mm', 'Panel especializado para uso en zonas húmedas.', 1841.02, 38719.38, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Duela de pino tratada para exteriores (deck)', 'Madera tratada para terrazas y áreas exteriores.', 1079.31, 49916.71, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tronco de eucalipto para postería 6m', 'Madera rolliza usada en construcción rural y cercado.', 1037.31, 25959.83, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Viruta de madera para cama de animales saco 20kg', 'Subproducto de madera usado como cama para ganado y mascotas.', 1372.03, 19597.98, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de parota para muebles rústicos', 'Madera de gran veta usada en mobiliario artesanal.', 718.64, 29817.08, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Poste de madera para línea eléctrica 9m', 'Madera tratada para soporte de infraestructura eléctrica.', 705.46, 47405.42, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chapa decorativa de haya para muebles', 'Lámina fina de madera para acabados de mobiliario.', 1354.57, 26357.36, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tarima industrial reforzada de pino', 'Plataforma resistente para carga pesada en almacén.', 202.44, 18845.9, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cortezas de pino trituradas para jardinería saco 40L', 'Material forestal usado como cubresuelo ornamental.', 804.78, 28154.67, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Madera de balsa para modelismo 1x4x60cm', 'Madera ligera usada en manualidades y aeromodelismo.', 1150.24, 44015.79, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Listón de pino cepillado 1x2 2.44m', 'Madera de acabado para molduras y detalles de carpintería.', 1929.12, 24438.31, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Panel de fibrocemento con textura de madera', 'Material compuesto usado en fachadas exteriores.', 883.13, 31305.29, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rollizo de pino para postes rústicos 2.5m', 'Madera rolliza usada en cercado y construcción rural.', 1992.27, 17295.33, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Duela flotante laminada símil madera 1.5m2', 'Piso laminado de alta resistencia al desgaste.', 1062.63, 40831.13, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tablero de MDF hidrófugo verde 15mm', 'Tablero resistente a la humedad para cocinas y baños.', 345.59, 16040.27, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Astillas de madera para biomasa tonelada', 'Material forestal usado como combustible en calderas.', 1956.96, 41336.26, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de pino blanco para cimbra 1x12', 'Madera de uso temporal para moldeo de concreto.', 1027.62, 5703.48, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (27, LAST_INSERT_ID());

-- Papel y Cartón (categoria 28)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caja de cartón corrugado 40x30x30cm paquete 25pz', 'Empaque de cartón para envío y almacenamiento.', 894.62, 20727.63, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rollo de papel kraft 90cm x 100m', 'Papel resistente para empaque y envoltura industrial.', 820.73, 29708.43, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel couché brillante 150g caja 500h', 'Papel de alta calidad para impresión de folletos.', 888.26, 12684.53, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartulina opalina blanca 200g caja 500h', 'Cartulina de acabado fino para impresión y manualidades.', 157.24, 8768.8, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel higiénico institucional jumbo caja 12 rollos', 'Papel absorbente para dispensadores comerciales.', 512.09, 15196.13, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Toalla de papel interfoliada caja 24 paquetes', 'Papel absorbente para dispensadores de baño y cocina.', 188.92, 5554.06, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caja de cartón para mudanza extra grande', 'Empaque resistente para transporte de artículos voluminosos.', 630.47, 18133.52, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel bond blanco tamaño oficio caja 5000h', 'Papel de uso general para impresión y oficina.', 353.83, 29813.09, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartón gris compacto para empaque 2mm', 'Cartón resistente usado en la fabricación de cajas rígidas.', 636.88, 1365.18, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel periódico en rollo 55g tonelada', 'Papel económico usado en la industria editorial.', 412.01, 23650.31, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caja de cartón para pizza 30cm paquete 100pz', 'Empaque desechable para alimentos de comida rápida.', 307.43, 20751.87, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel encerado para alimentos rollo 300m', 'Papel con recubrimiento de cera para envoltura alimenticia.', 4.91, 9203.25, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartón microcorrugado para displays', 'Material ligero usado en exhibidores comerciales.', 842.32, 17627.39, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel térmico para ticket de punto de venta', 'Papel especializado para impresoras térmicas.', 668.44, 5979.85, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sobre de papel manila tamaño carta caja 500pz', 'Sobre resistente para archivo y envío de documentos.', 498.36, 16642.17, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rollo de papel para plotter 90cm x 50m', 'Papel especializado para impresión de planos técnicos.', 266.75, 19439.66, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel fotográfico satinado tamaño carta paquete 100h', 'Papel de alta calidad para impresión fotográfica.', 531.96, 29913.58, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartón piedra (chipboard) para forros de libro', 'Cartón rígido usado en encuadernación.', 574.89, 12391.9, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel de china de colores paquete 100h', 'Papel delgado decorativo para manualidades y empaque.', 122.38, 4787.45, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caja de cartón troquelada para e-commerce', 'Empaque personalizado para envío de productos en línea.', 759.74, 3288.72, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel autoadhesivo (etiqueta) tamaño carta paquete 100h', 'Papel con adhesivo para impresión de etiquetas.', 101.0, 5199.02, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartón dúplex para empaque de cosméticos', 'Cartón de calidad para empaque plegadizo comercial.', 522.97, 24711.91, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel filtro industrial para café en rollo', 'Papel poroso usado en procesos de filtración.', 613.39, 24217.34, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rollo de papel para caja registradora 57mm', 'Papel térmico compatible con terminales punto de venta.', 63.05, 473.49, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartón corrugado triple pared para exportación', 'Cartón reforzado para embalaje de carga pesada.', 770.81, 9752.38, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel vegetal traslúcido para diseño rollo', 'Papel especializado para dibujo técnico y arquitectónico.', 715.74, 10679.96, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tubo de cartón para envío de pósters 90cm', 'Empaque cilíndrico para protección de documentos enrollados.', 170.25, 8071.64, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel de estraza para envoltura de alimentos rollo', 'Papel resistente y económico para empaque general.', 100.36, 27125.27, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartulina cansón para arte 220g paquete 50h', 'Papel grueso usado en dibujo artístico y manualidades.', 582.68, 10531.92, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caja de cartón para huevo 30 piezas paquete', 'Empaque especializado para transporte de huevo fresco.', 450.39, 11631.13, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel biblia para impresión de libros delgados', 'Papel ultradelgado usado en ediciones de bajo gramaje.', 55.62, 26727.17, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rollo de papel para fax térmico', 'Papel especializado para equipos de fax tradicionales.', 583.08, 28792.42, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartón para separadores de botellas (divisiones)', 'Material estructural para empaque de bebidas en caja.', 440.2, 18643.32, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel adhesivo transparente para forrar libros rollo', 'Papel protector autoadhesivo para uso escolar.', 250.08, 1414.96, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartulina Bristol blanca 300g caja 250h', 'Cartulina rígida usada en impresión de tarjetas y portadas.', 930.89, 25655.99, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rollo de papel higiénico doméstico paquete 12pz', 'Papel absorbente de uso doméstico cotidiano.', 315.48, 26976.15, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Caja de cartón para archivo muerto tamaño oficio', 'Empaque especializado para almacenamiento de documentos.', 816.08, 9179.93, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel carbón para copias tamaño carta caja 100h', 'Papel especializado para reproducción manual de documentos.', 602.95, 28804.87, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cartón ondulado para separadores de charolas', 'Material de protección para empaque de productos frágiles.', 496.06, 28496.37, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Papel reciclado ecológico tamaño carta caja 500h', 'Papel de oficina elaborado con fibra reciclada.', 243.68, 11754.88, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (28, LAST_INSERT_ID());

-- Instrumentos Musicales (categoria 29)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Piano vertical Yamaha U1', 'Piano acústico de estudio con mecanismo de acción profesional.', 215.62, 27190.68, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Piano de cola Kawai GL-10', 'Piano de concierto compacto para espacios profesionales.', 92.95, 105136.69, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guitarra acústica Taylor 214ce', 'Guitarra electroacústica con cutaway y ecualizador integrado.', 145.47, 95296.57, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guitarra clásica Yamaha C40', 'Guitarra de nylon para estudiantes e intérpretes clásicos.', 73.24, 21477.34, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bajo eléctrico Fender Precision Bass', 'Bajo de 4 cuerdas con pastillas de precisión.', 107.71, 23037.09, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Violín 4/4 Stentor Student II', 'Violín de estudiante con estuche y arco incluidos.', 291.47, 35451.52, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Violonchelo 4/4 con estuche', 'Instrumento de cuerda frotada de registro grave.', 168.59, 14494.45, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Contrabajo acústico 3/4', 'Instrumento de cuerda de gran tamaño para orquesta y jazz.', 160.27, 46763.21, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Trompeta Bach Stradivarius 180S37', 'Instrumento de viento metal profesional en laca dorada.', 121.14, 8601.27, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Trombón de vara Bach 42B', 'Instrumento de viento metal para orquesta sinfónica.', 37.25, 99238.37, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Clarinete Buffet Crampon E13', 'Instrumento de viento madera de estudio avanzado.', 105.57, 29996.38, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Flauta traversa Yamaha 200 Series', 'Instrumento de viento madera con llaves plateadas.', 57.6, 34603.55, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Oboe profesional Fox 333', 'Instrumento de viento madera de doble lengüeta.', 71.38, 4961.97, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Fagot Fox Renard Model 41', 'Instrumento de viento madera de registro grave.', 199.38, 41497.4, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tuba Sinfónica Miraphone', 'Instrumento de viento metal de gran tamaño para orquesta.', 47.02, 84939.84, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Corno francés Holton H179', 'Instrumento de viento metal con doble juego de tubos.', 28.06, 32944.39, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Batería acústica Tama Imperialstar 5 piezas', 'Set completo de batería con platillos y hardware.', 250.55, 16033.09, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Teclado sintetizador Korg Kronos', 'Estación de trabajo musical profesional programable.', 133.16, 100488.77, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Órgano electrónico Hammond XK-5', 'Órgano portátil con emulación de tonewheel clásico.', 241.54, 19779.26, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Acordeón diatónico Hohner Corona', 'Instrumento de fuelle usado en música tradicional.', 106.07, 86917.98, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Arpa de concierto Lyon & Healy', 'Instrumento de cuerda pulsada de gran formato para orquesta.', 113.26, 115041.67, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Ukulele soprano Kala KA-15S', 'Instrumento de cuerda pequeño de origen hawaiano.', 62.66, 114151.93, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Banjo de 5 cuerdas Deering Goodtime', 'Instrumento de cuerda usado en música bluegrass.', 151.6, 27890.94, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mandolina Kentucky KM-150', 'Instrumento de cuerda pulsada de ocho cuerdas.', 135.97, 16408.63, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Marimba de concierto 4.3 octavas', 'Instrumento de percusión de placas de madera afinadas.', 212.03, 31882.57, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Xilófono orquestal profesional', 'Instrumento de percusión melódica de placas metálicas.', 269.92, 70837.6, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Timbales sinfónicos Adams Symphonic', 'Instrumento de percusión afinable para orquesta.', 110.59, 30153.08, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Congas LP Aspire 11 y 12 pulgadas', 'Instrumento de percusión de origen afrocubano.', 182.58, 26135.0, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bongó de madera profesional', 'Par de tambores pequeños de percusión afrolatina.', 261.76, 15436.44, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Vibráfono Musser M55', 'Instrumento de percusión melódica con motor de trémolo.', 154.05, 65477.07, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guitarra eléctrica Gibson Les Paul Standard', 'Guitarra de cuerpo sólido con pastillas humbucker.', 81.34, 92791.92, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Amplificador de guitarra Marshall JCM800', 'Amplificador de válvulas para guitarra eléctrica.', 115.63, 79176.56, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Amplificador de bajo Ampeg SVT-4 Pro', 'Amplificador de potencia especializado para bajo eléctrico.', 170.43, 37846.04, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Saxofón tenor Selmer Series III', 'Instrumento de viento metal profesional para jazz y orquesta.', 117.16, 11055.61, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Gaita escocesa tradicional', 'Instrumento de viento con fuelle de origen celta.', 53.36, 102239.5, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Didgeridoo de madera tallada', 'Instrumento de viento tradicional aborigen australiano.', 96.51, 79799.66, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sitar indio tradicional', 'Instrumento de cuerda usado en música clásica de la India.', 32.96, 67789.29, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Kalimba de 17 teclas de madera', 'Instrumento de lengüetas metálicas de origen africano.', 108.64, 60443.57, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Melódica Hohner Student 32', 'Instrumento de viento con teclado de fácil aprendizaje.', 89.3, 8656.59, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cajón peruano de percusión', 'Instrumento de percusión de caja usado en flamenco y folclore.', 93.59, 27789.84, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (29, LAST_INSERT_ID());

-- Artículos Deportivos (categoria 30)
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Balón de fútbol Adidas Champions League', 'Balón oficial de competición con superficie termosellada.', 25.31, 28724.35, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Balón de básquetbol Spalding NBA oficial', 'Balón reglamentario de cuero compuesto para cancha.', 56.54, 16254.45, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guante de béisbol Wilson A2000', 'Guante profesional de piel para posición de campo.', 181.79, 31044.87, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bate de béisbol de aluminio Easton', 'Bate ligero de alto rendimiento para bateo.', 176.56, 34478.96, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Raqueta de bádminton Yonex Astrox', 'Raqueta ligera de grafito para juego competitivo.', 26.52, 11205.54, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Pelota de tenis Wilson US Open tubo 3', 'Pelota de fieltro reglamentaria para cancha dura.', 6.01, 27249.06, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de surf de fibra de vidrio 6''2"', 'Tabla deportiva para práctica de surf en olas medianas.', 132.76, 14186.88, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Casco de ciclismo Giro Aether MIPS', 'Casco aerodinámico con sistema de protección MIPS.', 82.57, 26430.73, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guantes de boxeo Everlast 16oz', 'Guantes acolchados para entrenamiento y sparring.', 139.88, 10087.16, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de pesas olímpicas 100kg con barra', 'Equipo de entrenamiento de fuerza para levantamiento.', 169.36, 14214.12, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Kayak inflable de una plaza', 'Embarcación ligera para deportes acuáticos recreativos.', 125.8, 7429.94, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de snowboard Burton Custom', 'Tabla deportiva para descenso en nieve.', 23.13, 36524.9, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Esquís alpinos Rossignol Experience', 'Par de esquís para descenso en pista.', 146.84, 28560.97, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bicicleta de ruta Specialized Allez', 'Bicicleta ligera de carbono para ciclismo de carretera.', 8.19, 1791.94, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Balón de voleibol Mikasa V200W oficial', 'Balón reglamentario para competición internacional.', 32.49, 8083.89, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Colchoneta de yoga antiderrapante 6mm', 'Tapete de práctica con buen agarre y amortiguación.', 60.68, 15353.53, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cuerda para saltar con contador digital', 'Equipo de entrenamiento cardiovascular portátil.', 7.94, 12574.49, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guante de portero de fútbol Adidas Predator', 'Guante especializado con protección de dedos.', 127.7, 7350.93, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de golf completo Callaway Strata', 'Juego de palos de golf para jugador principiante.', 167.91, 22892.58, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Patines en línea Rollerblade Zetrablade', 'Patines deportivos con ruedas de poliuretano.', 143.36, 10337.42, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Casco de motociclismo Shoei RF-1400', 'Casco integral certificado para uso en motociclismo.', 87.04, 27436.24, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Traje de neopreno para triatlón O''Neill', 'Traje de baja fricción para nado en aguas abiertas.', 69.87, 238.68, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Red de voleibol de playa portátil', 'Sistema desmontable de red para juego en arena.', 166.87, 31103.64, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Mancuernas ajustables Bowflex SelectTech', 'Equipo de entrenamiento de peso variable para gimnasio en casa.', 57.34, 1909.8, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Bicicleta de montaña Trek Marlin 8', 'Bicicleta todo terreno con suspensión delantera.', 170.84, 24374.01, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Palos de hockey sobre hielo Bauer Nexus', 'Bastón de composite para juego de hockey sobre hielo.', 9.56, 9929.39, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Balón de rugby Gilbert oficial', 'Balón ovalado reglamentario para competición.', 22.33, 31699.22, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Set de arquería recurvo para principiantes', 'Equipo completo de tiro con arco deportivo.', 42.11, 36596.36, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guantes de portería de hockey Bauer Supreme', 'Guante especializado de protección para portero.', 149.93, 3628.25, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Tabla de paddle surf inflable (SUP) 10''6"', 'Tabla inflable versátil para remo de pie.', 138.97, 15866.69, 2);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Casco de esquí Smith Vantage MIPS', 'Casco térmico con ventilación ajustable para nieve.', 149.54, 33183.94, 3);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guantes de ciclismo de montaña Fox Racing', 'Guantes con protección de nudillos para ciclismo todo terreno.', 56.31, 3779.36, 4);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Red de bádminton portátil con postes', 'Sistema desmontable de red para práctica recreativa.', 189.28, 17074.23, 5);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Chaleco salvavidas para deportes acuáticos', 'Equipo de flotación certificado para actividades náuticas.', 186.05, 27726.5, 6);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Rodilleras de voleibol Mizuno', 'Protección acolchada para práctica de voleibol.', 147.75, 33233.58, 7);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Aletas de natación Speedo Biofuse', 'Equipo de propulsión para entrenamiento de nado.', 125.66, 18220.66, 8);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Cinturón de levantamiento de pesas de cuero', 'Equipo de soporte lumbar para entrenamiento de fuerza.', 10.95, 27990.56, 9);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Banda de resistencia elástica set 5 niveles', 'Equipo de entrenamiento funcional portátil.', 85.73, 20572.87, 10);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Guante de esgrima FIE homologado', 'Equipo de protección para práctica de esgrima competitiva.', 185.63, 5280.26, 11);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());
INSERT INTO producto (nombre, descripcion, peso, valor_unitario, paquete) VALUES ('Sistema de portería de fútbol portátil 3x2m', 'Estructura desmontable para práctica de fútbol.', 152.41, 1938.91, 1);
INSERT INTO categorias_productos_rel (categorias, productos) VALUES (30, LAST_INSERT_ID());

ALTER TABLE inspeccion ADD COLUMN motivo_segunda VARCHAR(500) NULL;
