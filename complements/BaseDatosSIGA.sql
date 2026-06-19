-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost
-- Tiempo de generación: 19-06-2026 a las 05:28:34
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `BaseDatosSIGA`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `aduana`
--

CREATE TABLE `aduana` (
  `codigo` int(11) NOT NULL,
  `ciudad` varchar(60) NOT NULL,
  `nombre` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `aduana`
--

INSERT INTO `aduana` (`codigo`, `ciudad`, `nombre`) VALUES
(160, 'Veracruz', 'Aduana de Veracruz (Marítima)'),
(200, 'Nuevo Laredo', 'Aduana de Nuevo Laredo'),
(240, 'Colombia', 'Aduana de Colombia (Fronteriza)'),
(300, 'Altamira', 'Aduana de Altamira'),
(400, 'Tijuana', 'Aduana de Tijuana (Fronteriza)'),
(500, 'Ciudad de México', 'Aduana del AICM (Aérea)'),
(650, 'Ciudad Juárez', 'Aduana de Ciudad Juárez (Fronteriza)'),
(720, 'Cancún', 'Aduana de Cancún (Aérea)'),
(800, 'Manzanillo', 'Aduana de Manzanillo (Marítima)'),
(810, 'Lázaro Cárdenas', 'Aduana de Lázaro Cárdenas (Marítima)');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `arancel`
--

CREATE TABLE `arancel` (
  `numero` int(11) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `IGI` decimal(5,2) NOT NULL,
  `tasa_interes` decimal(5,2) NOT NULL,
  `Tipo_Arancel` int(11) NOT NULL,
  `pedimento` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `arancel`
--

INSERT INTO `arancel` (`numero`, `subtotal`, `descripcion`, `IGI`, `tasa_interes`, `Tipo_Arancel`, `pedimento`) VALUES
(1, 15000.00, 'Arancel general para importación de rollos textiles.', 15.00, 0.00, 1, '24 40 3991 4001254'),
(2, 0.00, 'Exención arancelaria por certificado fitosanitario de origen.', 0.00, 0.00, 1, '24 80 3991 8000412'),
(3, 45000.00, 'Arancel químico tasa general.', 5.00, 0.00, 1, '24 20 3991 2004112'),
(4, 2500.00, 'Tasa especial suplementos alimenticios.', 10.00, 0.00, 1, '24 50 3991 5001235'),
(5, 4000.00, 'Tasa maderas finas protegidas.', 20.00, 0.00, 1, '24 40 3991 4005512'),
(6, 12000.00, 'Beneficio cupo SE automotriz.', 0.00, 0.00, 1, '24 16 3991 1600122'),
(7, 34200.00, 'Arancel cárnico regular.', 12.00, 0.00, 1, '24 80 3991 8009941'),
(8, 0.00, 'Tratado de Libre Comercio con EE.UU. componentes.', 0.00, 0.00, 1, '24 65 3991 6500123'),
(9, 250.00, 'Tasa insumos básicos IMMEX.', 5.00, 0.00, 1, '24 40 3991 4008124'),
(10, 48.00, 'Arancel instrumental médico general.', 10.00, 0.00, 1, '24 24 3991 2400115');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add permission', 1, 'add_permission'),
(2, 'Can change permission', 1, 'change_permission'),
(3, 'Can delete permission', 1, 'delete_permission'),
(4, 'Can view permission', 1, 'view_permission'),
(5, 'Can add group', 2, 'add_group'),
(6, 'Can change group', 2, 'change_group'),
(7, 'Can delete group', 2, 'delete_group'),
(8, 'Can view group', 2, 'view_group'),
(9, 'Can add content type', 3, 'add_contenttype'),
(10, 'Can change content type', 3, 'change_contenttype'),
(11, 'Can delete content type', 3, 'delete_contenttype'),
(12, 'Can view content type', 3, 'view_contenttype'),
(13, 'Can add log entry', 4, 'add_logentry'),
(14, 'Can change log entry', 4, 'change_logentry'),
(15, 'Can delete log entry', 4, 'delete_logentry'),
(16, 'Can view log entry', 4, 'view_logentry'),
(17, 'Can add session', 5, 'add_session'),
(18, 'Can change session', 5, 'change_session'),
(19, 'Can delete session', 5, 'delete_session'),
(20, 'Can view session', 5, 'view_session'),
(21, 'Can add Usuario', 6, 'add_usuario'),
(22, 'Can change Usuario', 6, 'change_usuario'),
(23, 'Can delete Usuario', 6, 'delete_usuario'),
(24, 'Can view Usuario', 6, 'view_usuario'),
(25, 'Can add usuario', 7, 'add_usuario'),
(26, 'Can change usuario', 7, 'change_usuario'),
(27, 'Can delete usuario', 7, 'delete_usuario'),
(28, 'Can view usuario', 7, 'view_usuario');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bitacora`
--

CREATE TABLE `bitacora` (
  `numero` int(11) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bitacora`
--

INSERT INTO `bitacora` (`numero`, `descripcion`, `fecha`, `hora`) VALUES
(1, 'Usuario admin_tij inició sesión desde IP 192.168.1.50', '2024-03-01', '08:00:00'),
(2, 'Registro de nuevo pedimento TIJ-2024-881', '2024-03-01', '08:45:00'),
(3, 'Actualización de estatus de operación ID 1 a Finalizado', '2024-03-01', '12:30:00'),
(4, 'Usuario log_user1 inició sesión.', '2024-03-01', '13:00:00'),
(5, 'Fallo de autenticación para usuario externo_3', '2024-03-01', '15:22:00'),
(6, 'Generación de reporte mensual de incidencias', '2024-03-02', '09:00:00'),
(7, 'Alta de nuevo cliente en la plataforma', '2024-03-02', '11:14:00'),
(8, 'Modificación de parámetros de aranceles Ad-valorem', '2024-03-03', '10:30:00'),
(9, 'Eliminación de paquete de prueba ID 999', '2024-03-04', '16:45:00'),
(10, 'Cierre de bitácora diaria automatizado', '2024-03-04', '23:59:59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias_productos_rel`
--

CREATE TABLE `categorias_productos_rel` (
  `categorias` int(11) NOT NULL,
  `productos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias_productos_rel`
--

INSERT INTO `categorias_productos_rel` (`categorias`, `productos`) VALUES
(1, 1),
(1, 3),
(2, 8),
(2, 11),
(3, 2),
(3, 12),
(4, 10),
(5, 4),
(5, 13),
(6, 5),
(6, 14),
(7, 6),
(7, 15),
(8, 7),
(10, 9);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_productos`
--

CREATE TABLE `categoria_productos` (
  `numero` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `arancel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categoria_productos`
--

INSERT INTO `categoria_productos` (`numero`, `nombre`, `descripcion`, `arancel`) VALUES
(1, 'Textiles', 'Prendas de vestir, rollos de tela y fibras hiladas.', 1),
(2, 'Perecederos / Alimentos', 'Frutas, verduras y productos del campo frescos.', 2),
(3, 'Químicos e Industriales', 'Resinas, soluciones y compuestos químicos de uso de fábrica.', 3),
(4, 'Médicos y Farmacéuticos', 'Medicamentos, material de curación y equipamiento médico.', 4),
(5, 'Maquinaria Pesada', 'Componentes industriales y tornos de gran volumen.', 5),
(6, 'Electrónicos y Tecnología', 'Microprocesadores, pantallas y circuitos integrados.', 6),
(7, 'Bebidas y Alcoholes', 'Destilados, vinos y licores listos para comercializar.', 7),
(8, 'Metales y Siderurgia', 'Láminas, vigas de acero y derivados de metal.', 8),
(9, 'Agrícolas', 'Lotes de semillas y productos vegetales sin procesar.', 9),
(10, 'Automotriz', 'Vehículos terminados y autopartes de ensamble.', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `numero` int(11) NOT NULL,
  `nombre` varchar(80) NOT NULL,
  `primer_apell` varchar(40) DEFAULT NULL,
  `seg_apell` varchar(40) DEFAULT NULL,
  `tipo_persona` varchar(20) NOT NULL,
  `RFC` varchar(13) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`numero`, `nombre`, `primer_apell`, `seg_apell`, `tipo_persona`, `RFC`) VALUES
(1, 'Carlos', 'Martínez', 'López', 'Física', 'MALC850312HBC'),
(2, 'María', 'Rodríguez', 'Torres', 'Física', 'ROTM900615MDF'),
(3, 'Importaciones del Norte SA de CV', NULL, NULL, 'Moral', 'INSA010101ABC'),
(4, 'José', 'Hernández', 'Ramírez', 'Física', 'HERJ780923HBC'),
(5, 'Logística Fronteriza SA de CV', NULL, NULL, 'Moral', 'LFSA150601XYZ'),
(6, 'Ana', 'García', 'Soto', 'Física', 'GASA950204MBC'),
(7, 'Comercializadora Pacífico SC', NULL, NULL, 'Moral', 'CPSC200305DEF'),
(8, 'Luis', 'Pérez', 'Méndez', 'Física', 'PEML820717HBC'),
(9, 'Grupo Aduanal del Sur SA', NULL, NULL, 'Moral', 'GASA110808GHI'),
(10, 'Rosa', 'Fuentes', 'Castillo', 'Física', 'FUCR930930MBC'),
(11, 'José María', 'Ochoa', 'Velasco', 'Física', 'OCVJ980418HBC'),
(12, 'Arturo', 'Vallado', 'Ruiz', 'Física', 'VARA850204MDF'),
(13, 'Aduanas Océano Pacífico', NULL, NULL, 'Moral', 'AOPA070512JKL'),
(14, 'Sofía', 'Castro', 'Guzmán', 'Física', 'CAGS911102XYZ'),
(15, 'Distribuidora Global S.A.', NULL, NULL, 'Moral', 'DGLO990101FFA');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `correo_electronico`
--

CREATE TABLE `correo_electronico` (
  `numero` int(11) NOT NULL,
  `correoElec` varchar(80) NOT NULL,
  `cliente` int(11) NOT NULL,
  `usuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `correo_electronico`
--

INSERT INTO `correo_electronico` (`numero`, `correoElec`, `cliente`, `usuario`) VALUES
(1, 'carlos.mtz@gmail.com', 1, 1),
(2, 'maria.rod@hotmail.com', 2, 1),
(3, 'contacto@importacionesnorte.com', 3, 2),
(4, 'jose.hernandez@outlook.com', 4, 3),
(5, 'operaciones@logisticafront.com', 5, 2),
(6, 'ana.garcia.soto@gmail.com', 6, 3),
(7, 'ventas@compacifico.com', 7, 7),
(8, 'luis.perez.m@yahoo.com', 8, 5),
(9, 'direccion@grupoaduanalsur.com', 9, 7),
(10, 'rosa.fuentes@gmail.com', 10, 9);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(6, 'accounts', 'usuario'),
(4, 'admin', 'logentry'),
(2, 'auth', 'group'),
(1, 'auth', 'permission'),
(3, 'contenttypes', 'contenttype'),
(7, 'home', 'usuario'),
(5, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'home', '0001_initial', '2026-06-19 01:30:03.950183'),
(2, 'contenttypes', '0001_initial', '2026-06-19 01:30:04.068501'),
(3, 'admin', '0001_initial', '2026-06-19 01:30:04.118246'),
(4, 'admin', '0002_logentry_remove_auto_add', '2026-06-19 01:30:04.216090'),
(5, 'admin', '0003_logentry_add_action_flag_choices', '2026-06-19 01:30:04.336849'),
(6, 'contenttypes', '0002_remove_content_type_name', '2026-06-19 01:30:04.419784'),
(7, 'auth', '0001_initial', '2026-06-19 01:30:04.502294'),
(8, 'auth', '0002_alter_permission_name_max_length', '2026-06-19 01:30:04.552360'),
(9, 'auth', '0003_alter_user_email_max_length', '2026-06-19 01:30:04.612021'),
(10, 'auth', '0004_alter_user_username_opts', '2026-06-19 01:30:04.661212'),
(11, 'auth', '0005_alter_user_last_login_null', '2026-06-19 01:30:04.754700'),
(12, 'auth', '0006_require_contenttypes_0002', '2026-06-19 01:30:04.837387'),
(13, 'auth', '0007_alter_validators_add_error_messages', '2026-06-19 01:30:04.909197'),
(14, 'auth', '0008_alter_user_username_max_length', '2026-06-19 01:30:04.981148'),
(15, 'auth', '0009_alter_user_last_name_max_length', '2026-06-19 01:30:05.403119'),
(16, 'auth', '0010_alter_group_name_max_length', '2026-06-19 01:30:05.486124'),
(17, 'auth', '0011_update_proxy_permissions', '2026-06-19 01:30:05.546050'),
(18, 'auth', '0012_alter_user_first_name_max_length', '2026-06-19 01:30:05.684376'),
(19, 'sessions', '0001_initial', '2026-06-19 01:30:05.767058');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_pago`
--

CREATE TABLE `estado_pago` (
  `codigo` int(11) NOT NULL,
  `concepto` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `pago` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado_pago`
--

INSERT INTO `estado_pago` (`codigo`, `concepto`, `descripcion`, `pago`) VALUES
(1, 'Liquidado', 'El pago ha sido procesado y validado en el sistema bancario de la aduana.', 'TXN-99823122'),
(2, 'Liquidado', 'Impuestos de importación ordinarios aplicados.', 'TXN-88124151'),
(3, 'Liquidado', 'Prevalidación del archivo de pedimento exitosa.', 'TXN-77412399'),
(4, 'Liquidado', 'Cuotas de compensación por acero extranjero cobradas.', 'TXN-66512311'),
(5, 'Liquidado', 'Multa administrativa de inspección pagada.', 'TXN-55412388'),
(6, 'Liquidado', 'DTA básico para salida del país.', 'TXN-44123511'),
(7, 'Liquidado', 'Pago masivo de IVA en importación temporal.', 'TXN-33211599'),
(8, 'Liquidado', 'Validación de DTA de re-ingreso.', 'TXN-22199411'),
(9, 'Liquidado', 'Servicio de piso fiscalizado cobrado.', 'TXN-11088211'),
(10, 'Liquidado', 'Pago final de salida aduanera.', 'TXN-00177311');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `codigo` int(11) NOT NULL,
  `IVA` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `total` decimal(12,2) NOT NULL,
  `folio_fiscal` varchar(50) NOT NULL,
  `fecha_factura` date NOT NULL,
  `ID_operacion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`codigo`, `IVA`, `subtotal`, `total`, `folio_fiscal`, `fecha_factura`, `ID_operacion`) VALUES
(1, 56000.00, 350000.00, 406000.00, '4A9F21B0-8812-4C11-AA77-BB2394DF110A', '2024-03-01', 1),
(2, 19200.00, 120000.00, 139200.00, '7B1A32C4-9913-5D22-BB88-CC3405EG221B', '2024-03-02', 2),
(3, 144000.00, 900000.00, 1044000.00, '1C2B43D5-0024-6E33-CC99-DD4516FH332C', '2024-03-02', 3),
(4, 8000.00, 50000.00, 58000.00, '3D4C54E6-1135-7F44-DD00-EE5627IJ443D', '2024-03-02', 4),
(5, 3200.00, 20000.00, 23200.00, '5E6D65F7-2246-8A55-EE11-FF6738JK554E', '2024-03-03', 5),
(6, 24000.00, 150000.00, 174000.00, '6F7E76G8-3357-9B66-FF22-AA7849LM665F', '2024-03-03', 6),
(7, 45600.00, 285000.00, 330600.00, '8G9F87H9-4468-0C77-AA33-BB8950MN776G', '2024-03-04', 7),
(8, 1568.00, 9800.00, 11368.00, '9H0A98I0-5579-1D88-BB44-CC9061OP887H', '2024-03-04', 8),
(9, 200.00, 1250.00, 1450.00, '0I1B09J1-6680-2E99-CC55-DD0172QR998I', '2024-03-05', 9),
(10, 76.80, 480.00, 556.80, '1J2C10K2-7791-3F00-DD66-EE1283ST009J', '2024-03-05', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `incidencia`
--

CREATE TABLE `incidencia` (
  `codigo` int(11) NOT NULL,
  `gravedad` varchar(30) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  `inspeccion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `incidencia`
--

INSERT INTO `incidencia` (`codigo`, `gravedad`, `descripcion`, `inspeccion`) VALUES
(1, 'Media', 'Diferencia en el peso declarado en el pedimento (+5% detectado).', 2),
(2, 'Alta', 'Falta de certificado fitosanitario vigente para el lote alimenticio.', 4),
(3, 'Baja', 'Error tipográfico en la dirección de la factura del proveedor extranjero.', 2),
(4, 'Alta', 'Fracción arancelaria incorrecta para evitar el pago de cuotas compensatorias.', 8),
(5, 'Media', 'Embalaje de madera no muestra los sellos oficiales de la norma NOM-144.', 10),
(6, 'Baja', 'Inconsistencia menor en los números de serie del equipo electrónico.', 2),
(7, 'Alta', 'Mercancía no declarada oculta en el fondo del contenedor.', 10),
(8, 'Media', 'Monto de valor unitario declarado visiblemente inferior al valor de mercado.', 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inspeccion`
--

CREATE TABLE `inspeccion` (
  `numero` int(11) NOT NULL,
  `fecha_inspeccion` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `resultado` varchar(20) DEFAULT NULL,
  `semaforo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inspeccion`
--

INSERT INTO `inspeccion` (`numero`, `fecha_inspeccion`, `hora_inicio`, `resultado`, `semaforo`) VALUES
(1, '2024-03-01', '09:45:00', 'Aprobado', 2),
(2, '2024-03-01', '14:00:00', 'Incidencia', 4),
(3, '2024-03-02', '10:15:00', 'Aprobado', 2),
(4, '2024-03-02', '17:20:00', 'Incidencia', 7),
(5, '2024-03-03', '09:35:00', 'Aprobado', 2),
(6, '2024-03-03', '14:10:00', 'Aprobado', 4),
(7, '2024-03-04', '11:15:00', 'Aprobado', 2),
(8, '2024-03-04', '17:40:00', 'Incidencia', 7),
(9, '2024-03-05', '10:00:00', 'Aprobado', 2),
(10, '2024-03-05', '21:15:00', 'Incidencia', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inspeccion_inspector`
--

CREATE TABLE `inspeccion_inspector` (
  `inspeccion` int(11) NOT NULL,
  `inspector_adu` varchar(20) NOT NULL,
  `observaciones` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inspeccion_inspector`
--

INSERT INTO `inspeccion_inspector` (`inspeccion`, `inspector_adu`, `observaciones`) VALUES
(1, 'INS001', 'Revisión documental y física sin novedades.'),
(2, 'INS002', 'Se detecta discrepancia de bultos en palé central.'),
(3, 'INS001', 'Todo en orden con el cargamento automotriz.'),
(4, 'INS003', 'El cargamento de frutas no cuenta con sello fitosanitario.'),
(5, 'INS004', 'Revisión exprés en andén 4 sin observaciones.'),
(6, 'INS005', 'Verificación física de maquinaria aprobada.'),
(7, 'INS006', 'Exportación de electrónicos liberada.'),
(8, 'INS002', 'Fracción declarada no corresponde con los textiles.'),
(9, 'INS007', 'Muestreo de químicos completado.'),
(10, 'INS008', 'Cajas al fondo no corresponden a lo declarado.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inspector_aduanero`
--

CREATE TABLE `inspector_aduanero` (
  `matricula` varchar(20) NOT NULL,
  `no_gafete` varchar(25) NOT NULL,
  `nombre_pila` varchar(40) NOT NULL,
  `primer_apell` varchar(40) NOT NULL,
  `seg_apell` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inspector_aduanero`
--

INSERT INTO `inspector_aduanero` (`matricula`, `no_gafete`, `nombre_pila`, `primer_apell`, `seg_apell`) VALUES
('INS001', 'GAF-99231', 'Roberto', 'Gómez', 'Sánchez'),
('INS002', 'GAF-88122', 'Laura', 'Elena', 'Díaz'),
('INS003', 'GAF-77451', 'Alejandro', 'Meza', 'Luna'),
('INS004', 'GAF-66512', 'Patricia', 'Arredondo', 'Cruz'),
('INS005', 'GAF-55419', 'Ricardo', 'Benítez', 'Morales'),
('INS006', 'GAF-44123', 'Diana', 'Villalobos', 'Silva'),
('INS007', 'GAF-33211', 'Fernando', 'Guerrero', 'Ríos'),
('INS008', 'GAF-22199', 'Gabriela', 'Mendoza', 'Pantoja'),
('INS009', 'GAF-11088', 'Hugo', 'Salgado', 'Cortés'),
('INS010', 'GAF-00177', 'Mónica', 'Estrada', 'Chávez');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `operacion_aduanera`
--

CREATE TABLE `operacion_aduanera` (
  `ID_operacion` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_final` date DEFAULT NULL,
  `tipo_operacion` varchar(20) NOT NULL,
  `cliente` int(11) NOT NULL,
  `usuario` int(11) NOT NULL,
  `bitacora` int(11) NOT NULL,
  `aduana` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `operacion_aduanera`
--

INSERT INTO `operacion_aduanera` (`ID_operacion`, `fecha_inicio`, `fecha_final`, `tipo_operacion`, `cliente`, `usuario`, `bitacora`, `aduana`) VALUES
(1, '2024-03-01', '2024-03-01', 'Importación', 3, 1, 3, 400),
(2, '2024-03-02', NULL, 'Exportación', 1, 2, 4, 800),
(3, '2024-03-02', '2024-03-03', 'Importación', 5, 3, 2, 200),
(4, '2024-03-02', NULL, 'Importación', 7, 3, 7, 500),
(5, '2024-03-03', '2024-03-04', 'Exportación', 2, 1, 3, 400),
(6, '2024-03-03', NULL, 'Importación', 9, 7, 6, 160),
(7, '2024-03-04', '2024-03-05', 'Exportación', 13, 2, 8, 800),
(8, '2024-03-04', NULL, 'Importación', 15, 5, 9, 650),
(9, '2024-03-05', '2024-03-05', 'Importación', 4, 9, 10, 400),
(10, '2024-03-05', NULL, 'Exportación', 6, 2, 4, 240);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pago`
--

CREATE TABLE `pago` (
  `no_transaccion` varchar(50) NOT NULL,
  `numero_pago` int(11) NOT NULL,
  `concepto` varchar(100) NOT NULL,
  `saldo_final` decimal(12,2) NOT NULL,
  `monto` decimal(12,2) NOT NULL,
  `fecha_pago` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pago`
--

INSERT INTO `pago` (`no_transaccion`, `numero_pago`, `concepto`, `saldo_final`, `monto`, `fecha_pago`) VALUES
('TXN-00177311', 10, 'Liquidación General de Impuestos', 0.00, 32150.00, '2024-03-05'),
('TXN-11088211', 9, 'Almacenaje Fiscalizado Aduana 400', 0.00, 18900.00, '2024-03-05'),
('TXN-22199411', 8, 'DTA Recinto Fiscalizado', 0.00, 840.00, '2024-03-04'),
('TXN-33211599', 7, 'IVA de Importación de Maquinaria', 0.00, 456000.00, '2024-03-03'),
('TXN-44123511', 6, 'Derecho de Trámite Aduanero EXPO', 0.00, 420.00, '2024-03-02'),
('TXN-55412388', 5, 'Multa de Comercio Exterior Liquidad', 0.00, 15400.00, '2024-03-02'),
('TXN-66512311', 4, 'Cuota Compensatoria Lote Acero', 0.00, 120500.00, '2024-03-02'),
('TXN-77412399', 3, 'Prevalidación Electrónica y DTA', 0.00, 3410.00, '2024-03-01'),
('TXN-88124151', 2, 'Impuesto General de Importación (IGI)', 0.00, 14500.00, '2024-03-01'),
('TXN-99823122', 1, 'Derecho de Trámite Aduanero e IVA', 0.00, 72080.00, '2024-02-28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paquete`
--

CREATE TABLE `paquete` (
  `codigo` int(11) NOT NULL,
  `peso` decimal(10,2) NOT NULL,
  `tipo_embalaje` varchar(30) NOT NULL,
  `dimensions` varchar(50) DEFAULT NULL,
  `ope_aduanera` int(11) NOT NULL,
  `pedimento` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `paquete`
--

INSERT INTO `paquete` (`codigo`, `peso`, `tipo_embalaje`, `dimensions`, `ope_aduanera`, `pedimento`) VALUES
(1, 1250.50, 'Palé de madera (Pallet)', '1.20 x 1.00 x 1.50 m', 1, '24 40 3991 4001254'),
(2, 45.00, 'Caja de cartón reforzada', '0.60 x 0.60 x 0.80 m', 1, '24 40 3991 4001254'),
(3, 3400.00, 'Contenedor Refrigerado 20ft', '6.10 x 2.44 x 2.59 m', 2, '24 80 3991 8000412'),
(4, 500.00, 'Tambo metálico (Drum)', '0.60 x 0.60 x 0.90 m', 3, '24 20 3991 2004112'),
(5, 120.00, 'Caja de cartón con hielo seco', '1.00 x 1.00 x 1.00 m', 4, '24 50 3991 5001235'),
(6, 8900.00, 'Plataforma abierta (Flat Rack)', '12.20 x 2.44 m', 5, '24 40 3991 4005512'),
(7, 15000.00, 'Contenedor Estándar 40ft', '12.20 x 2.44 x 2.59 m', 6, '24 16 3991 1600122'),
(8, 2200.00, 'Isotanque de seguridad', '6.10 x 2.44 m', 7, '24 80 3991 8009941'),
(9, 15.00, 'Paquete Courier de alta seg', '0.30 x 0.30 x 0.30 m', 8, '24 65 3991 6500123'),
(10, 850.00, 'Palé plástico industrial', '1.20 x 1.20 x 1.60 m', 9, '24 40 3991 4008124');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedimento`
--

CREATE TABLE `pedimento` (
  `numero_pedimento` varchar(30) NOT NULL,
  `clave_pedimento` varchar(10) NOT NULL,
  `fecha_registro` date NOT NULL,
  `valor_total` decimal(12,2) NOT NULL,
  `semaforo` int(11) NOT NULL,
  `regimen_adu` int(11) NOT NULL,
  `permiso` varchar(30) NOT NULL,
  `ope_aduanera` int(11) NOT NULL,
  `tipo_exportacion` int(11) DEFAULT NULL,
  `tipo_importacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pedimento`
--

INSERT INTO `pedimento` (`numero_pedimento`, `clave_pedimento`, `fecha_registro`, `valor_total`, `semaforo`, `regimen_adu`, `permiso`, `ope_aduanera`, `tipo_exportacion`, `tipo_importacion`) VALUES
('24 16 3991 1600122', 'A1', '2024-03-03', 150000.00, 6, 1, 'PERM-SE-2024-002', 6, NULL, 1),
('24 20 3991 2004112', 'IN', '2024-03-02', 900000.00, 4, 4, 'PERM-SEDENA-102', 3, NULL, 2),
('24 24 3991 2400115', 'V1', '2024-03-05', 480.00, 10, 6, 'PERM-COFEPRIS-05', 10, 4, NULL),
('24 40 3991 4001254', 'A1', '2024-03-01', 350000.00, 2, 1, 'PERM-SE-2024-001', 1, NULL, 1),
('24 40 3991 4005512', 'A1', '2024-03-03', 20000.00, 5, 2, 'PERM-PROFEPA-19', 5, 1, NULL),
('24 40 3991 4008124', 'A1', '2024-03-05', 1250.00, 2, 1, 'PERM-SAT-IMMEX1', 9, NULL, 2),
('24 50 3991 5001235', 'A1', '2024-03-02', 50000.00, 3, 1, 'PERM-COFEPRIS-04', 4, NULL, 1),
('24 65 3991 6500123', 'A1', '2024-03-04', 9800.00, 7, 1, 'PERM-CRE-99211', 8, NULL, 1),
('24 80 3991 8000412', 'A1', '2024-03-02', 120000.00, 1, 2, 'PERM-SENASICA-882', 2, 1, NULL),
('24 80 3991 8009941', 'RT', '2024-03-04', 285000.00, 2, 5, 'PERM-SENASICA-89', 7, 2, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permiso`
--

CREATE TABLE `permiso` (
  `clave_numerica` varchar(30) NOT NULL,
  `tipo_permiso` varchar(50) NOT NULL,
  `vigencia` date NOT NULL,
  `descripcion` varchar(250) DEFAULT NULL,
  `cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `permiso`
--

INSERT INTO `permiso` (`clave_numerica`, `tipo_permiso`, `vigencia`, `descripcion`, `cliente`) VALUES
('PERM-COFEPRIS-04', 'Aviso Sanitario de Importación', '2026-01-15', 'Permiso para suplementos alimenticios y medicamentos.', 7),
('PERM-COFEPRIS-05', 'Registro Sanitario Dispositivos', '2025-11-22', 'Validación técnica de equipos médicos importados.', 15),
('PERM-CRE-99211', 'Permiso de Hidrocarburos', '2027-10-30', 'Autorización para importación de lubricantes especiales.', 13),
('PERM-PROFEPA-19', 'Certificado de CITES', '2024-08-20', 'Verificación de maderas y productos forestales permitidos.', 9),
('PERM-SAT-IMMEX1', 'Registro del Programa IMMEX', '2029-12-31', 'Folio autorizado del programa de maquila y exportación.', 5),
('PERM-SE-2024-001', 'Permiso de Importación Regulación SE', '2025-12-31', 'Permiso para importación de productos siderúrgicos.', 3),
('PERM-SE-2024-002', 'Cupo de Importación Automotriz', '2025-05-18', 'Cupo asignado para aranceles preferenciales de ensamble.', 3),
('PERM-SEDENA-102', 'Permiso de Materiales Regulados', '2024-12-31', 'Importación de químicos y componentes industriales controlados.', 5),
('PERM-SENASICA-882', 'Certificado Fitosanitario', '2024-06-30', 'Autorización sanitaria para productos perecederos.', 1),
('PERM-SENASICA-89', 'Certificado Zoosanitario', '2024-07-11', 'Permiso de cárnicos y productos de origen animal.', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `codigo` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `peso` decimal(10,2) NOT NULL,
  `valor_unitario` decimal(12,2) NOT NULL,
  `paquete` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codigo`, `nombre`, `descripcion`, `peso`, `valor_unitario`, `paquete`) VALUES
(1, 'Rollos de Mezclilla Denim', 'Tela de mezclilla en rollo de 50 metros.', 25.00, 350.00, 1),
(2, 'Resina ABS industrial', 'Granulado de plástico ABS para inyección.', 500.00, 18.50, 3),
(3, 'Bota de trabajo piel', 'Bota industrial con casquillo de acero talla 27.', 1.20, 890.00, 4),
(4, 'Torno CNC horizontal', 'Torno de control numérico para mecanizado de precisión.', 3200.00, 285000.00, 5),
(5, 'Microprocesador Intel i9', 'Procesador de décima generación 3.7 GHz.', 0.05, 9800.00, 6),
(6, 'Whisky Escocés 12 años', 'Botella 750 ml, Scotch Single Malt.', 1.20, 1250.00, 7),
(7, 'Lámina de acero galvanizada', 'Lámina de 1.22x2.44 m calibre 20.', 12.00, 480.00, 8),
(8, 'Aguacate Hass', 'Caja de aguacates frescos 4 kg.', 4.00, 185.00, 9),
(9, 'Automóvil Toyota Corolla 2024', 'Sedan 4 puertas, motor 1.8L, transmisión CVT.', 1350.00, 380000.00, 10),
(10, 'Amoxicilina 500mg caja 100 cápsulas', 'Antibiótico de amplio espectro para uso humano.', 0.35, 420.00, 3),
(11, 'Atún en lata 140g', 'Atún en agua, envasado herméticamente para consumo humano.', 0.14, 28.50, 2),
(12, 'Poliuretano Expandido Líquido', 'Componente químico en tambo para aislamiento térmico.', 220.00, 4500.00, 4),
(13, 'Válvula de Control Hidráulico', 'Refacción industrial para tuberías de alta presión.', 8.50, 2300.00, 10),
(14, 'Memoria RAM DDR5 16GB', 'Módulo de memoria RAM de alta velocidad para servidores.', 0.03, 1650.00, 9),
(15, 'Vino Tinto Cabernet Sauvignon', 'Botella de vino de mesa 750 ml origen Valle de Guadalupe.', 1.30, 450.00, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `regimen_aduanero`
--

CREATE TABLE `regimen_aduanero` (
  `num_regimen` int(11) NOT NULL,
  `clave_oficial` varchar(10) NOT NULL,
  `descripcion` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `regimen_aduanero`
--

INSERT INTO `regimen_aduanero` (`num_regimen`, `clave_oficial`, `descripcion`) VALUES
(1, 'IMD', 'Definitivo de importación'),
(2, 'EXD', 'Definitivo de exportación'),
(3, 'ITM', 'Temporal de importación para retornar al extranjero en el mismo estado'),
(4, 'ITE', 'Temporal de importación para elaboración, transformación o reparación'),
(5, 'ETM', 'Temporal de exportación para retornar al país en el mismo estado'),
(6, 'ETE', 'Temporal de exportación para elaboración, transformación o reparación'),
(7, 'DFI', 'Depósito fiscal'),
(8, 'RFE', 'Recinto fiscalizado estratégico'),
(9, 'TRA', 'Tránsito de mercancías interno'),
(10, 'TRM', 'Tránsito de mercancías internacional');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sancion`
--

CREATE TABLE `sancion` (
  `num_sancion` int(11) NOT NULL,
  `monto_multa` decimal(12,2) NOT NULL,
  `fundamento_legal` varchar(250) NOT NULL,
  `incidencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sancion`
--

INSERT INTO `sancion` (`num_sancion`, `monto_multa`, `fundamento_legal`, `incidencia`) VALUES
(1, 15400.00, 'Artículo 176 y 178 de la Ley Aduanera (Datos inexactos de mercancía).', 1),
(2, 45000.00, 'Artículo 176 Fracción II (Falta de permiso de autoridades sanitarias).', 2),
(3, 89000.00, 'Artículo 178 Fracción I (Omisión total o parcial de impuestos de comercio exterior).', 4),
(4, 12300.00, 'Artículo 182 de la Ley Aduanera (Violación a las normas de etiquetado comercial NOM).', 5),
(5, 115000.00, 'Artículo 176 Fracción III (Mercancía de contrabando no declarada en contenedor).', 7),
(6, 32000.00, 'Artículo 178 Fracción IV (Subvaluación de mercancías declaradas en factura).', 8);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `segunda_inspeccion`
--

CREATE TABLE `segunda_inspeccion` (
  `ID_revision` int(11) NOT NULL,
  `inspeccion_FK` int(11) NOT NULL,
  `fecha_inspeccion` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `resultado` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `segunda_inspeccion`
--

INSERT INTO `segunda_inspeccion` (`ID_revision`, `inspeccion_FK`, `fecha_inspeccion`, `hora_inicio`, `resultado`) VALUES
(1, 2, '2024-03-01', '15:30:00', 'Sanción aplicada, mercancía liberada tras pago.'),
(2, 4, '2024-03-02', '18:45:00', 'Mercancía decomisada temporalmente por falta de permisos.'),
(3, 8, '2024-03-04', '19:10:00', 'Aclaración documental exitosa, liberado sin multa.'),
(4, 10, '2024-03-05', '22:30:00', 'Multa por clasificación arancelaria incorrecta detectada.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `segunda_inspeccion_inspector`
--

CREATE TABLE `segunda_inspeccion_inspector` (
  `segunda_ins` int(11) NOT NULL,
  `inspector_adu` varchar(20) NOT NULL,
  `observaciones` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `segunda_inspeccion_inspector`
--

INSERT INTO `segunda_inspeccion_inspector` (`segunda_ins`, `inspector_adu`, `observaciones`) VALUES
(1, 'INS003', 'Cotejo final de mercancías contra pago de multa exitoso.'),
(2, 'INS005', 'Aseguramiento precautorio de cajas en bodega fiscal.'),
(3, 'INS001', 'Validación de documentos corregidos por la agencia.'),
(4, 'INS009', 'Supervisión de re-clasificación arancelaria.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `semaforo_fiscal`
--

CREATE TABLE `semaforo_fiscal` (
  `ID` int(11) NOT NULL,
  `hora` time NOT NULL,
  `resultado` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `semaforo_fiscal`
--

INSERT INTO `semaforo_fiscal` (`ID`, `hora`, `resultado`) VALUES
(1, '08:15:00', 'Verde - Desaduanamiento libre'),
(2, '09:30:00', 'Rojo - Reconocimiento aduanero'),
(3, '11:00:00', 'Verde - Desaduanamiento libre'),
(4, '13:45:00', 'Rojo - Reconocimiento aduanero'),
(5, '15:20:00', 'Verde - Desaduanamiento libre'),
(6, '16:10:00', 'Verde - Desaduanamiento libre'),
(7, '17:05:00', 'Rojo - Reconocimiento aduanero'),
(8, '18:30:00', 'Verde - Desaduanamiento libre'),
(9, '19:40:00', 'Verde - Desaduanamiento libre'),
(10, '21:00:00', 'Rojo - Reconocimiento aduanero');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefono`
--

CREATE TABLE `telefono` (
  `numero` int(11) NOT NULL,
  `numTelefono` varchar(20) NOT NULL,
  `cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `telefono`
--

INSERT INTO `telefono` (`numero`, `numTelefono`, `cliente`) VALUES
(1, '6641234567', 1),
(2, '6647654321', 2),
(3, '5559876543', 3),
(4, '8113456789', 5),
(5, '3334561122', 7),
(6, '2229873344', 9),
(7, '7441235566', 4),
(8, '9991112233', 6),
(9, '6564567788', 8),
(10, '4421239900', 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_arancel`
--

CREATE TABLE `tipo_arancel` (
  `numero` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `fecha_actualizacion` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_arancel`
--

INSERT INTO `tipo_arancel` (`numero`, `nombre`, `descripcion`, `fecha_actualizacion`) VALUES
(1, 'Ad-valorem', 'Porcentaje aplicado sobre el valor en aduana de la mercancía.', '2024-01-01'),
(2, 'Específico', 'Monto fijo de dinero por unidad de medida física.', '2024-01-01'),
(3, 'Mixto', 'Combinación de un arancel Ad-valorem y uno específico.', '2024-01-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_exportaciones`
--

CREATE TABLE `tipo_exportaciones` (
  `tipo_exportacion` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_exportaciones`
--

INSERT INTO `tipo_exportaciones` (`tipo_exportacion`, `nombre`, `descripcion`) VALUES
(1, 'Definitiva A1', 'Exportación de mercancías para permanecer en el extranjero por tiempo ilimitado.'),
(2, 'Temporal de Remanentes', 'Salida de materiales para retornar en el mismo estado.'),
(3, 'Temporal para Transformación', 'Salida para maquila o ensamble industrial en el extranjero.'),
(4, 'Virtuales de Exportación', 'Transferencias de mercancías entre empresas IMMEX de manera electrónica.'),
(5, 'Tránsito Internacional', 'Mercancías extranjeras que cruzan por el país con destino al exterior.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_importaciones`
--

CREATE TABLE `tipo_importaciones` (
  `tipo_importacion` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_importaciones`
--

INSERT INTO `tipo_importaciones` (`tipo_importacion`, `nombre`, `descripcion`) VALUES
(1, 'Definitiva A1', 'Importación de mercancías para permanecer en el país por tiempo ilimitado.'),
(2, 'Temporal IMMEX', 'Importación temporal de materias primas para procesos de manufactura maquila.'),
(3, 'Virtuales de Importación', 'Retorno virtual de mercancías procesadas por maquiladoras.'),
(4, 'Depósito Fiscal', 'Almacenamiento de mercancías en almacenes generales de depósito autorizados.'),
(5, 'Recinto Fiscalizado', 'Ingreso a zonas estratégicas para manejo, almacenaje y custodia.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_permiso`
--

CREATE TABLE `tipo_permiso` (
  `id_tipo_permiso` int(11) NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `permiso` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_permiso`
--

INSERT INTO `tipo_permiso` (`id_tipo_permiso`, `tipo`, `descripcion`, `permiso`) VALUES
(1, 'Siderúrgico', 'Control de importación de aceros y derivados.', 'PERM-SE-2024-001'),
(2, 'Agrícola', 'Inspección de sanidad vegetal y control de plagas.', 'PERM-SENASICA-882'),
(3, 'Químico Controlado', 'Sustancias de uso dual reguladas por fuerzas armadas.', 'PERM-SEDENA-102'),
(4, 'Salud Pública', 'Validación de inocuidad para consumo directo.', 'PERM-COFEPRIS-04'),
(5, 'Ecológico', 'Protección de flora y fauna silvestre maderas.', 'PERM-PROFEPA-19'),
(6, 'Cupo Preferencial', 'Beneficio arancelario por tratados comerciales.', 'PERM-SE-2024-002'),
(7, 'Pecuario', 'Inspección de sanidad animal e importación cárnica.', 'PERM-SENASICA-89'),
(8, 'Energético', 'Regulación de combustibles y aceites pesados.', 'PERM-CRE-99211'),
(9, 'Maquiladora', 'Estatus temporal para transformación industrial.', 'PERM-SAT-IMMEX1'),
(10, 'Médico', 'Dispositivos de hospitalización y uso quirúrgico.', 'PERM-COFEPRIS-05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `ID_usuario` int(11) NOT NULL,
  `nombre_usuario` varchar(50) NOT NULL,
  `nombre_pila` varchar(40) NOT NULL,
  `primer_apell` varchar(40) NOT NULL,
  `seg_apell` varchar(40) DEFAULT NULL,
  `fecha_alta` date NOT NULL,
  `correo` varchar(80) NOT NULL,
  `contrasena` varchar(100) NOT NULL,
  `bitacora` int(11) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `is_superuser` tinyint(1) DEFAULT 0,
  `is_staff` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`ID_usuario`, `nombre_usuario`, `nombre_pila`, `primer_apell`, `seg_apell`, `fecha_alta`, `correo`, `contrasena`, `bitacora`, `last_login`, `is_superuser`, `is_staff`, `is_active`) VALUES
(1, 'admin_tij', 'Francisco', 'Javier', 'Solís', '2023-01-15', 'fjavier@aduana.gob.mx', 'pbkdf2_sha256$1200000$mUSxoV9UUGaOCqZRfA302O$WhFFBVHEABS+x7Hv9+Dntm70EieEuh46uLFeWNgrPtg=', 1, '2026-06-19 02:19:10', 0, 0, 1),
(2, 'log_user1', 'Elena', 'Ríos', 'Mendoza', '2023-06-20', 'erios@logistica.com', 'pbkdf2_sha256$1200000$9LgTItqvGFBNE8AVtDJ07l$AtXQjfNOU8d20NEWOLUkUdKj8yRyBmHTn0JQYmo/wIs=', 4, NULL, 0, 0, 1),
(3, 'capturista_1', 'Juan', 'Paredes', 'Vega', '2023-08-11', 'jparedes@agencia.com', 'pbkdf2_sha256$1200000$P3pHbnD3UZNzPDjNb56xWd$dGxMBqD+XUXgFlLws+DahVZZET3TwTsf0qLaXLs7Nes=', 2, NULL, 0, 0, 1),
(4, 'supervisor_nz', 'Marcos', 'Patiño', 'Luna', '2022-11-02', 'mpatino@aduana.gob.mx', 'pbkdf2_sha256$1200000$xgBq8ri9lpP4fOiYcJn6s8$e0DzzkDImsJMCksvBad0LRuXhbipE/VLJpIvqfBwPc0=', 3, NULL, 0, 0, 1),
(5, 'auditor_ext', 'Diana', 'Kuri', 'Alba', '2024-01-10', 'dkuri@auditoria.com', 'hash_secure_password_5', 6, NULL, 0, 0, 1),
(6, 'jefe_aduana', 'Rodolfo', 'Casas', 'Tello', '2020-05-18', 'rcasas@aduana.gob.mx', 'pbkdf2_sha256$1200000$YeCPix6OgmVK4en4KspUjQ$vf7AMVrRa+Ik8qcWieiEWq/0WhlZKgR02zdr318AYmE=', 8, NULL, 0, 0, 1),
(7, 'v_operador', 'Valeria', 'Núñez', 'Guerra', '2023-09-01', 'vnunez@forwarder.com', 'hash_secure_password_7', 7, NULL, 0, 0, 1),
(8, 'soporte_siga', 'Ismael', 'Borges', 'Ochoa', '2021-03-24', 'siga_support@siga.com', 'hash_secure_password_8', 9, NULL, 0, 0, 1),
(9, 'consultor_fisc', 'Paola', 'Jiménez', 'Pinto', '2024-02-15', 'pjimenez@consultores.com', 'hash_secure_password_9', 5, NULL, 0, 0, 1),
(10, 'api_user', 'Sistema', 'Automatizado', 'Integración', '2022-01-01', 'api@siga.com', 'hash_secure_password_10', 10, NULL, 0, 0, 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `aduana`
--
ALTER TABLE `aduana`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `arancel`
--
ALTER TABLE `arancel`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indices de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indices de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `categorias_productos_rel`
--
ALTER TABLE `categorias_productos_rel`
  ADD PRIMARY KEY (`categorias`,`productos`);

--
-- Indices de la tabla `categoria_productos`
--
ALTER TABLE `categoria_productos`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`numero`),
  ADD UNIQUE KEY `uq_cliente_rfc` (`RFC`);

--
-- Indices de la tabla `correo_electronico`
--
ALTER TABLE `correo_electronico`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_usuario_ID_usuario` (`user_id`);

--
-- Indices de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indices de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indices de la tabla `estado_pago`
--
ALTER TABLE `estado_pago`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`codigo`),
  ADD UNIQUE KEY `uq_factura_folio` (`folio_fiscal`);

--
-- Indices de la tabla `incidencia`
--
ALTER TABLE `incidencia`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `inspeccion`
--
ALTER TABLE `inspeccion`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `inspeccion_inspector`
--
ALTER TABLE `inspeccion_inspector`
  ADD PRIMARY KEY (`inspeccion`,`inspector_adu`);

--
-- Indices de la tabla `inspector_aduanero`
--
ALTER TABLE `inspector_aduanero`
  ADD PRIMARY KEY (`matricula`),
  ADD UNIQUE KEY `uq_inspector_gafete` (`no_gafete`);

--
-- Indices de la tabla `operacion_aduanera`
--
ALTER TABLE `operacion_aduanera`
  ADD PRIMARY KEY (`ID_operacion`);

--
-- Indices de la tabla `pago`
--
ALTER TABLE `pago`
  ADD PRIMARY KEY (`no_transaccion`);

--
-- Indices de la tabla `paquete`
--
ALTER TABLE `paquete`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `pedimento`
--
ALTER TABLE `pedimento`
  ADD PRIMARY KEY (`numero_pedimento`);

--
-- Indices de la tabla `permiso`
--
ALTER TABLE `permiso`
  ADD PRIMARY KEY (`clave_numerica`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`codigo`);

--
-- Indices de la tabla `regimen_aduanero`
--
ALTER TABLE `regimen_aduanero`
  ADD PRIMARY KEY (`num_regimen`),
  ADD UNIQUE KEY `uq_regimen_clave` (`clave_oficial`);

--
-- Indices de la tabla `sancion`
--
ALTER TABLE `sancion`
  ADD PRIMARY KEY (`num_sancion`);

--
-- Indices de la tabla `segunda_inspeccion`
--
ALTER TABLE `segunda_inspeccion`
  ADD PRIMARY KEY (`ID_revision`,`inspeccion_FK`);

--
-- Indices de la tabla `segunda_inspeccion_inspector`
--
ALTER TABLE `segunda_inspeccion_inspector`
  ADD PRIMARY KEY (`segunda_ins`,`inspector_adu`);

--
-- Indices de la tabla `semaforo_fiscal`
--
ALTER TABLE `semaforo_fiscal`
  ADD PRIMARY KEY (`ID`);

--
-- Indices de la tabla `telefono`
--
ALTER TABLE `telefono`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `tipo_arancel`
--
ALTER TABLE `tipo_arancel`
  ADD PRIMARY KEY (`numero`);

--
-- Indices de la tabla `tipo_exportaciones`
--
ALTER TABLE `tipo_exportaciones`
  ADD PRIMARY KEY (`tipo_exportacion`);

--
-- Indices de la tabla `tipo_importaciones`
--
ALTER TABLE `tipo_importaciones`
  ADD PRIMARY KEY (`tipo_importacion`);

--
-- Indices de la tabla `tipo_permiso`
--
ALTER TABLE `tipo_permiso`
  ADD PRIMARY KEY (`id_tipo_permiso`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`ID_usuario`),
  ADD UNIQUE KEY `uq_usuario_nombre` (`nombre_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `aduana`
--
ALTER TABLE `aduana`
  MODIFY `codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=811;

--
-- AUTO_INCREMENT de la tabla `arancel`
--
ALTER TABLE `arancel`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT de la tabla `bitacora`
--
ALTER TABLE `bitacora`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `categoria_productos`
--
ALTER TABLE `categoria_productos`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `correo_electronico`
--
ALTER TABLE `correo_electronico`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `estado_pago`
--
ALTER TABLE `estado_pago`
  MODIFY `codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `incidencia`
--
ALTER TABLE `incidencia`
  MODIFY `codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `inspeccion`
--
ALTER TABLE `inspeccion`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `operacion_aduanera`
--
ALTER TABLE `operacion_aduanera`
  MODIFY `ID_operacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `paquete`
--
ALTER TABLE `paquete`
  MODIFY `codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `regimen_aduanero`
--
ALTER TABLE `regimen_aduanero`
  MODIFY `num_regimen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `sancion`
--
ALTER TABLE `sancion`
  MODIFY `num_sancion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `semaforo_fiscal`
--
ALTER TABLE `semaforo_fiscal`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `telefono`
--
ALTER TABLE `telefono`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `tipo_arancel`
--
ALTER TABLE `tipo_arancel`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipo_exportaciones`
--
ALTER TABLE `tipo_exportaciones`
  MODIFY `tipo_exportacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tipo_importaciones`
--
ALTER TABLE `tipo_importaciones`
  MODIFY `tipo_importacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `tipo_permiso`
--
ALTER TABLE `tipo_permiso`
  MODIFY `id_tipo_permiso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `ID_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Filtros para la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Filtros para la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_usuario_ID_usuario` FOREIGN KEY (`user_id`) REFERENCES `usuario` (`ID_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
