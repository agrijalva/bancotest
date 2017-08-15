-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 15-08-2017 a las 11:59:41
-- Versión del servidor: 10.1.21-MariaDB
-- Versión de PHP: 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bancotest`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE PROCEDURE `SP_BENEFICIARIOS` (`idCliente` INT)  BEGIN
	SELECT BEN.*, `rel_tipo` as Relacion  FROM `beneficiario` BEN
	INNER JOIN `tiporelacion` REL ON BEN.idRelacion = REL.idRelacion
	WHERE `idCliente` = idCliente;
END$$

CREATE PROCEDURE `SP_BUSCAR_CUENTA` (`tipo` INT, `numero` VARCHAR(16) CHARSET utf8)  BEGIN

	IF(tipo = 1)THEN -- Por Numero de cuenta
		SELECT *
		FROM cuenta CUE
		INNER JOIN cliente CLI ON CUE.idCliente = CLI.idCliente
		WHERE idCuenta = numero;
    ELSE -- Por Numero de tarjeta
		SELECT *
		FROM tarjeta TAR
		INNER JOIN cuenta CUE ON CUE.idCuenta = TAR.idCuenta
		INNER JOIN cliente CLI ON CUE.idCliente = CLI.idCliente
		WHERE TAR.noTarjeta = numero;
    END IF;
END$$

CREATE PROCEDURE `SP_CATALOGOS` (`catalogo` VARCHAR(15) CHARSET utf8)  BEGIN
	SET @tabla = CONCAT('tipo', catalogo);
    SET @Query = CONCAT('SELECT * FROM ', @tabla);
        
	PREPARE result FROM @Query;
	EXECUTE result;
	DEALLOCATE PREPARE result;
END$$

CREATE PROCEDURE `SP_DEPOSITOS` (`_mov_monto` FLOAT, `_idEjecutivo` INT, `_idCuenta` INT, `_idTipoMovimiento` INT, `_idTipoCuenta` INT)  BEGIN
	IF( _idTipoMovimiento = 1 ) THEN
		SET _mov_monto = (SELECT tcu_monto_apertura FROM tipocuenta WHERE idTipoCuenta = _idTipoCuenta);
    END IF;
    
	INSERT INTO movimientos(`mov_monto`, `idEjecutivo`, `mov_relacion`, `mov_cargo`, `idCuenta`, `idTipoMovimiento`) VALUES( _mov_monto, _idEjecutivo, 0, 1, _idCuenta, _idTipoMovimiento );
    
    SELECT 1 as success, 'Se inserto de manera correcta' as msg;
END$$

CREATE PROCEDURE `SP_LOGIN` (`usuario` VARCHAR(255) CHARSET utf8, `pass` VARCHAR(255) CHARSET utf8, `tipousuario` INT)  BEGIN
	IF(tipousuario = 4)THEN -- Cliente
		SELECT * FROM usuario USU
        INNER JOIN cliente CLI ON cli_email = usu_usuario
		WHERE usu_usuario = usuario
			  AND usu_password = pass
			  AND idTipoUsuario = tipousuario;
	ELSE
		SELECT * FROM usuario USU  -- Ejecutivo
        INNER JOIN ejecutivo EJE ON eje_email = usu_usuario
		WHERE usu_usuario = usuario 
			  AND usu_password = pass
			  AND idTipoUsuario = tipousuario;
    END IF;
END$$

CREATE PROCEDURE `SP_MOVIMIENTOS` (`noTarjeta` VARCHAR(16) CHARSET utf8, `fechaInicio` VARCHAR(10) CHARSET utf8, `fechaFin` VARCHAR(10) CHARSET utf8)  BEGIN
	SELECT * FROM movimientos MOV
	INNER JOIN cuenta CUE ON CUE.idCuenta = MOV.idCuenta
	INNER JOIN tarjeta TAR ON TAR.idCuenta = MOV.idCuenta
	WHERE noTarjeta = noTarjeta
		  AND idEstatusCuenta = 1
		  AND (MOV.timestamp BETWEEN fechaInicio AND fechaFin);
END$$

CREATE PROCEDURE `SP_NUEVA_CUENTA` (`_idEjecutivo` INT, `_idCliente` INT, `_idEstatusCuenta` INT, `_idTipoCuenta` INT)  BEGIN
	INSERT INTO cuenta(idEjecutivo, idCliente, idEstatusCuenta, idTipoCuenta) VALUE(_idEjecutivo, _idCliente, _idEstatusCuenta, _idTipoCuenta);
    
    SELECT LAST_INSERT_ID() as lastId;
END$$

CREATE PROCEDURE `SP_OBTENER_CLIENTE` (`_noCliente` VARCHAR(15) CHARSET utf8)  BEGIN
	SELECT * FROM cliente CLI WHERE noCliente = _noCliente;
END$$

CREATE PROCEDURE `SP_OBTENER_CLIENTES` (`_idEjecutivo` INT)  BEGIN
	SELECT CLI.*, ECL.`esc_estatus` as Estatus FROM `cliente` CLI
	INNER JOIN `estatuscliente` ECL ON CLI.`idEstatusCliente` = ECL.`idEstatusCliente`
	WHERE `idEjecutivo` = _idEjecutivo;
END$$

CREATE PROCEDURE `SP_OBTENER_CUENTAS` (`_idCliente` INT)  BEGIN
	SELECT *
	FROM cuenta CUE
	INNER JOIN tarjeta TAR ON CUE.idCuenta = TAR.idCuenta
    WHERE CUE.idCliente  = _idCliente;
END$$

CREATE PROCEDURE `SP_REGISTRAR_CLIENTE` (`_noCliente` VARCHAR(100) CHARSET utf8, `_cli_nombre` VARCHAR(100) CHARSET utf8, `_cli_apellidos` VARCHAR(100) CHARSET utf8, `_cli_rfc` VARCHAR(12) CHARSET utf8, `_cli_email` VARCHAR(150) CHARSET utf8, `_cli_telefono` VARCHAR(15) CHARSET utf8, `_cli_celular` VARCHAR(15) CHARSET utf8, `_idEjecutivo` INT)  BEGIN
	DECLARE _key VARCHAR(60);
    DECLARE lastId INT;
    SET _key  = MD5(NOW());
    
    INSERT INTO cliente(`noCliente`,`cli_nombre`, `cli_apellidos`, `cli_rfc`, `cli_email`, `cli_telefono`, `cli_celular`, `idEstatusCliente`, `idEjecutivo`, `key`) VALUES(_noCliente, _cli_nombre, _cli_apellidos, _cli_rfc, _cli_email, _cli_telefono, _cli_celular, 1, _idEjecutivo, _key);
    SET lastId = LAST_INSERT_ID();
    
    INSERT INTO usuario(usu_usuario, usu_password, idTipoUsuario) VALUES (_cli_email, '12345', 4);
    SELECT 1 as success, 'Se inserto de manera correcta' as msg, lastId as lastId;
END$$

CREATE PROCEDURE `SP_REGISTRA_BENEFICIARIO` (`ben_nombre` VARCHAR(150) CHARSET utf8, `ben_telefono` VARCHAR(15) CHARSET utf8, `ben_email` VARCHAR(100) CHARSET utf8, `idCliente` INT, `idRelacion` INT)  BEGIN
	INSERT INTO cliente(`ben_nombre`, `ben_telefono`, `ben_email`, `idCliente`, `idRelacion`) VALUES( ben_nombre, ben_telefono, ben_email, idCliente, idRelacion );
    SELECT 1 as success, 'Se inserto de manera correcta' as msg, LAST_INSERT_ID() as lastId;
END$$

CREATE PROCEDURE `SP_SALDO_TARJETAS` (`_idCuenta` INT)  BEGIN
	SET @Cargo = (SELECT SUM(`mov_monto`) as Cargo FROM `movimientos` WHERE `idCuenta` = _idCuenta AND `mov_cargo` = 1);
	SET @Abono = (SELECT SUM(`mov_monto`) as Abono FROM `movimientos` WHERE `idCuenta` = _idCuenta AND `mov_cargo` = 0);
    
    IF( @Abono IS NULL ) THEN
		SET @Saldo = @Cargo - 0;
	ELSEIF( @Cargo IS NULL ) THEN
		SET @Saldo = 0 - @Abono;
	ELSE
		SET @Saldo = @Cargo - @Abono;
	END IF;
	
	SELECT @Saldo AS Saldo;
END$$

CREATE PROCEDURE `SP_TRAMITAR_TARJETA_SP` (`_noTarjeta` VARCHAR(16) CHARSET utf8, `_idEjecutivo` INT, `_idCuenta` INT, `_idTipoTarjeta` INT)  BEGIN
    INSERT INTO tarjeta(`noTarjeta`, `idEjecutivo`, `idCuenta`, `idTipoTarjeta`) VALUES( _noTarjeta, _idEjecutivo, _idCuenta, _idTipoTarjeta );
    SELECT 1 as success, 'Se inserto de manera correcta' as msg, LAST_INSERT_ID() as lastId;
END$$

CREATE PROCEDURE `SP_TRANSFERENCIA` (`mov_monto` VARCHAR(16) CHARSET utf8, `idEjecutivo` INT, `idCuentaOrigen` INT, `idCuentaDestino` INT)  BEGIN
	DECLARE lastID INT;
    
	INSERT INTO tarjeta(`mov_monto`, `idEjecutivo`, `mov_relacion`, `mov_cargo`, `idCuenta`, `idTipoMovimiento`) 
    VALUES( mov_monto, idEjecutivo, 0, 1, idCuentaOrigen, 3 );
    
    SET lastID = LAST_INSERT_ID();
    
    INSERT INTO tarjeta(`mov_monto`, `idEjecutivo`, `mov_relacion`, `mov_cargo`, `idCuenta`, `idTipoMovimiento`) 
    VALUES( mov_monto, idEjecutivo, lastID, 0, idCuentaDestino, 3 );
    
    SELECT 1 as success, 'Se inserto de manera correcta' as msg, lastID as lastId;
END$$

CREATE PROCEDURE `SP_VERIFICAR_EMAIL_CLIENTE` (`email` VARCHAR(150) CHARSET utf8)  BEGIN
	SELECT idCliente FROM cliente
	WHERE cli_email = email;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `beneficiario`
--

CREATE TABLE `beneficiario` (
  `idBeneficiario` int(11) NOT NULL,
  `ben_nombre` varchar(150) COLLATE latin1_spanish_ci NOT NULL,
  `ben_telefono` varchar(15) COLLATE latin1_spanish_ci NOT NULL,
  `ben_email` varchar(100) COLLATE latin1_spanish_ci NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idCliente` int(11) NOT NULL,
  `idRelacion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `beneficiario`
--

INSERT INTO `beneficiario` (`idBeneficiario`, `ben_nombre`, `ben_telefono`, `ben_email`, `timestamp`, `idCliente`, `idRelacion`) VALUES
(1, 'ARANZA DE JESUS', '7713671834', 'alex9.abril@gmail.com', '2017-08-13 14:22:41', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idCliente` int(11) NOT NULL,
  `noCliente` varchar(45) COLLATE latin1_spanish_ci NOT NULL,
  `cli_nombre` varchar(200) COLLATE latin1_spanish_ci NOT NULL,
  `cli_apellidos` varchar(200) COLLATE latin1_spanish_ci NOT NULL,
  `cli_rfc` varchar(18) COLLATE latin1_spanish_ci DEFAULT NULL,
  `cli_email` varchar(100) COLLATE latin1_spanish_ci NOT NULL,
  `cli_telefono` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `cli_celular` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idEstatusCliente` int(11) NOT NULL,
  `idEjecutivo` int(11) NOT NULL,
  `key` varchar(45) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idCliente`, `noCliente`, `cli_nombre`, `cli_apellidos`, `cli_rfc`, `cli_email`, `cli_telefono`, `cli_celular`, `timestamp`, `idEstatusCliente`, `idEjecutivo`, `key`) VALUES
