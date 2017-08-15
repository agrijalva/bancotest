<?php

class Cliente
{
	var $Return_Type;
	var $conn;

	var $idEjecutivo;
	var $Catalogo;

	var $cli_apellidos;
	var $cli_celular;
	var $cli_email;
	var $cli_nombre;
	var $cli_rfc;
	var $cli_telefono;
	var $idEstatusCliente;
	var $idTipoCuenta;
	var $idTipoTarjeta;
	var $noCliente;
	var $noTarjeta;

	var $idCliente;

	var $tipo;
	var $numero;

	var $mov_monto;
	var $idCuenta;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function obtenerClientes(){
		$_response['success'] = false;
		if( empty( $this->idEjecutivo ) ){
			$_response['msg']     	= 'No se ha especificado el Id del ejecutivo.';
		}
		else{
			$params = array('idEjecutivo' => array( 'value' => $this->idEjecutivo, 'type' => 'STRING' ));

			$_result = $this->conn->Query( "SP_OBTENER_CLIENTES", $params );

			$_response = $_result;
		}

		return $this->Request( $_response );
	}

	public function getCatalogo(){
		$_response['success'] = false;
		if( empty( $this->Catalogo ) ){
			$_response['msg']     	= 'No se ha especificado el catálogo que necesita.';
		}
		else{
			$params = array('Catalogo' => array( 'value' => $this->Catalogo, 'type' => 'STRING' ));

			$_result = $this->conn->Query( "SP_CATALOGOS", $params );

			$_response = $_result;
		}

		return $this->Request( $_response );
	}

	public function guardarTarjetahabiente(){
		$_response['success'] = false;

		if( empty( $this->cli_nombre ) ){
			$_response['msg']     	= 'No se ha especificado nombre del tarjetahabiente.';
		}
		else if( empty( $this->cli_apellidos ) ){
			$_response['msg']     	= 'No se ha especificado los apellidos del tarjetahabiente.';
		}
		else if( empty( $this->cli_rfc ) ){
			$_response['msg']     	= 'No se ha especificado el RFC.';
		}
		else if( empty( $this->cli_email ) ){
			$_response['msg']     	= 'No se ha especificado el email.';
		}
		else if(!filter_var($this->cli_email, FILTER_VALIDATE_EMAIL)){
			$_response['msg']     	= 'El email proporcionado no cuenta con el formato requerido.';
		}
		else if( !$this->verificarEmailCliente( $this->cli_email ) ){
			$_response['msg']     	= 'El email que proporcionó ya esta en uso.';
		}		
		else if( empty( $this->cli_telefono ) ){
			$_response['msg']     	= 'No se ha especificado el teléfono de casa.';
		}
		else if( empty( $this->cli_celular ) ){
			$_response['msg']     	= 'No se ha especificado el numero celular.';
		}
		else if( empty( $this->idTipoCuenta ) ){
			$_response['msg']     	= 'No se ha especificado el tipo de cuenta.';
		}
		else if( empty( $this->idTipoTarjeta ) ){
			$_response['msg']     	= 'No se ha especificado el tipo de tarjeta.';
		}
		else if( empty( $this->idEstatusCliente ) ){
			$_response['msg']     	= 'No se ha especificado el estatus del cliente.';
		}
		else if( empty( $this->idEjecutivo ) ){
			$_response['msg']     	= 'No se ha especificado el Id del ejecutivo.';
		}
		else if( empty( $this->noCliente ) ){
			$_response['msg']     	= 'No se ha especificado el número de cliente.';
		}
		else if( empty( $this->noTarjeta ) ){
			$_response['msg']     	= 'No se ha especificado el número de tarjeta.';
		}
		else{
			$params_cliente = array(
				'_noCliente'    => array( 'value' => $this->noCliente,	      'type' => 'STRING' ),
				'_cli_nombre'    => array( 'value' => $this->cli_nombre,	  'type' => 'STRING' ),
				'_cli_apellidos' => array( 'value' => $this->cli_apellidos,   'type' => 'STRING' ),
				'_cli_rfc'  	 => array( 'value' => $this->cli_rfc,  		  'type' => 'STRING' ),
				'_cli_email'     => array( 'value' => $this->cli_email,	  	  'type' => 'STRING' ),
				'_cli_telefono'  => array( 'value' => $this->cli_telefono,	  'type' => 'STRING' ),
				'_cli_celular'   => array( 'value' => $this->cli_celular,	  'type' => 'STRING' ),
				'_idEjecutivo' 	 => array( 'value' => $this->idEjecutivo, 	  'type' => 'INT' )
			);
			$_result = $this->conn->Query( "SP_REGISTRAR_CLIENTE", $params_cliente );
			$ResultCliente = $_result;

			if( count( $ResultCliente ) != 0 ){
				$params_cuenta = array(
					'_idEjecutivo'    	=> array( 'value' => $this->idEjecutivo,	      'type' => 'INT' ),
					'_idCliente' 		=> array( 'value' => $ResultCliente[0]['lastId'], 'type' => 'INT' ),
					'_idEstatusCuenta'  => array( 'value' => 1,  		  			 	  'type' => 'INT' ),
					'_idTipoCuenta' 	=> array( 'value' => $this->idTipoCuenta, 	  	  'type' => 'INT' )
				);
				$_result = $this->conn->Query( "SP_NUEVA_CUENTA", $params_cuenta );
				$ResultCuenta = $_result;

				if( count( $ResultCuenta ) != 0 ){
					// Registramos el movimiento
					$params_deposito = array(
						'_mov_monto'    	=> array( 'value' => 0,  'type' => 'STRING' ),
						'_idEjecutivo' 		=> array( 'value' => $this->idEjecutivo,    	  'type' => 'INT' ),
						'_idCuenta'  		=> array( 'value' => $ResultCuenta[0]['lastId'], 'type' => 'INT' ),
						'_idTipoMovimiento' => array( 'value' => 1, 	  	  				  'type' => 'INT' ),
						'_idTipoCuenta' 	=> array( 'value' => $this->idTipoCuenta, 	  	  'type' => 'INT' )
					);
					$_result = $this->conn->Query( "SP_DEPOSITOS", $params_deposito );					

					// Registramos la tarjeta
					$params_tarjeta = array(
						'_noTarjeta'    	=> array( 'value' => $this->noTarjeta,	      	  'type' => 'STRING' ),
						'_idEjecutivo' 		=> array( 'value' => $this->idEjecutivo,    	  'type' => 'INT' ),
						'_idCuenta'  		=> array( 'value' => $ResultCuenta[0]['lastId'], 'type' => 'INT' ),
						'_idTipoTarjeta' 	=> array( 'value' => $this->idTipoTarjeta, 	  	  'type' => 'INT' )
					);
					$_result = $this->conn->Query( "SP_TRAMITAR_TARJETA_SP", $params_tarjeta );
					$ResultTarjeta = $_result;

					if( count( $ResultTarjeta ) != 0 ){
						$_response['msg']     	= 'Se guardo correctamente el tarjeta habiente';
						$_response['success']   = true;
					}
				}
				else{
					$_response['msg']     	= 'Ocurrio un error al guardar la cuenta';
				}
			}
			else{
				$_response['msg']     	= 'Ocurrio un error al guardar el cliente';
			}
		}
		
		return $this->Request( $_response );
	}

