<?PHP
class BIM_API_Instagram extends BIM_API
{
   /**
    * URI of the REST API
    *
    * @access  public
    * @var     string
    */
    public $api_root = 'https://api.instagram.com/v1';
        
   /**
    * Application key (as provided by http://api.zvents.com)
    *
    * @access  public
    * @var     string
    */
    public $client_id = null;

   /**
    * client secret ( as provided by instagram )
    *
    * @access  public
    * @var     string
    */
    public $client_secret = null;

    /**
    * Username
    *
    * @access  private
    * @var     string
    */
    private $user = null;

   /**
    * Password
    *
    * @access  private
    * @var     string
    */
    private $_password = null;
    
   /**
    * User authentication key
    *
    * @access  private
    * @var     string
    */
    private $user_key = null;
    
   /**
    * Latest request URI
    *
    * @access  private
    * @var     string
    */
    private $_request_uri = null;
    
    protected $methods = array(
        'subscriptions' => 'POST'
    );
    
   /**
    * Latest response as unserialized data
    *
    * @access  public
    * @var     string
    */
    public $_response_data = null;
    
   /**
    * Create a new client
    *
    * @access	public
    * @param	string	client_id
    */
    function __construct( $params )
    {
        if( !isset( $params->client_secret ) || !isset( $params->client_id ) ){
            throw new Exception("Missing client_id  or client_seret!.  Please make sure they are passed to the constructor");
        }
        
        $this->client_id = $params->client_id;
        $this->client_secret = $params->client_secret;
    }
    
	public function call( $method, $args = array(), $format = 'json', $fullResponse = false, $reqMethod = 'GET' ){
	    
        $url = $this->api_root . "/$method";
        $args['client_id'] =  $this->client_id;

        $REQ_METHOD = $reqMethod;
        if( isset( $this->methods[ $method ] ) ){
            $REQ_METHOD = $this->methods[ $method ];
        }
        
        $queryStr = http_build_query($args);
        if( $REQ_METHOD == 'GET' ){
            $url = "$url?$queryStr";
        }
        
		$options = array(
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_HEADER		   => true,
			CURLOPT_FOLLOWLOCATION => true,
			CURLOPT_ENCODING	   => "",
			CURLOPT_AUTOREFERER	   => true,
			CURLOPT_CONNECTTIMEOUT => 60,
			CURLOPT_POSTFIELDS	   => $queryStr,
			CURLOPT_TIMEOUT		   => 300,
			CURLOPT_MAXREDIRS	   => 10,
			CURLOPT_CUSTOMREQUEST  => $REQ_METHOD,
			CURLOPT_SSL_VERIFYPEER => false,
			CURLOPT_VERBOSE        => false,
		);

		$ch = curl_init($url);
		curl_setopt_array($ch,$options);
		curl_setopt($ch, CURLINFO_HEADER_OUT, true);
		$responseStr = curl_exec($ch);
		$err = curl_errno($ch);
		$data = curl_getinfo( $ch );
		if( $err ){
			$errmsg  = curl_error($ch) ;
			$msg = "errored when contacting instagram.  err no: $err - err msg: $errmsg\n";
			error_log( print_r(array($msg,$data),true) );
		}
		curl_close($ch);
		$response = self::parseResponse( $responseStr );
		//		return $format == 'json' ? json_decode( $response['body'] ) : $response['body'];
		$response['req_info'] = $data;
		if( $fullResponse ){
		    return $response;
        } else {
            return $response['body'];
        }
	}
	
    public function throttledCall( $method, $args = array(), $format = 'json', $fullResponse = false, $reqMethod = 'GET' ){
    	$response = $this->call( $method, $args, $format, true, $reqMethod );
        if( !$this->throttle( $response ) ){
    	    $response = $response['body'];
    	} else {
        	$response = $this->call( $method, $args, $format, false, $reqMethod );
       	}
       	return $response;
    }
	
	/**
	headers	Array [10]	
	Content-Encoding	gzip	
	Content-Language	en	
	Content-Type	application/json; charset=utf-8	
	Date	Sat, 28 Apr 2012 05:00:23 GMT	
	Server	nginx/0.8.54	
	Vary	Accept-Language, Cookie	
	X-Ratelimit-Limit	5000	
	X-Ratelimit-Remaining	4998
	Content-Length	62	
	Connection	keep-alive	
	
	we check our remaining calls and if we are at 0, we go to sleep for 10 seconds and see if we can keep going
	every 15 secs.
	
	 */
	public function throttle( $response ){
	    $throttled = false;
	    $key = 'X-Ratelimit-Remaining';
	    $maxedOut =  ( ( !array_key_exists($key, $response['headers'] ) || $response['headers'][ $key ] == 0 ) );
	    if( $maxedOut ){
	        print_r( array( "maxed out!", $response ) );
	        $throttled = true;
	        while( $throttled ){
    	        echo("Going to sleep for 15 secs\n");
    	        sleep( 15 );
    	        echo("Checking the rate limit\n");
    	        // calling media/3  does not mean anything, we just need to call the service and check the response
    	        // to see if we are still limited
    	        $response = $this->call( 'media/3', array(), 'json', true );
        	    $maxedOut =  ( ( !array_key_exists($key, $response['headers'] ) || $response['headers'][ $key ] == 0 ) );
    	        if( !$maxedOut ){
    	            $throttled = false;
    	            print_r("no longer throttled!\n");
    	        }
	        }
	        $throttled = true;
	    }
	    return $throttled;
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
	    // Split response into header and body sections
	    list($responseHeaders, $responseBody) = explode("\r\n\r\n", $responseStr, 2);
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

    public function getPicsByHashTag( $tag, $max_id = null ){
        $params = null;
        if( $max_id ){
            $params = array(
                'max_tag_id' => $max_id
            );
        }
        
    	$pics = json_decode( $this->throttledCall( "tags/$tag/media/recent", $params ) );

        return $pics;
    }

    public function getUser( $userId ){
    	$user = json_decode( $this->throttledCall( "users/$userId" ) );
    	if( isset( $user->meta ) ){
    	    $user = $user->data;
    	}
        return $user;
    }
    
    public function getFollowing( $userId, $params  ){
        $url = "users/$userId/follows";
        $res = $this->call( $url, $params );
        $res = json_decode( $res );
        return $res->data;
    }
    
    public function getFollowers( $userId, $params  ){
        $url = "users/$userId/followed-by";
        $res = $this->call( $url, $params );
        $res = json_decode( $res );
        return $res->data;
    }
    
    public function getLatestPicForUser( $userId, $params  ){
        $url = "users/$userId/media/recent";
        $res = $this->call( $url, $params );
        $res = json_decode( $res );
        return isset( $res->data[0] ) ? $res->data[0] : null;
    }
    
    public function commentOnPic( $pic, $comment, $params ){
        $params['text'] = $comment;
        $method = "/media/$pic->id/comments";
        $response = $this->call( $method, $params, 'json', false, 'POST' );
        return $response;
    }
    
    public function commentOnLatestPic( $userId, $comment, $params ){
        $pic = $this->getLatestPicForUser( $userId, $params  );
        if( $pic ){
            $this->commentOnPic( $pic, $comment, $params );
        }
    }
    
}
