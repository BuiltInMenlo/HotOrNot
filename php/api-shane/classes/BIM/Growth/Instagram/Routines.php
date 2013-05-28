<?php

class BIM_Growth_Instagram_Routines{
    protected $persona = null;
    protected $oauth = null;
    protected $oauth_data = null;
    
    public function __construct( $persona ){
        $this->persona = $persona;
        
        $conskey = 'TXB9fZ1LMYthFd8ZPTjV0qRKesFsKo6GIDPG3deOTmtAxxSO6L';
        $conssec = 'oPos1EyfSnNDgfo7KLmH0I4PhMUNhHCGHLQZA2VJw4dEwUfzuh';
        $this->oauth = new OAuth($conskey,$conssec);
        $this->oauth->enableDebug();
    }
    
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
	
	/**
	 * oauth_token=6DB4hFn3rfhu72F6h6eGaANn6FYFSdfeIbOY74ic2wUH196GtT
	 * input type="hidden" name="form_key" value="!1231369675784|eYlf6FoNjc0vyXVkMWKKyenrNFU"
	 */
    public function login( ){
        
        $loggedIn = false;
        
        // first we attempt to access our oauth script
        // and we get the oauth_token and the form_key from the response
        $response = $this->get( 'http://54.243.163.24/instagram_oauth.php' );
        
        $ptrn = '/name="form_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $formKey = $matches[1];
        
        $ptrn = '/oauth_token=(.+?)\b/';
        preg_match($ptrn, $response, $matches);
        $oauthToken = $matches[1];
        
        $ptrn = '/type="hidden" name="recaptcha_public_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $recapPubKey = $matches[1];
        
        $redirect_to = "http://www.instagram.com/oauth/authorize?oauth_token=$oauthToken";
        
        $input = array(
            'user[email]' => $this->persona->instagram->email,
            'user[password]' =>  $this->persona->instagram->password,
            'tumblelog[name]' => '',
            'user[age]' => '',
            'recaptcha_public_key' => $recapPubKey,
            'recaptcha_response_field' => '',
            'context' => 'no_referer',
            'redirect_to' => $redirect_to,
            'form_key' => $formKey,
            'seen_suggestion' => '0',
            'used_suggestion' => '0',
        );
                
        $response = $this->post('https://www.instagram.com/login', $input, true);
        
        if( isset( $response['headers']['Set-Cookie'] ) && preg_match('/logged_in=1/', $response['headers']['Set-Cookie'] ) ){
            $loggedIn = true;
        }
        
        $input = array(
            'form_key' => $formKey,
            'oauth_token' => $oauthToken,
            'allow' => ''
        );
        
        $response = $this->post("http://www.instagram.com/oauth/authorize?oauth_token=$oauthToken", $input);
        
        $ptrn = '/name="form_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $formKey = $matches[1];
        
        $ptrn = '/name="oauth_token" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $oauthToken = $matches[1];
        
        $input = array(
            'form_key' => $formKey,
            'oauth_token' => $oauthToken,
            'allow' => ''
        );
        
        $response = $this->post("http://www.instagram.com/oauth/authorize?oauth_token=$oauthToken", $input );
        
        $this->oauth_data = $response = json_decode($response);
        $this->oauth->setToken( $response->oauth_token, $response->oauth_token_secret);
        
        
    }
    
    public function followUser( $user ){
        //$url = "http://api.instagram.com/v2/blog/exty86.instagram.com/post";
        //$params = array('type'=>'text', 'body'=>'This is a test post');
        $url = "http://api.instagram.com/v2/user/follow";
        
        $params = array( 'url' => $user->blogUrl );
        
        //Post text 'This is a test post' to user's Instagram
        $this->oauth->fetch($url, $params, OAUTH_HTTP_METHOD_POST);
        
        //Print out Instagram's response
        $json = json_decode($this->oauth->getLastResponse());
        print_r($json);
    }
}