(1, '1502758812860', 'JOSE JAVIER', 'GRIJALVA ANTONIO', 'GRIA123902487', 'alex.9abril@gmail.com', '7716376543', '7713679938', '2017-08-13 14:17:58', 1, 1, 'da6810a28c95d49713a03c9990c08ddc'),
(18, '1502779173324', 'JOSEFINA', 'ANTONIO CONTRERAS', 'JOSE57467809', 'josefina@gmail.com', '45698709', '78986789', '2017-08-15 01:39:33', 1, 1, '874084abde55df4ecd05bb8187d0205a'),
(19, '1502779434571', 'EDER ROMAN', 'SANCHEZ FERRER', 'EDR97678897', 'eder@gmail.com', '546789098098', '987655687', '2017-08-15 01:43:54', 1, 1, 'cd8f9ae042fd2355347b8fc74648971f'),
(20, '1502784633368', 'HECTOR', 'SANTOS V.', 'HEC877687', 'hector@gmail.com', '5658970098', '098766567', '2017-08-15 03:10:33', 1, 1, '6980bfc1e7c2a720a02ff9d5fdac5d1c');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuenta`
--

CREATE TABLE `cuenta` (
  `idCuenta` int(11) NOT NULL,
  `cue_fecha_apertura` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idEjecutivo` varchar(45) COLLATE latin1_spanish_ci NOT NULL,
  `idCliente` int(11) NOT NULL,
  `idEstatusCuenta` int(11) NOT NULL,
  `idTipoCuenta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `cuenta`
--

INSERT INTO `cuenta` (`idCuenta`, `cue_fecha_apertura`, `idEjecutivo`, `idCliente`, `idEstatusCuenta`, `idTipoCuenta`) VALUES
(1, '2017-08-13 14:20:00', '1', 1, 1, 1),
(18, '2017-08-15 01:39:33', '1', 18, 1, 2),
(19, '2017-08-15 01:43:54', '1', 19, 1, 1),
(20, '2017-08-15 03:00:44', '1', 19, 1, 2),
(21, '2017-08-15 03:08:56', '1', 19, 1, 2),
(22, '2017-08-15 03:09:08', '1', 19, 1, 1),
(23, '2017-08-15 03:10:33', '1', 20, 1, 2),
(24, '2017-08-15 03:10:47', '1', 20, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ejecutivo`
--

