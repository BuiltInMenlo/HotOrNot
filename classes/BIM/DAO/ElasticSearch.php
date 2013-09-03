<?php
class BIM_DAO_ElasticSearch
{
    
    public static $profile = null;
    /**
     * 
     * @var search
     */
    protected $search = null;
    
    /**
     * hold the search condif
     * @var searchConfig
     */
    protected $searchConfig = null;
    
   /**
    * URI of the REST API
    *
    * @access  public
    * @var     string
    */
    public $api_root = null;
        
   /**
    * Create a new client
    *
    * @access  public
    * @param   string      app_key
    */
    function __construct( $params = null ){
        if(!isset($params->api_root)){
            throw new Exception("no api root passed to the constructior!!");
        }
        $this->api_root = $params->api_root;
    }
    
    /**
     * function for making an http call to ElasticSearch
     * 
     * here we take the reqmethod
     * build the url
     * then depending on the reqmethod, we get the correct curl options
     * we make the request and return the response
     * 
     * @param string $reqMethod
     * @param string $urlSuffix
     * @param array $args
     * @param string $routing
     */
    public function call( $reqMethod, $urlSuffix, $args = array(), $routing = '' ){
        if( BIM_Utils::isProfiling() ){
            $start = microtime(1);
        }
        
        if( !$reqMethod ){
            throw new Exception("no request method passed to the call method.  you must pass a request method");
        }
        
        $url = "$this->api_root/$urlSuffix";
        if( $routing ){
            $url .= "?routing=$routing";
        }

        $options = array(
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HEADER           => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_ENCODING       => "",
            CURLOPT_AUTOREFERER       => true,
            CURLOPT_CONNECTTIMEOUT => 60,
            CURLOPT_TIMEOUT           => 60,
            CURLOPT_MAXREDIRS       => 10,
            CURLOPT_CUSTOMREQUEST  => $reqMethod,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_VERBOSE        => false,
            CURLOPT_URL            => $url,
        );

        if( $args ){
            $options[ CURLOPT_POSTFIELDS ] = json_encode( $args );
        }
        $ch = curl_init();
        curl_setopt_array($ch,$options);
        $responseStr = curl_exec($ch);
        
        $err = curl_errno($ch);
        $data = curl_getinfo( $ch );
        if( $err ){
            $errmsg  = curl_error($ch) ;
            $msg = "errored when contacting ElasticSearch.  err no: $err - err msg: $errmsg\n";
            error_log( print_r(array($msg,$data),true) );
        }
        //curl_close($ch);
        
        $response = self::parseResponse( $responseStr );
//      return $format == 'json' ? json_decode( $response['body'] ) : $response['body'];
        if( BIM_Utils::isProfiling() ){
            if( strtolower($reqMethod) == 'get' ){
                $suffix = explode( '/', $urlSuffix );
                array_pop($suffix);
                $suffix = join('/',$suffix);
                $q = "{$reqMethod}_$suffix";
            } else {
                $q = "{$reqMethod}_$urlSuffix";
            }
            $end = microtime(1);
            if( empty( self::$profile ) ){
                self::$profile = array();
            }
            if( empty( self::$profile[ $q ] ) ){
                self::$profile[ $q ] = array();
                self::$profile[ $q ]['total'] = 0;
                self::$profile[ $q ]['time'] = 0;
            }
            self::$profile[ $q ]['total']++;
            self::$profile[ $q ]['time'] += ($end - $start);

            $bt = debug_backtrace();
            $callTree = join( ' => ', array( $bt[2]['class'].':'.$bt[2]['function'], $bt[1]['class'].':'.$bt[1]['function'] ) );
            if( !isset( self::$profile[ $q ][$callTree] ) ){
                self::$profile[ $q ][$callTree] = 0;
            }
            self::$profile[ $q ][$callTree]++;
        }
        
        return $response['body'];
    }
    
    /**
     * parses a curlhttp response
     *
     * @param string of a complete http response headers and body
     * @return     returns an array in the following format which varies depending on headers returned
    
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
    
    public function flush(){
        $this->call('GET','_flush');
    }
}
