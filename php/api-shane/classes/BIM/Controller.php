<?php 

class BIM_Controller{
    
    protected $user = null;
    
    public function handleReq(){
        $res = null;
        if( $this->sessionOK() ){
            $request = BIM_Utils::getRequest();
            $method = $request->method;
            $controllerClass = $request->controllerClass;
            $r = new $controllerClass();
            if( $method && method_exists( $r, $method ) ){
                $r->user = BIM_Utils::getSessionUser();
                $res = $r->$method();
                if( is_bool( $res ) ){
                    $res = array( 'result' => $res );
                }
            }
        }
        $this->sendResponse( 200, $res );
    }
        
	public function getStatusCodeMessage($status) {			
		$codes = array(
			100 => 'Continue',
			101 => 'Switching Protocols',
			200 => 'OK',
			201 => 'Created',
			202 => 'Accepted',
			203 => 'Non-Authoritative Information',
			204 => 'No Content',
			205 => 'Reset Content',
			206 => 'Partial Content',
			300 => 'Multiple Choices',
			301 => 'Moved Permanently',
			302 => 'Found',
			303 => 'See Other',
			304 => 'Not Modified',
			305 => 'Use Proxy',
			306 => '(Unused)',
			307 => 'Temporary Redirect',
			400 => 'Bad Request',
			401 => 'Unauthorized',
			402 => 'Payment Required',
			403 => 'Forbidden',
			404 => 'Not Found',
			405 => 'Method Not Allowed',
			406 => 'Not Acceptable',
			407 => 'Proxy Authentication Required',
			408 => 'Request Timeout',
			409 => 'Conflict',
			410 => 'Gone',
			411 => 'Length Required',
			412 => 'Precondition Failed',
			413 => 'Request Entity Too Large',
			414 => 'Request-URI Too Long',
			415 => 'Unsupported Media Type',
			416 => 'Requested Range Not Satisfiable',
			417 => 'Expectation Failed',
			500 => 'Internal Server Error',
			501 => 'Not Implemented',
			502 => 'Bad Gateway',
			503 => 'Service Unavailable',
			504 => 'Gateway Timeout',
			505 => 'HTTP Version Not Supported');

		return ((isset($codes[$status])) ? $codes[$status] : '');
	}
			
	public function sendResponse($status=200, $body=null, $content_type='application/json') {			
		$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
		
		header($status_header);
		header("Content-type: ". $content_type);
		
		echo isset($body->data) ? json_encode( $body->data ) : json_encode( $body );
	}
	
	/*
	 * session is ok if 
	 * 		we are calling the function to create a new user
	 * 		OR we have turned off sessions
	 * 		OR we find a valid session user 
	 */
	protected function sessionOK(){
        
        $newUser = false;
        $request = BIM_Utils::getRequest();
        
        if( strtolower( $request->controllerClass ) == 'bim_controller_users' 
                && strtolower( $request->method ) == 'submitnewuser' 
        )
        {
            $newUser = true;
        }
        
        $sessionConf = BIM_Config::session();
        
        return ( $newUser || empty( $sessionConf->use ) || BIM_Utils::getSessionUser() );
	}

}