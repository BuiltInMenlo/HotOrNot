<?php 

class BIM_Growth{
    
    protected function getCurlParams(){
        return array(
            CURLOPT_COOKIEJAR => '/tmp/cookies.txt',
            CURLOPT_COOKIEFILE => '/tmp/cookies.txt',
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_HEADER		   => true,
			CURLOPT_FOLLOWLOCATION => true,
			CURLOPT_ENCODING	   => "",
			CURLOPT_AUTOREFERER	   => true,
			CURLOPT_CONNECTTIMEOUT => 60,
			CURLOPT_TIMEOUT		   => 300,
			CURLOPT_MAXREDIRS	   => 10,
			CURLOPT_CUSTOMREQUEST  => 'GET',
			CURLOPT_SSL_VERIFYPEER => true,
			CURLOPT_VERBOSE        => false,
			CURLOPT_USERAGENT => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36'
        );
    }
    
	public function get( $url, $args = array(), $fullResponse = false ){
        $queryStr = http_build_query($args);
	    $url = "$url?$queryStr";
		$options = $this->getCurlParams();
	    return $this->handleRequest($url, $options, $fullResponse);
	}
	
	public function post( $url, $args = array(), $fullResponse = false ){
        $queryStr = http_build_query($args);
        $options = $this->getCurlParams();
		$options[CURLOPT_POSTFIELDS] = $queryStr;
		$options[CURLOPT_CUSTOMREQUEST]  = 'POST';
		return $this->handleRequest($url, $options, $fullResponse);
	}
	
	public function handleRequest( $url, $options, $fullResponse ){
		// open the handle and execute the call to sendstream
		$ch = curl_init($url);
		curl_setopt_array($ch,$options);
		$responseStr = curl_exec($ch);
		$err = curl_errno($ch);
		$data = curl_getinfo( $ch );
		if( $err ){
			$errmsg  = curl_error($ch) ;
			$msg = "err no: $err - err msg: $errmsg\n";
			error_log( print_r(array($msg,$data),true) );
		}
		curl_close($ch);
		$response = self::parseResponse( $responseStr );
		//		return $format == 'json' ? json_decode( $response['body'] ) : $response['body'];
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
}