	public function getCliente(){
		$_response['success'] = false;
		if( empty( $this->noCliente ) ){
			$_response['msg']     	= 'No se ha especificado el número de cliente.';
		}
		else{
			$params = array('noCliente' => array( 'value' => $this->noCliente, 'type' => 'STRING' ));

			$_result = $this->conn->Query( "SP_OBTENER_CLIENTE", $params );

			$_response = $_result;
		}

		return $this->Request( $_response );
	}

	public function getCuentas(){
		$_response['success'] = false;
		if( empty( $this->idCliente ) ){
			$_response['msg']     	= 'No se ha especificado el id del cliente.';
		}
		else{
			$params = array('idCliente' => array( 'value' => $this->idCliente, 'type' => 'STRING' ));
			$_result = $this->conn->Query( "SP_OBTENER_CUENTAS", $params );

			foreach ($_result as $key => $value) {

				$params_saldo = array('idCuenta' => array( 'value' => $value['idCuenta'], 'type' => 'STRING' ));
				$_result_saldo = $this->conn->Query( "SP_SALDO_TARJETAS", $params_saldo );
				$_result[ $key ]['Saldo'] = $_result_saldo[0]['Saldo'];
			}

			$_response = $_result;
		}

		return $this->Request( $_response );
	}

	public function guardarTarjeta(){
		$_response['success'] = false;

		if( empty( $this->idTipoCuenta ) ){
			$_response['msg']     	= 'No se ha especificado el tipo de cuenta.';
		}
		else if( empty( $this->idTipoTarjeta ) ){
			$_response['msg']     	= 'No se ha especificado el tipo de tarjeta.';
		}		
		else if( empty( $this->idEjecutivo ) ){
			$_response['msg']     	= 'No se ha especificado el Id del ejecutivo.';
		}
		else if( empty( $this->noCliente ) ){
			$_response['msg']     	= 'No se ha especificado el número de cliente.';
		}
		else if( empty( $this->noTarjeta ) ){
			$_response['msg']     	= 'No se ha especificado el número de tarjeta.';
		}
		else if( empty( $this->idCliente ) ){
			$_response['msg']     	= 'No se ha especificado el id del cliente.';
		}		
		else{
			$params_cuenta = array(
				'_idEjecutivo'    	=> array( 'value' => $this->idEjecutivo,	      'type' => 'INT' ),
				'_idCliente' 		=> array( 'value' => $this->idCliente, 'type' => 'INT' ),
				'_idEstatusCuenta'  => array( 'value' => 1,  		  			 	  'type' => 'INT' ),
				'_idTipoCuenta' 	=> array( 'value' => $this->idTipoCuenta, 	  	  'type' => 'INT' )
			);
			$_result = $this->conn->Query( "SP_NUEVA_CUENTA", $params_cuenta );
			$ResultCuenta = $_result;

			if( count( $ResultCuenta ) != 0 ){
				// Registramos el movimiento
				$params_deposito = array(
					'_mov_monto'    	=> array( 'value' => 0,  'type' => 'STRING' ),
					'_idEjecutivo' 		=> array( 'value' => $this->idEjecutivo,    	  'type' => 'INT' ),
					'_idCuenta'  		=> array( 'value' => $ResultCuenta[0]['lastId'],  'type' => 'INT' ),
					'_idTipoMovimiento' => array( 'value' => 1, 	  	  				  'type' => 'INT' ),
					'_idTipoCuenta' 	=> array( 'value' => $this->idTipoCuenta, 	  	  'type' => 'INT' )
				);
				$_result = $this->conn->Query( "SP_DEPOSITOS", $params_deposito );					

				// Registramos la tarjeta
				$params_tarjeta = array(
					'_noTarjeta'    	=> array( 'value' => $this->noTarjeta,	      	  'type' => 'STRING' ),
					'_idEjecutivo' 		=> array( 'value' => $this->idEjecutivo,    	  'type' => 'INT' ),
					'_idCuenta'  		=> array( 'value' => $ResultCuenta[0]['lastId'],  'type' => 'INT' ),
					'_idTipoTarjeta' 	=> array( 'value' => $this->idTipoTarjeta, 	  	  'type' => 'INT' )
				);
				$_result = $this->conn->Query( "SP_TRAMITAR_TARJETA_SP", $params_tarjeta );
				$ResultTarjeta = $_result;

				if( count( $ResultTarjeta ) != 0 ){
					$_response['msg']     	= 'Se guardo correctamente el tarjeta habiente';
					$_response['success']   = true;
				}
			}
			else{
				$_response['msg']     	= 'Ocurrio un error al guardar la cuenta';
			}
		}
		
		return $this->Request( $_response );
	}

