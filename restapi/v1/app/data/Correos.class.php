<?php
class Correos
{
	var $Return_Type;
	var $conn;
	var $mail;

	var $ToEmail;
	var $ToName;
	var $Subject;
	var $Mensaje;

	var $template;
	var $template_path;

	var $password;

	public function __construct( $Class_Properties = array() ) {
		// $this->template_path = 'app/assets/';
		$this->template_path = $_SERVER['DOCUMENT_ROOT'] . '/restapi/v1/app/assets/templates/';
		$this->Assign_Properties_Values($Class_Properties);
		$this->conn = new Connection();
		$this->Return_Type = 'json';
		$this->mail = new PHPMailer;
		$this->config();
	}

	public function SendMail(){
		$_response['success'] = false;

		if( empty( $this->ToEmail ) ){
			$_response['msg'] 	= 'Debes proporcinar la dirección de correo.';
		}
		else{
			$this->ToEmail = ( empty( $this->ToEmail ) ) ? '' : $this->ToEmail;
			$this->ToName  = ( empty( $this->ToName ) ) ? '' : $this->ToName;
	
			$this->mail->Subject = empty($this->Subject) ? 'Sin asunto' : $this->Subject;
			$this->mail->Body = $this->getTemplete();
			// $this->mail->Body    = empty($this->Mensaje) ? '- ' : $this->Mensaje;
	
			$this->mail->addAddress($this->ToEmail, $this->ToName);
			
			if(!$this->mail->send()) {
			  	$_response['msg'] 	= 'Message was not sent.';
			  	$_response['error'] = $this->mail->ErrorInfo;
			} else {
				$_response['success'] = true;
			  	$_response['msg'] 	= 'Mensaje enviado correctamente';
			}
		}
		
		return $this->Request( $_response );
	}

	private function getTemplete(){
		$html = file_get_contents( $this->template_path . $this->template . '.html' );
		return $html;
	}

	private function config(){
		$this->mail->SMTPDebug  = SMTP::DEBUG_SERVER;
		$this->mail->SMTPDebug  = 0; //Alternative to above constant
		$this->mail->isSMTP();  // tell the class to use SMTP
		$this->mail->SMTPAuth   = true;                // enable SMTP authentication
		$this->mail->Port       = 25;                  // set the SMTP port
		$this->mail->Host       = "mail.nutricionintegral.com.mx"; // SMTP server
		$this->mail->Username   = "agrijalva@nutricionintegral.com.mx"; // SMTP account username
		$this->mail->Password   = "amorOdio1*";     // SMTP account password		
		$this->mail->setFrom('agrijalva@nutricionintegral.com.mx', 'Asesoria');
		$this->mail->IsHTML(true);
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