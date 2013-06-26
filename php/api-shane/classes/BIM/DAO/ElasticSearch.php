<?php
class BIM_DAO_ElasticSearch
{
    
/*
{
  "from": 0,
  "size": 2,
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "_geo_distance": {
        "coords": {
          "lat": 33.109948,
          "lon": -114.662247
        },
        "order": "asc",
        "unit": "mi"
      }
    }
  ],
  "filter": {
    "geo_distance_range": {
      "from": "0mi",
      "to": "3000mi",
      "coords": {
        "lat": 33.109948,
        "lon": -114.662247
      }
    }
  }
}

{
  "from": 0,
  "size": 1,
  "query": {
    "match_all": []
  },
  "sort": [
    {
      "_geo_distance": {
        "coords": {
          "lat": "37.7790775",
          "lon": "-122.4146372"
        },
        "order": "asc",
        "unit": "mi"
      }
    }
  ],
  "filter": {
    "geo_distance_range": {
      "from": "0mi",
      "to": "3000mi",
      "coords": {
        "lat": "37.7790775",
        "lon": "-122.4146372"
      }
    }
  }
}
*/
    
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
        
        // open the handle and execute the call to sendstream
        if(!isset( $this->curl ) ){
            $this->curl = curl_init();
        }
        $ch = $this->curl;
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
//        return $format == 'json' ? json_decode( $response['body'] ) : $response['body'];
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
    
	public function getSearch( $subClass = '' ){
		if( !isset( $this->search[$subClass] ) ){
		    $searchConf = $this->getSearchConfig();
		    // commented out to test the class auto loading feature of kohana 
			// require_once 'TN/Cache/Memcache.php';
			$classFile = 'TN/Search/ElasticSearch';
			if( $subClass ){
			    $classFile .= "/$subClass";
			}
			$className = preg_replace('#/#', '_', $classFile);
			$classFile .= '.php';
			require_once $classFile;
			$this->search[$subClass] = new $className( $searchConf );
		}
		return  $this->search[$subClass];
	}

	public function getSearchConfig(){
		if( !$this->searchConfig ){
			$this->searchConfig = require('config/elastic_search.php');
		}
		return $this->searchConfig;
	}
    
    /*
    public function getEventsByTime( $min, $max, $params, $from = 0, $size = 10 ){
        // make the term queries for any regions that were passed in
        $should = array();
        if( isset( $params->outpic_regions ) && is_array( $params->outpic_regions ) ){
            foreach( $params->outpic_regions as $region_name ){
                $q = array(
                    "term" => array(
                        'outpic_region' => $region_name
                    )
                );
                $should[] = $q;
            }
        }
        
        // make the range query
        $must = array();
        if( isset(  $params->total_media_items ) ){
            $must[] = array(
                "range" => array(
                    "total_media_items" => array( 
                        "gte" =>  $params->total_media_items,
                    )
                )
            );
        }
        
        $must[] = array(
            "range" => array(
                "media_collection.start_time" => array( 
                    "gte" => $min,
                    "lte" => $max, 
                )
            )
        );
        
        $q = array(
            "from" => $from,
            "size" => $size,
            "query" => array(
                "bool" => array(
                    "must" => $must,
                )
            )
        );
        
        if( $should ){
            $q["query"]['bool']["should"] = $should;
            $q["query"]['bool']["minimum_number_should_match"] = 1;
        }
        
        $urlSuffix = "events/event/_search";
        
        $res = $this->call( 'GET', $urlSuffix, $q );
        return $res;
    }
    */
}
