<?php
class Usuario
{
	var $Return_Type;
	var $conn;

	var $usuario;
	var $pass;
	var $tipousuario;

	public function __construct( $Class_Properties = array() ) {
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
	}

	public function login(){
		$_response['success'] = false;
		if( empty( $this->usuario ) && empty( $this->pass ) ){
			$_response['msg']     	= 'Favor de proporcionar tus credenciales';
		}
		else if( empty( $this->usuario ) ){
			$_response['msg']     	= 'Proporciona tu usuario';
		}
		else if( empty( $this->pass ) ){
			$_response['msg']     	= 'Proporciona tu password';
		}
		else if( empty( $this->tipousuario ) ){
			$_response['msg']     	= 'No se ha indicado el tipo de usuario.';
		}
		else{
			$params = array(
					'usuario' 	  => array( 'value' => $this->usuario, 'type' => 'STRING' ),
					'pass' 		  => array( 'value' => $this->pass, 'type' => 'STRING' ),
					'tipousuario' => array( 'value' => $this->tipousuario, 'type' => 'INT' )
				);

			$_result = $this->conn->Query( "SP_LOGIN", $params );

			if( !empty( $_result ) ){
				$_response['success'] 	= true;
				$_response['msg']     	= 'Registros encontrados: ' . count( $_result );
				$_response['data'] 		= $_result;
			}
			else{
				$_response['msg']     	= 'No se encontraron resultados para tu solicitud.';	
			}			
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