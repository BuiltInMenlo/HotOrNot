<?php 

class BIM_Growth{
    
    protected $curl = null;
    protected $instagramApiClient = null; 
    protected $twilioApiClient = null; 
    protected $useProxy = false;
    
	public function testProxies( $url ){
	    
	    $c = BIM_Config::proxies();
	    foreach( $c->proxies as $proxyInfo ){
	        list( $host,$port) = explode(':',$proxyInfo);
	        echo "testing $host $port\n";
	        $ch = curl_init( $url );
    		//$ch = $this->initCurl($url);
    		$options = $this->getCurlParams();
    		$options[CURLOPT_TIMEOUT] = 30;
    		$options[CURLOPT_CONNECTTIMEOUT] = 30;
    		curl_setopt_array($ch, $options);
    		
    		curl_setopt($ch, CURLINFO_HEADER_OUT, true);
            curl_setopt($ch, CURLOPT_PROXY, $host);
            curl_setopt($ch, CURLOPT_PROXYPORT, $port);
            curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 0);
    		
            $responseStr = curl_exec($ch);
    		$err = curl_errno($ch);
    		$data = curl_getinfo( $ch );
    		if( $err ){
    			$errmsg  = curl_error($ch) ;
    			$msg = "err no: $err - err msg: $errmsg\n";
    			error_log( "bad proxy: $host:$port" );
    		}
    		curl_close($ch);
	    }
	}
   
    public function getProxy(){
	    $proxy = BIM_Config::getProxy();
	    return $proxy;
    }
	
    protected function setUseProxy( $onOff = true ){
        $this->useProxy = $onOff;
    }
    
    protected function useProxy( ){
        return $this->useProxy;
    }
    
    public function disablePersona( $reason ){
        $dao = new BIM_DAO_Mysql_Jobs( BIM_Config::db() );
        $dao->disableJob($this->persona->name);
        $this->sendWarningEmail( $reason );
    }
    
    public function enablePersona( ){
        $dao = new BIM_DAO_Mysql_Jobs( BIM_Config::db() );
        $dao->enableJob($this->persona->name);
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
			CURLOPT_TIMEOUT		   => 60,
			CURLOPT_MAXREDIRS	   => 10,
			CURLOPT_SSL_VERIFYPEER => false,
			CURLOPT_VERBOSE        => false,
			CURLOPT_USERAGENT => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36'
        );
        return $opts;
    }
    
	public function get( $url, $args = array(), $fullResponse = false, $headers = array() ){
        $queryStr = http_build_query($args);
        if( $queryStr ){
    	    $url = "$url?$queryStr";
        }
		$options = $this->getCurlParams( $headers );
	    return $this->handleRequest($url, $options, $fullResponse, $headers );
	}
	
	public function post( $url, $args = array(), $fullResponse = false, $headers = array() ){
        $queryStr = http_build_query($args);
        $headers[] = 'Content-Length: '.strlen($queryStr);
        $options = $this->getCurlParams( $headers );
		$options[CURLOPT_POSTFIELDS] = $queryStr;
		$options[CURLOPT_POST] = true;
		return $this->handleRequest($url, $options, $fullResponse );
	}
	
	public function handleRequest( $url, $options, $fullResponse = false ){
	    
        $ch = curl_init( $url );
		curl_setopt_array($ch,$options);
		curl_setopt($ch, CURLINFO_HEADER_OUT, true);
		
		if( $this->useProxy() ){
            $proxy = $this->getProxy();
		    if( $proxy ){
		        print_r( array( 'USING PROXY', $proxy ) );
                curl_setopt($ch, CURLOPT_PROXY, $proxy->host);
                curl_setopt($ch, CURLOPT_PROXYPORT, $proxy->port);
                curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 0);
            }
        }
        
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
    
    /**
     *
       \_o_/
         |
       _/ \_
     * getting campaign data means 
     * getting all of the tags for a network
     * then we take the total number of images to get and figure out how many per tag
     * then we proceed to try and get images for those tags
     * 
     * we search tumblr with the tag
     * foreach inage we:
     * 		save the image to disk in a folder named after the job
     * 		collect all comments for the images in a file named "comments" in the same folder
     * 		collect the associated comment with the image and save it into a file named quotes
     *
     * after we have collected or exhausted all of the images
     * we zip up the folder and associated images and send an email out to jason
     * with a link to said zip file
     */
    public static function createCampaign( $params ){
        $totalImages = $params->total_media;
        $freq = $params->freq;
        $network = $params->network;
        
        $imagesRetrieved = 0;
        
        // first get the tags for the network
        $dao = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
        $tags = $dao->getTags( $network, 'authentic' );
        $tags = $tags[0];
        $tags = json_decode($tags->tags);
        
        $contentPerTag = ceil( $totalImages / count( $tags ) );
        
        $c = BIM_Config::tumblr();
        $q = new Tumblr\API\Client($c->api->consumerKey, $c->api->consumerSecret);
        
        $dir = $network.'-'.uniqid();
        mkdir( $dir );
        $commentsFile = "$dir/comments.csv";
        file_put_contents($commentsFile, "caption,post url,image name\n", FILE_APPEND);
        $tarFiles = array();
        foreach( $tags as $tag ){
            $options = array( 'limit' => $contentPerTag );
            $posts = $q->getTaggedPosts( $tag, $options );
            foreach( $posts as $post ){
                $contentRetrieved = 0;
                if( $post->type == 'photo' && !empty( $post->photos ) ){
                    foreach( $post->photos as $photo ){
                        if( $imagesRetrieved >= $totalImages ){
                            break(3);
                        }
                        $image = new Imagick( $photo->original_size->url );
                        $imageName = explode('/', $photo->original_size->url );
                        $imageName = array_pop( $imageName );
                        $filePath = "$dir/$imageName";
                        $image->writeImage( $filePath );
                        $caption = strip_tags($post->caption);
                        $postUrl = strip_tags($post->post_url);
                        file_put_contents($commentsFile, "$caption,$postUrl,$imageName\n", FILE_APPEND);
                        $tarFiles[] = $filePath;
                        /*
                        $postData = $q->getBlogPosts( 
                            $post->blog_name, 
                            array( 
                            	'id' => $post->id, 
                            	'reblog_info' => true, 
                            	'notes_info' => true 
                            ) 
                        );
                        */
                        echo ++$imagesRetrieved." images retrieved. \n";
                        sleep(1);
                    }
                }
            }
        }
        // create the tar file and zip it uo
        $tar_object = new Archive_Tar("$dir.tgz", true);
        $tar_object->setErrorHandling(PEAR_ERROR_PRINT);
        $tarFiles[] = $commentsFile;
        $tar_object->create($tarFiles);
        
        // now we move the tar file to the web dir and send an email out
        rename("$dir.tgz", "/var/www/html/$dir.tgz");
        
        $c = BIM_Config::smtp();
        $e = new BIM_Email_Swift( $c );
        $emailData = (object) array(
        	'to_email' => 'jason@builtinmenlo.com',
        	'from_email' => 'apps@builtinmenlo.com',
        	'from_name' => 'Scumbag Kim Dot Com',
        	'subject' => 'Your shady campaign has been created',
        	'text' => "The campaign $dir has been created.  http://64.27.28.124/$dir.tgz"
        );

        $e->sendEmail( $emailData );
        
        foreach( $tarFiles as $file ){
            unlink( $file );
        }
        rmdir( $dir );
    }
}