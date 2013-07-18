<?php 

class BIM_Growth{
    
    protected $curl = null;
    protected $instagramApiClient = null; 
    protected $twilioApiClient = null; 
    
    public function disablePersona( $reason ){
        $dao = new BIM_DAO_Mysql_Jobs( BIM_Config::db() );
        $dao->disableJob($this->persona->name);
        $this->sendWarningEmail( $reason );
    }
    
    public function sendWarningEmail( $reason ){
        $c = BIM_Config::warningEmail();
        $e = new BIM_Email_Swift( $c->smtp );
        $c->emailData->text = $reason;
        $e->sendEmail( $c->emailData );
    }
    
    public function purgeCookies(){
        $file = $this->getCookieFileName();
        if( file_exists( $file ) ){
            unlink( $file );
        }
    }
    
    protected function getCookieFileName(){
        $uniqueId = isset( $this->persona->name ) ? '_'.$this->persona->name : '';
        $class = get_class( $this );
        return "/tmp/cookies_{$class}{$uniqueId}.txt";
    }
    
    protected function getCurlParams( $headers = array() ){
        $cookieFile = $this->getCookieFileName();
        
        $opts = array(
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_COOKIEJAR => $cookieFile,
            CURLOPT_COOKIEFILE => $cookieFile,
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_HEADER		   => true,
			CURLOPT_FOLLOWLOCATION => true,
			CURLOPT_ENCODING	   => "",
			CURLOPT_AUTOREFERER	   => true,
			CURLOPT_CONNECTTIMEOUT => 60,
			CURLOPT_TIMEOUT		   => 300,
			CURLOPT_MAXREDIRS	   => 10,
			CURLOPT_SSL_VERIFYPEER => true,
			CURLOPT_VERBOSE        => false,
			CURLOPT_USERAGENT => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36'
        );
        return $opts;
    }
    
	public function get( $url, $args = array(), $fullResponse = false, $headers = array() ){
        $queryStr = http_build_query($args);
	    $url = "$url?$queryStr";
		$options = $this->getCurlParams( $headers );
	    return $this->handleRequest($url, $options, $fullResponse, $headers );
	}
	
	public function post( $url, $args = array(), $fullResponse = false, $headers = array() ){
        $queryStr = http_build_query($args);
        $options = $this->getCurlParams( $headers );
		$options[CURLOPT_POSTFIELDS] = $queryStr;
		$options[CURLOPT_POST] = true;
		return $this->handleRequest($url, $options, $fullResponse );
	}
	
	public function handleRequest( $url, $options, $fullResponse = false ){
	    
        $proxy = BIM_Config::getProxy();
        if( $proxy ){
            if( preg_match( '/^https/i', trim($url) ) ){
                $proxy->host = "https://$proxy->host";
            } else {
                $proxy->host = "http://$proxy->host";
            }
            $opts[CURLOPT_PROXYPORT] = $proxy->port;
            $opts[CURLOPT_PROXY] = $proxy->host;
            echo "using proxy: \n";
            print_r( $proxy );
        }
	    
        $ch = curl_init( $url );
		//$ch = $this->initCurl($url);
		curl_setopt_array($ch,$options);
		curl_setopt($ch, CURLINFO_HEADER_OUT, true);
		$responseStr = curl_exec($ch);
		$err = curl_errno($ch);
		$data = curl_getinfo( $ch );
		if( $err ){
			$errmsg  = curl_error($ch) ;
			$msg = "err no: $err - err msg: $errmsg\n";
			error_log( print_r(array($msg,$data),true) );
		}
		//curl_close($ch);
		$response = self::parseResponse( $responseStr );
		//		return $format == 'json' ? json_decode( $response['body'] ) : $response['body'];
		$response['req_info'] = $data;
		if( $fullResponse ){
		    return $response;
        } else {
            return $response['body'];
        }
	}
	
	/**
	 * parses a curlhttp response
	 *
	 * @param string of a complete http response headers and body
	 * @return 	returns an array in the following format which varies depending on headers returned
	
		[status] => the HTTP error or response code such as 404
		[headers] => Array
		(
			[Server] => Microsoft-IIS/5.0
			[Date] => Wed, 28 Apr 2004 23:29:20 GMT
			[X-Powered-By] => ASP.NET
			[Connection] => close
			[Set-Cookie] => COOKIESTUFF
			[Expires] => Thu, 01 Dec 1994 16:00:00 GMT
			[Content-Type] => text/html
			[Content-Length] => 4040
		)
		[body] => Response body (string)

	 */
	
 	public function parseResponse($responseStr) {
 	    
	    $response = explode("\r\n\r\n", $responseStr);
	    $len = count( $response );
	    $responseHeaders = $response[ $len - 2 ];
	    $responseBody = $response[ $len - 1 ];
	    $responseHeaderLines = explode("\r\n", $responseHeaders);
	
	    // First line of headers is the HTTP response code
	    $httpResponseLine = array_shift($responseHeaderLines);
	    $matches = array();
	    if(preg_match('@^HTTP/[0-9]\.[0-9] ([0-9]{3})@',$httpResponseLine, $matches)) { $responseCode = $matches[1]; }
	    $iterations = 0;
	    while($responseCode == 100 && $iterations < 100 ){
		    list($responseHeaders, $responseBody) = explode("\r\n\r\n", $responseBody, 2);
		    $responseHeaderLines = explode("\r\n", $responseHeaders);
		    // First line of headers is the HTTP response code
		    $httpResponseLine = array_shift($responseHeaderLines);
		    $matches = array();
		    if(preg_match('@^HTTP/[0-9]\.[0-9] ([0-9]{3})@',$httpResponseLine, $matches)) { $responseCode = $matches[1]; }
	    	$iterations++;
	    }
	
	    // put the rest of the headers in an array
	    $responseHeaderArray = array();
	    foreach($responseHeaderLines as $headerLine){
	        list($header,$value) = explode(': ', $headerLine, 2);
	        if(!isset( $responseHeaderArray[$header] )){
	        	$responseHeaderArray[$header] = '';
	        }
	        $responseHeaderArray[$header] .= $value;
        }
	
	    return array("status" => $responseCode, "headers" => $responseHeaderArray, "body" => $responseBody);
    }
    
    public function getInstagramApiClient(){
        if( ! $this->instagramApiClient ){
            $conf = BIM_Config::instagram();
            $this->instagramApiClient = new BIM_API_Instagram( $conf->api );
        }
        return $this->instagramApiClient;
    }
    
    public function getTwilioClient(){
        if( ! $this->twilioApiClient ){
            $conf = BIM_Config::twilio();
            $this->twilioApiClient = new Services_Twilio( $conf->api->accountSid, $conf->api->authToken );
        }
        return $this->twilioApiClient;
    }
}