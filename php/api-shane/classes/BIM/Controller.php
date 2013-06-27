<?php 

class BIM_Controller{
    
    public function handleReq(){
        $c = BIM_Config::app();
        $cdata = trim(str_replace( $c->base_path, '', $_SERVER['SCRIPT_URL'] ),'/');
        
        $cdata = explode( '/', $cdata );
        
        $controller = ucfirst( trim($cdata[0],'/') );
        $controller = str_replace('.php', '', $controller);
        $method = isset( $cdata[1] ) ? trim( $cdata[1], '/' ) : '';
        
        $controllerClass = "BIM_Controller_$controller";
        
        $r = new $controllerClass();
        if( $method && method_exists( $r, $method ) ){
            $res = $r->$method();
        } else {
            $res = $r->handleReq();
        }
        
        if( is_bool( $res ) ){
            $res = array( 'result' => $res );
        }
        $code = 200;
        
        //setcookie( 'foo','poo', time() + 7200, '/','discover.getassembly.com' );
        $this->sendResponse( $code, $res );
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
			
	public function sendResponse($status=200, $body=null, $content_type='text/json') {			
		$status_header = "HTTP/1.1 ". $status ." ". $this->getStatusCodeMessage($status);
		
		header($status_header);
		header("Content-type: ". $content_type);
		
		echo isset($body->data) ? json_encode( $body->data ) : json_encode( $body );
	}
}