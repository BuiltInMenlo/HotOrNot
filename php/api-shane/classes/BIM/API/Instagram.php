<?PHP
require_once 'BIM/API.php';
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
    
   /**
    * Log in and verify the user.
    *
    * @access  public
    * @param   string      user
    * @param   string      password
    */
    function login($user, $password)
    {
        $this->user     = $user;
        
        /* Call login to receive a nonce.
         * (The nonce is stored in an error structure.)
         */
        $r = $this->call('users/login', array() );

        $data = $this->_response_data;
        $nonce = $r->nonce;
        
        // Generate the digested password response.
        $response = md5( $nonce . ":" . md5($password) );
        
        // Send back the nonce and response.
        $args = array(
          'nonce'    => $nonce,
          'response' => $response,
        );
        $r = $this->call('users/login', $args);
        
        // Store the provided user_key.
        $this->user_key = $r->user_key;
        
        return 1;
    }
    
	/**
	 * function for making an http call to zvents
	 *
	 * @param string $url - the complete sendstream api url
	 * @param string $method -  the http request method to use (GET,PUT,POST,DELETE)
	 * @param optional string of $xml if data needs to be sent with the api call
	 * @return string - the response from sendstream
	 */
	public function call( $method, $args = array(), $format = 'json', $fullResponse = false ){
	    
        $url = $this->api_root . "/$method";
        $args['client_id'] =  $this->client_id;

        $REQ_METHOD = 'GET';
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

		// open the handle and execute the call to sendstream
		$ch = curl_init($url);
		curl_setopt_array($ch,$options);
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
		if( $fullResponse ){
		    return $response;
        } else {
            return $response['body'];
        }
	}
	
    public function throttledCall( $method, $args = array(), $format = 'json' ){
    	$response = $this->call( $method, $args, $format, true );
        if( !$this->throttle( $response ) ){
    	    $response = $response['body'];
    	} else {
        	$response = $this->call( $method, $args, $format, false );
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
    
    /**
     * returns a SimpleXML object
     *
     * @param string $xmlStr - string of well-formed xml
     * @return SimpleXML object
     */
    public static function fromXML( $xmlStr ){
    	return simplexml_load_string($xmlStr);
    }
    
	/**
	 * The main function for converting to an XML document.
	 * Pass in a multi dimensional array and this recrusively loops through and builds up an XML document.
	 *
	 * @param array $data
	 * @param string $rootNodeName - what you want the root node to be - defaultsto data.
	 * @param SimpleXMLElement $xml - should only be used recursively
	 * @return string XML
	 */
	public static function toXml($data, $rootNodeName = 'data', $xml=null){
		// turn off compatibility mode as simple xml throws a wobbly if you don't.
		if (ini_get('zend.ze1_compatibility_mode') == 1)
		{
			ini_set ('zend.ze1_compatibility_mode', 0);
		}
		
		if ($xml == null)
		{
			$xml = simplexml_load_string("<$rootNodeName />");
		}
		
		// loop through the data passed in.
		foreach($data as $key => $value) {
			// no numeric keys in our xml please!
			if ( is_numeric($key) ){
				// make string key...
				$key = "column". (string) $key;
			}
			
			// replace anything not alpha numeric
			$key = preg_replace('/[^a-z\-]/i', '', $key);
			
			// if there is another array found recursively call this function
			if ( is_array($value) ) {
				$node = $xml->addChild($key);
				// recursive call.
				self::toXml($value, $rootNodeName, $node);
			} else {
				// add single node.
				$value = htmlentities($value);
				$xml->addChild($key,$value);
			}
			
		}
		// pass back as string. or simple xml object if you want!
		return $xml->asXML();
	}
	
	/**
	 * !!!!!!!!!!!!  THIS FUNCTION MIGHT THROTTLE AND MAKE THE PROCESS GO TO SLEEP !!!!!!!!!!!
	 * @param object $event
	 * 
LAT	Latitude of the center search coordinate. If used, lng is required.
MIN_TIMESTAMP	A unix timestamp. All media returned will be taken later than this timestamp.
LNG	Longitude of the center search coordinate. If used, lat is required.
MAX_TIMESTAMP	A unix timestamp. All media returned will be taken earlier than this timestamp.
DISTANCE	Default is 1km (distance=1000), max distance is 5km.
	 * 
	 */
    public function getPicsCloseTo( $event ){
        $params = array(
            'lat' => $event->venue->latitude,
            'lng' => $event->venue->longitude,
            'distance' => 1000,
            'min_timestamp' => $event->media_collection->start_time,
            'max_timestamp' => $event->media_collection->end_time,
            'count' => 1000,
        );
        
    	$pics = json_decode( $this->throttledCall( 'media/search', $params ) );

        return $pics;
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

    /**
	 * !!!!!!!!!!!!  THIS FUNCTION MIGHT THROTTLE AND MAKE THE PROCESS GO TO SLEEP !!!!!!!!!!!
	 * @param object $venue
	 */
    public function getVenuesCloseTo( $exVenue ){
        $params = array(
            'lat' => $exVenue->latitude,
            'lng' => $exVenue->longitude,
            'distance' => 500
         );
        
    	$venues = json_decode( $this->throttledCall( 'locations/search', $params ) );

        return $venues;
    }

    public function getUser( $userId ){
    	$user = json_decode( $this->throttledCall( "users/$userId" ) );
    	if( isset( $user->meta ) ){
    	    $user = $user->data;
    	}
        return $user;
    }
	/**
	 * !!!!!!!!!!!!  THIS FUNCTION MIGHT THROTTLE AND MAKE THE PROCESS GO TO SLEEP !!!!!!!!!!!
	 * 
 	curl 
 	-F 'client_id=ece86780bd9a49dd9a25275974fae1e7' 
 	-F 'client_secret=b23fbde8a92d4b21bfbf95310ba265de' 
 	-F 'object=geography' 
 	-F 'aspect=media' 
 	-F 'lat=37.7650' 
 	-F 'lng=-122.4695' 
 	-F 'radius=1000' 
 	-F 'verify_token=1238_irving_street' 
 	-F 'callback_url=http://dev.targetnode.com/gojo10backend/api/outpic/instagram/subscription/callback' 
 	https://api.instagram.com/v1/subscriptions
 	 */
    public function subscribe( $params ){
        $params['client_secret'] = $this->client_secret;
        require_once 'BIM/API/Instagram.php';
    	$venues = json_decode( $this->throttledCall( 'subscriptions', $params ) );
        return $venues;
    }
	/**
	 * 
	 * !!!!!!!!!!!!  THIS FUNCTION MIGHT THROTTLE AND MAKE THE PROCESS GO TO SLEEP !!!!!!!!!!!
	 * @param object $venue
	 * @param object $event
	 */
    public function getVenuePicsForEvent( $venue, $event ){
        
        $params = array(
            'min_timestamp' => $event->media_collection->start_time,
            'max_timestamp' => $event->media_collection->end_time,
        );

        $url = 'locations/'.$venue->id.'/media/recent';

        $pics_array = array();
        $pics = json_decode( $this->throttledCall( $url, $params ) );
    	$pics_array[] = $pics;
    	
    	$hasNext = isset( $pics->pagination ) && is_object( $pics->pagination ) && ( isset($pics->pagination->next_url) );
    	while( $hasNext ){
    	    $ptrn = '#'.$this->api_root.'#';
	        $nextUrl = preg_replace( $ptrn, '', $pics->pagination->next_url );
	        print "calling pics - pagination\n";
	        $res = $this->throttledCall( $nextUrl, $params );
    	    $pics = json_decode( $res );
         	$pics_array[] = $pics;
	        $hasNext = isset( $pics->pagination ) && is_object( $pics->pagination ) && ( isset($pics->pagination->next_url) );
    	}
    	return $pics_array;
    }
}