	public function buscarCuenta(){
		$_response['success'] = false;
		if( empty( $this->tipo ) ){
			$_response['msg']     	= 'No se ha especificado tipo de busqueda.';
		}
		else if( empty( $this->numero ) ){
			$_response['msg']     	= 'No se ha especificado el número de búsqueda.';
		}
		else{
			$params = array(
				'tipo'    	=> array( 'value' => $this->tipo,	 'type' => 'INT' ),
				'numero' 	=> array( 'value' => $this->numero,  'type' => 'STRING' )
			);

			$_result = $this->conn->Query( "SP_BUSCAR_CUENTA", $params );

			$_response = $_result[0];
		}

		return $this->Request( $_response );
	}

	public function deposito(){
		$_response['success'] = false;
		if( empty( $this->mov_monto ) ){
			$_response['msg']     	= 'No se ha especificado el monto a depositar.';
		}
		else if( empty( $this->idEjecutivo ) ){
			$_response['msg']     	= 'No se ha especificado el id del ejecutivo.';
		}
		else if( empty( $this->idCuenta ) ){
			$_response['msg']     	= 'No se ha especificado el número de cuenta.';
		}
		else{
			$params = array(
				'_mov_monto'    	=> array( 'value' => $this->mov_monto,	 'type' => 'INT' ),
				'_idEjecutivo'    	=> array( 'value' => $this->idEjecutivo,	 'type' => 'INT' ),
				'_idCuenta'    		=> array( 'value' => $this->idCuenta,	 'type' => 'INT' ),
				'_idTipoMovimiento' => array( 'value' => 2,	 'type' => 'INT' ),
				'_idTipoCuenta' 	=> array( 'value' => 0,  'type' => 'STRING' )
			);

			$_result = $this->conn->Query( "SP_DEPOSITOS", $params );

			$_response = $_result[0];
		}

		return $this->Request( $_response );
	}

	public function verificarEmailCliente( $email ){
		$params = array('email' => array( 'value' => $email, 'type' => 'STRING' ));
		$_result = $this->conn->Query( "SP_VERIFICAR_EMAIL_CLIENTE", $params );

		return ( count( $_result ) == 0 ) ? true : false;
	}

	private function Assign_Properties_Values($Properties_Array){
		if (is_array($Properties_Array)) {
			foreach($Properties_Array as $Property_Name => $Property_Value)  {
				$this->{$Property_Name} = trim(htmlentities($Property_Value, ENT_QUOTES, 'UTF-8'));
			}
		}
	}

	private function Request( $_array ){
		if( empty( $this->Return_Type ) ){
			return $_array;			
		}
		else if( $this->Return_Type == 'json'  || $this->Return_Type == 'JSON' ){
			print_r( json_encode( $_array ) );
		}
	}
}
?>