CREATE TABLE `ejecutivo` (
  `idEjecutivo` int(11) NOT NULL,
  `eje_nombre` varchar(150) COLLATE latin1_spanish_ci NOT NULL,
  `eje_telefono` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `eje_celular` varchar(45) COLLATE latin1_spanish_ci DEFAULT NULL,
  `eje_email` varchar(150) COLLATE latin1_spanish_ci NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `key` varchar(100) COLLATE latin1_spanish_ci NOT NULL,
  `idTipoEjecutivo` int(11) NOT NULL,
  `idEstatusEjecutivo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `ejecutivo`
--

INSERT INTO `ejecutivo` (`idEjecutivo`, `eje_nombre`, `eje_telefono`, `eje_celular`, `eje_email`, `timestamp`, `key`, `idTipoEjecutivo`, `idEstatusEjecutivo`) VALUES
(1, 'NORMA LILIA SANCHEZ FERRER', '7742536548', '7716734526', 'alex_9abril@hotmail.com', '2017-08-13 14:16:10', '6dbf7b4de58c46f6b61298047d9de36f', 2, 1),
(2, 'ALEJANDRO GRIJALVA ANTONIO', '7712364537', '5548671990', 'alex9abril@gmail.com', '2017-08-13 14:16:10', '6dbf7b4de58c46f6b61298047d9de36f', 3, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estatuscliente`
--

CREATE TABLE `estatuscliente` (
  `idEstatusCliente` int(11) NOT NULL,
  `esc_estatus` varchar(45) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `estatuscliente`
--

INSERT INTO `estatuscliente` (`idEstatusCliente`, `esc_estatus`) VALUES
(1, 'Activo'),
(2, 'Eliminado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estatuscuenta`
--

CREATE TABLE `estatuscuenta` (
  `idEstatusCuenta` int(11) NOT NULL,
  `esc_estatus` varchar(45) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `estatuscuenta`
--

INSERT INTO `estatuscuenta` (`idEstatusCuenta`, `esc_estatus`) VALUES
(1, 'Activo'),
(2, 'Cancelada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estatusejecutivo`
--

CREATE TABLE `estatusejecutivo` (
  `idEstatusEjecutivo` int(11) NOT NULL,
  `ese_estatus` varchar(50) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `estatusejecutivo`
--

INSERT INTO `estatusejecutivo` (`idEstatusEjecutivo`, `ese_estatus`) VALUES
(1, 'Activo'),
(2, 'Eliminado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos`
--

CREATE TABLE `movimientos` (
  `idMovimiento` int(11) NOT NULL,
  `mov_monto` float NOT NULL,
  `idEjecutivo` int(11) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mov_relacion` int(11) NOT NULL,
  `mov_cargo` int(11) NOT NULL,
  `idCuenta` int(11) NOT NULL,
  `idTipoMovimiento` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `movimientos`
--

INSERT INTO `movimientos` (`idMovimiento`, `mov_monto`, `idEjecutivo`, `timestamp`, `mov_relacion`, `mov_cargo`, `idCuenta`, `idTipoMovimiento`) VALUES
(1, 0, 1, '2017-08-13 14:21:20', 0, 1, 1, 1),
(2, 1000, 2, '2017-08-13 22:23:55', 0, 1, 1, 2),
(3, 200, 2, '2017-08-13 22:23:55', 0, 1, 1, 2),
(4, 700, 2, '2017-08-13 22:25:42', 0, 0, 1, 2),
(8, 1500, 1, '2017-08-15 01:39:33', 0, 1, 18, 1),
(9, 0, 1, '2017-08-15 01:43:54', 0, 1, 19, 1),
(10, 1500, 1, '2017-08-15 03:00:44', 0, 1, 20, 1),
(11, 1500, 1, '2017-08-15 03:08:57', 0, 1, 21, 1),
(12, 0, 1, '2017-08-15 03:09:08', 0, 1, 22, 1),
(13, 1500, 1, '2017-08-15 03:10:33', 0, 1, 23, 1),
(14, 0, 1, '2017-08-15 03:10:47', 0, 1, 24, 1),
(15, 57365, 2, '2017-08-15 04:31:21', 0, 1, 24, 2),
(16, 100, 2, '2017-08-15 04:32:24', 0, 1, 24, 2),
(17, 110, 2, '2017-08-15 04:34:01', 0, 1, 22, 2),
(18, 550, 2, '2017-08-15 04:34:19', 0, 1, 22, 2),
(19, 500000, 2, '2017-08-15 04:35:46', 0, 1, 18, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tarjeta`
--

CREATE TABLE `tarjeta` (
  `idTarjeta` int(11) NOT NULL,
  `noTarjeta` varchar(16) COLLATE latin1_spanish_ci NOT NULL,
  `idEjecutivo` int(11) NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idCuenta` int(11) NOT NULL,
  `idTipoTarjeta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `tarjeta`
--

INSERT INTO `tarjeta` (`idTarjeta`, `noTarjeta`, `idEjecutivo`, `timestamp`, `idCuenta`, `idTipoTarjeta`) VALUES
(1, '2911502644628969', 1, '2017-08-13 14:25:04', 1, 1),
(18, '2911502779173324', 1, '2017-08-15 01:39:33', 18, 1),
(19, '2911502779434571', 1, '2017-08-15 01:43:54', 19, 1),
(20, '2911502784044375', 1, '2017-08-15 03:00:44', 20, 1),
(21, '2911502784536831', 1, '2017-08-15 03:08:57', 21, 1),
(22, '2911502784548461', 1, '2017-08-15 03:09:08', 22, 1),
(23, '2911502784633368', 1, '2017-08-15 03:10:33', 23, 1),
(24, '2911502784647010', 1, '2017-08-15 03:10:47', 24, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipocuenta`
--

CREATE TABLE `tipocuenta` (
  `idTipoCuenta` int(11) NOT NULL,
  `tcu_tipo` varchar(45) COLLATE latin1_spanish_ci NOT NULL,
  `tcu_monto_apertura` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `tipocuenta`
--

INSERT INTO `tipocuenta` (`idTipoCuenta`, `tcu_tipo`, `tcu_monto_apertura`) VALUES
(1, 'Ahorro', 0),
(2, 'Inversion', 1500);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipoejecutivo`
--

CREATE TABLE `tipoejecutivo` (
  `idTipoEjecutivo` int(11) NOT NULL,
  `tej_tipo` varchar(45) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `tipoejecutivo`
--

INSERT INTO `tipoejecutivo` (`idTipoEjecutivo`, `tej_tipo`) VALUES
(1, 'Gerente'),
(2, 'Ejecutivo'),
(3, 'Cajero');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipomovimiento`
--

CREATE TABLE `tipomovimiento` (
  `idTipoMovimiento` int(11) NOT NULL,
  `tra_tipo` varchar(50) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `tipomovimiento`
--

INSERT INTO `tipomovimiento` (`idTipoMovimiento`, `tra_tipo`) VALUES
(1, 'Apertura'),
(2, 'Deposito'),
(3, 'Transferencia');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tiporelacion`
--

CREATE TABLE `tiporelacion` (
  `idRelacion` int(11) NOT NULL,
  `rel_tipo` varchar(45) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `tiporelacion`
--

INSERT INTO `tiporelacion` (`idRelacion`, `rel_tipo`) VALUES
(1, 'Conyuge'),
(2, 'Hijo/a'),
(3, 'Padre'),
(4, 'Madre'),
(5, 'Hermano/a');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipotarjeta`
--

CREATE TABLE `tipotarjeta` (
  `idTipoTarjeta` int(11) NOT NULL,
  `ttar_tipo` varchar(45) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `tipotarjeta`
--

INSERT INTO `tipotarjeta` (`idTipoTarjeta`, `ttar_tipo`) VALUES
(1, 'Nomina');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipousuario`
--

CREATE TABLE `tipousuario` (
  `idTipoUsuario` int(11) NOT NULL,
  `tusu_tipo` varchar(45) COLLATE latin1_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `tipousuario`
--

INSERT INTO `tipousuario` (`idTipoUsuario`, `tusu_tipo`) VALUES
(1, 'Gerente'),
(2, 'Ejecutivo'),
(3, 'Cajero'),
(4, 'Cliente');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idUsuario` int(11) NOT NULL,
  `usu_usuario` varchar(150) COLLATE latin1_spanish_ci NOT NULL,
  `usu_password` varchar(50) COLLATE latin1_spanish_ci NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idTipoUsuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_spanish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idUsuario`, `usu_usuario`, `usu_password`, `timestamp`, `idTipoUsuario`) VALUES
(19, 'alex_9abril@hotmail.com', 'qwerty', '2017-08-13 14:37:58', 2),
(20, 'alex9abril@gmail.com', 'qwerty', '2017-08-13 14:37:58', 3),
(21, 'eder@gmail.com', 'qwerty', '2017-08-13 14:37:58', 4);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `beneficiario`
--
ALTER TABLE `beneficiario`
  ADD PRIMARY KEY (`idBeneficiario`),
  ADD KEY `fk_beneficiario_cliente_idx` (`idCliente`),
  ADD KEY `fk_beneficiario_tiporelacion1_idx` (`idRelacion`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idCliente`),
  ADD KEY `fk_cliente_estatuscliente1_idx` (`idEstatusCliente`),
  ADD KEY `fk_cliente_ejecutivo1_idx` (`idEjecutivo`);

--
-- Indices de la tabla `cuenta`
--
ALTER TABLE `cuenta`
  ADD PRIMARY KEY (`idCuenta`),
  ADD KEY `fk_cuenta_cliente1_idx` (`idCliente`),
  ADD KEY `fk_cuenta_estatuscuenta1_idx` (`idEstatusCuenta`),
  ADD KEY `fk_cuenta_tipocuenta1_idx` (`idTipoCuenta`);

--
-- Indices de la tabla `ejecutivo`
--
ALTER TABLE `ejecutivo`
  ADD PRIMARY KEY (`idEjecutivo`),
  ADD KEY `fk_ejecutivo_tipoejecutivo1_idx` (`idTipoEjecutivo`),
  ADD KEY `fk_ejecutivo_estatusejecutivo1_idx` (`idEstatusEjecutivo`);

--
-- Indices de la tabla `estatuscliente`
--
ALTER TABLE `estatuscliente`
  ADD PRIMARY KEY (`idEstatusCliente`);

--
-- Indices de la tabla `estatuscuenta`
--
ALTER TABLE `estatuscuenta`
  ADD PRIMARY KEY (`idEstatusCuenta`);

--
-- Indices de la tabla `estatusejecutivo`
--
ALTER TABLE `estatusejecutivo`
  ADD PRIMARY KEY (`idEstatusEjecutivo`);

--
-- Indices de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD PRIMARY KEY (`idMovimiento`),
  ADD KEY `fk_movimientos_cuenta1_idx` (`idCuenta`),
  ADD KEY `fk_movimientos_tipomovimiento1_idx` (`idTipoMovimiento`);

--
-- Indices de la tabla `tarjeta`
--
ALTER TABLE `tarjeta`
  ADD PRIMARY KEY (`idTarjeta`),
  ADD KEY `fk_tarjeta_cuenta1_idx` (`idCuenta`),
  ADD KEY `fk_tarjeta_tipotarjeta1_idx` (`idTipoTarjeta`);

--
-- Indices de la tabla `tipocuenta`
--
ALTER TABLE `tipocuenta`
  ADD PRIMARY KEY (`idTipoCuenta`);

--
-- Indices de la tabla `tipoejecutivo`
--
ALTER TABLE `tipoejecutivo`
  ADD PRIMARY KEY (`idTipoEjecutivo`);

--
-- Indices de la tabla `tipomovimiento`
--
ALTER TABLE `tipomovimiento`
  ADD PRIMARY KEY (`idTipoMovimiento`);

--
-- Indices de la tabla `tiporelacion`
--
ALTER TABLE `tiporelacion`
  ADD PRIMARY KEY (`idRelacion`);

--
-- Indices de la tabla `tipotarjeta`
--
ALTER TABLE `tipotarjeta`
  ADD PRIMARY KEY (`idTipoTarjeta`);

--
-- Indices de la tabla `tipousuario`
--
ALTER TABLE `tipousuario`
  ADD PRIMARY KEY (`idTipoUsuario`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idUsuario`),
  ADD KEY `fk_usuario_tipousuario1_idx` (`idTipoUsuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `beneficiario`
--
ALTER TABLE `beneficiario`
  MODIFY `idBeneficiario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT de la tabla `cuenta`
--
ALTER TABLE `cuenta`
  MODIFY `idCuenta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT de la tabla `ejecutivo`
--
ALTER TABLE `ejecutivo`
  MODIFY `idEjecutivo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `estatuscliente`
--
ALTER TABLE `estatuscliente`
  MODIFY `idEstatusCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `estatuscuenta`
--
ALTER TABLE `estatuscuenta`
  MODIFY `idEstatusCuenta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `estatusejecutivo`
--
ALTER TABLE `estatusejecutivo`
  MODIFY `idEstatusEjecutivo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  MODIFY `idMovimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT de la tabla `tarjeta`
--
ALTER TABLE `tarjeta`
  MODIFY `idTarjeta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT de la tabla `tipocuenta`
--
ALTER TABLE `tipocuenta`
  MODIFY `idTipoCuenta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `tipoejecutivo`
--
ALTER TABLE `tipoejecutivo`
  MODIFY `idTipoEjecutivo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `tipomovimiento`
--
ALTER TABLE `tipomovimiento`
  MODIFY `idTipoMovimiento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `tiporelacion`
--
ALTER TABLE `tiporelacion`
  MODIFY `idRelacion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT de la tabla `tipotarjeta`
--
ALTER TABLE `tipotarjeta`
  MODIFY `idTipoTarjeta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `tipousuario`
--
ALTER TABLE `tipousuario`
  MODIFY `idTipoUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idUsuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `beneficiario`
--
ALTER TABLE `beneficiario`
  ADD CONSTRAINT `fk_beneficiario_cliente` FOREIGN KEY (`idCliente`) REFERENCES `cliente` (`idCliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_beneficiario_tiporelacion1` FOREIGN KEY (`idRelacion`) REFERENCES `tiporelacion` (`idRelacion`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `fk_cliente_ejecutivo1` FOREIGN KEY (`idEjecutivo`) REFERENCES `ejecutivo` (`idEjecutivo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_cliente_estatuscliente1` FOREIGN KEY (`idEstatusCliente`) REFERENCES `estatuscliente` (`idEstatusCliente`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `cuenta`
--
ALTER TABLE `cuenta`
  ADD CONSTRAINT `fk_cuenta_cliente1` FOREIGN KEY (`idCliente`) REFERENCES `cliente` (`idCliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_cuenta_estatuscuenta1` FOREIGN KEY (`idEstatusCuenta`) REFERENCES `estatuscuenta` (`idEstatusCuenta`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_cuenta_tipocuenta1` FOREIGN KEY (`idTipoCuenta`) REFERENCES `tipocuenta` (`idTipoCuenta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `ejecutivo`
--
ALTER TABLE `ejecutivo`
  ADD CONSTRAINT `fk_ejecutivo_estatusejecutivo1` FOREIGN KEY (`idEstatusEjecutivo`) REFERENCES `estatusejecutivo` (`idEstatusEjecutivo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_ejecutivo_tipoejecutivo1` FOREIGN KEY (`idTipoEjecutivo`) REFERENCES `tipoejecutivo` (`idTipoEjecutivo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD CONSTRAINT `fk_movimientos_cuenta1` FOREIGN KEY (`idCuenta`) REFERENCES `cuenta` (`idCuenta`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_movimientos_tipomovimiento1` FOREIGN KEY (`idTipoMovimiento`) REFERENCES `tipomovimiento` (`idTipoMovimiento`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tarjeta`
--
ALTER TABLE `tarjeta`
  ADD CONSTRAINT `fk_tarjeta_cuenta1` FOREIGN KEY (`idCuenta`) REFERENCES `cuenta` (`idCuenta`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_tarjeta_tipotarjeta1` FOREIGN KEY (`idTipoTarjeta`) REFERENCES `tipotarjeta` (`idTipoTarjeta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `fk_usuario_tipousuario1` FOREIGN KEY (`idTipoUsuario`) REFERENCES `tipousuario` (`idTipoUsuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
