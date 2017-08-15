<?php
// include 'app/model/tbl_medico.class.php';

class Cliente
{
	var $Return_Type;
	var $conn;

	var $idEjecutivo;

	var $key;

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

			$_response = $_result[0];
		}

		return $this->Request( $_response );
	}

	public function nuevoCliente(){
		$_response['success'] = false;
		if( empty( $this->emp_id ) ){
			$_response['msg']     	= 'No se ha especificado el Id de la empresa.';
		}
		else if( empty( $this->cli_razon_social ) ){
			$_response['msg']     	= 'Se debe proporcionar la razón social del cliente.';
		}
		else if( empty( $this->cli_rfc ) ){
			$_response['msg']     	= 'Debe ingresar el RFC del cliente.';
		}
		else if(!filter_var($this->cli_email, FILTER_VALIDATE_EMAIL)){
			$_response['msg']     	= 'El email proporcionado no cuenta con el formato requerido.';
		}
		else if( empty( $this->cli_celular ) ){
			$_response['msg']     	= 'Se debe especificar el número de celular, para esta operación este campo es obligatorio.';
		}
		else if( empty( $this->cli_nombre ) ){
			$_response['msg']     	= 'No se ha especificado el nombre del representante del cliente.';
		}
		else if( empty( $this->ctc_id ) ){
			$_response['msg']     	= 'No se ha proporcionado el tipo de cliente.';
		}
		else{
			$key = md5( date("Y-m-d H:i:s") );
			$params = array(
				'idEmpresa' => array( 'value' => $this->emp_id,   		  'type' => 'INT' ),
				'_razon' 	=> array( 'value' => $this->cli_razon_social, 'type' => 'STRING' ),
				'_rfc'  	=> array( 'value' => $this->cli_rfc,  		  'type' => 'STRING' ),
				'_email'    => array( 'value' => $this->cli_email,	  	  'type' => 'STRING' ),
				'_telefono' => array( 'value' => $this->cli_telefono,	  'type' => 'STRING' ),
				'_celular'  => array( 'value' => $this->cli_celular,	  'type' => 'STRING' ),
				'_nombre'   => array( 'value' => $this->cli_nombre,	      'type' => 'STRING' ),
				'_ctc'    	=> array( 'value' => $this->ctc_id,	      	  'type' => 'INT' ),
				'_key'      => array( 'value' => $key,				  	  'type' => 'STRING' )
			);

			$_result = $this->conn->Query( "CLI_INSERTAR_NUEVO_SP", $params );

			$_response = $_result[0];
		}
		
		return $this->Request( $_response );
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