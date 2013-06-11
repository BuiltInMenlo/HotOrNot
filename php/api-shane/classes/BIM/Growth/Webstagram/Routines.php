<?php

class BIM_Growth_Webstagram_Routines extends BIM_Growth_Webstagram{
    
    protected $persona = null;
    protected $oauth = null;
    protected $oauth_data = null;
    
    public function __construct( $persona ){
        if( is_string( $persona )  ){
            $persona = new BIM_Growth_Persona( $persona );
        } 
        $this->persona = $persona;
        
        $this->instagramConf = BIM_Config::instagram();
        $clientId = $this->instagramConf->api->client_id;
        $clientSecret = $this->instagramConf->api->client_secret;
        
        //$this->oauth = new OAuth($conskey,$conssec);
        //$this->oauth->enableDebug();
    }
    
    /*
    
    Request URL:https://instagram.com/oauth/authorize/?client_id=63a3a9e66f22406799e904ccb91c3ab4&redirect_uri=http://54.243.163.24/instagram_oauth.php&response_type=code
    Request Headersview source
    
    */// Accept:text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8 
    /*
    
    Content-Type:application/x-www-form-urlencoded
    Origin:https://instagram.com
    Referer:https://instagram.com/oauth/authorize/?client_id=63a3a9e66f22406799e904ccb91c3ab4&redirect_uri=http://54.243.163.24/instagram_oauth.php&response_type=code
    User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36
    
    Query String Parameters
    
    client_id:63a3a9e66f22406799e904ccb91c3ab4
    redirect_uri:http://54.243.163.24/instagram_oauth.php
    response_type:code

    Form Data
    
    csrfmiddlewaretoken:42215b2aa4eaa8988f87185008b4beac
    allow:Authorize
    
	 */
    public function loginAndAuthorizeApp( ){
        $this->purgeCookies();
        
        $response = $this->login();
        
        $ptrn = '/Authorization Request/';
        if( preg_match( $ptrn, $response ) ){
            // we are at the authorize page
            $response = $this->authorizeApp($response);
        }
    }
    
    public function authorizeApp( $authPageHtml ){
        
        $ptrn = '/<form.*?action="(.+?)"/';
        preg_match($ptrn, $authPageHtml, $matches);
        $formActionUrl = 'https://instagram.com'.$matches[1];
        
        $ptrn = '/name="csrfmiddlewaretoken" value="(.+?)"/';
        preg_match($ptrn, $authPageHtml, $matches);
        $csrfmiddlewaretoken = $matches[1];

        $responseType = 'code';
        
        $args = array(
            'csrfmiddlewaretoken' => $csrfmiddlewaretoken,
            'allow' => 'Authorize',
        );
        
        $headers = array(
            'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            "Referer: $formActionUrl",
            'Origin: https://instagram.com',
        );
        $response = $this->post( $formActionUrl, $args, false, $headers);
        // print_r( array( $url, $args, $response)  ); exit;
        return $response;
    }
    
    public function login(){
        
        $redirectUri = 'https://api.instagram.com/oauth/authorize/';
        $params = array(
            'client_id' => '9d836570317f4c18bca0db6d2ac38e29',
            'redirect_uri' => 'http://web.stagram.com/',
            'response_type' => 'code',
            'scope' => 'likes comments relationships',
        );
        $response = $this->get( $redirectUri, $params );
           
        // now we should have the login form
        // so we login and make sure we are logged in
        $ptrn = '/name="csrfmiddlewaretoken" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $csrfmiddlewaretoken = $matches[1];
        
        // <form method="POST" id="login-form" class="adjacent" action="/accounts/login/?next=/oauth/authorize/%3Fclient_id%3D63a3a9e66f22406799e904ccb91c3ab4%26redirect_uri%3Dhttp%3A//54.243.163.24/instagram_oauth.php%26response_type%3Dcode"
        $ptrn = '/<form .*? action="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $formActionUrl = 'https://instagram.com'.$matches[1];
        
        $args = array(
            'csrfmiddlewaretoken' => $csrfmiddlewaretoken,
            'username' => $this->persona->instagram->username,
            'password' => $this->persona->instagram->password
        );
        
        $headers = array(
            'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Referer: https://instagram.com/accounts/login/',
            'Origin: https://instagram.com',
        );
        //print_r(  array( $response, $args, $headers ) ); exit;
        
        $response = $this->post( $formActionUrl, $args, false, $headers );
        
        //print_r( array( $formActionUrl, $args, $response)  ); exit;
        
        return $response;
    }
    
    /**
     * login and authorize the app
     * 
     * then get the tag array appropriate for this type of persona
     * 
     * we collect up to 5 posts for the tag
     * 
     * when collecting
     * 		we hit the tag page
     * 		get all of the ids from the page
     * 		and for each id check the db to see if we have commented on this before
     * 		we also check to see if we have commented on this user in the last week
     *		if either condition is true, we DO NOT comment
     *		then we put the id in an array
     *		as soon as we have 5 items or have gone throu 2 pages we return the array and comment on each item
     *
     * 
     * when we have the 5 items or less
     * we comment on each item and we sleep for 5 seconds
     * 
     * when we are dome with the tag we sleep for 7 minutes
     * 
     */
    
    public function browseTags(){
        $taggedIds = $this->getTaggedIds( );
        foreach( $taggedIds as $tag => $ids ){
            foreach( $ids as $id ){
                $this->submitComment( $id );
                $sleep = 5;
                echo "submitted comment - sleeping for $sleep seconds\n";
                sleep($sleep);
            }
            $sleep = 120;
            echo "completed tag $tag - sleeping for $sleep seconds\n";
            sleep($sleep);
        }
    }
    
    public function getTaggedIds( ){
        $tags = $this->persona->getTags();
        shuffle($tags);
        $tags = array_slice( $tags, 0, 2 );
        $taggedIds = array();
        foreach( $tags as $tag ){
            $ids = $this->getIdsForTag($tag, 2);
            $taggedIds[ $tag ] = array();
            foreach( $ids as $id ){
                if( count( $taggedIds[ $tag ] ) < 5 && $this->canPing( $id ) ){
                    $taggedIds[ $tag ][] = $id;
                }
            }
        }
        // print_r( $taggedIds ); exit;
        return $taggedIds;
    }
    
    public function getIdsForTag( $tag, $iterations = 1 ){
        $ids = array();
        $pageUrl = "http://web.stagram.com/tag/$tag";
        for( $n = 0; $n < $iterations; $n++ ){
            $response = $this->get( $pageUrl );
            // here we ensure that we are logged in still
            // $this->handleLogin( $response );
            //print_r( $this->isLoggedIn($response ) ); exit;
            
            // type="image" name="comment__166595034299642639_37459491"
            $ptrn = '/type="image" name="comment__(.+?)"/';
            preg_match_all($ptrn, $response, $matches);
            if( isset( $matches[1] ) ){
                array_splice( $ids, count( $ids ),  0, $matches[1] );
            }
            
            $sleep = 2;
            echo "sleeping for $sleep seconds\n";
            sleep( $sleep );
        }
        $ids = array_unique( $ids );
        // print_r( array($ids, $tag) );exit;
        return $ids;
    }
    
    public function canPing( $id ){
        $canPing = false;
        list( $imageId, $userId ) = explode( '_', $id, 2 );
        if( $imageId && $userId ){
            $dao = new BIM_DAO_Mysql_Growth_Webstagram( BIM_Config::db() );
            $timeSpan = 86400 * 7;
            $currentTime = time();
            $lastContact = $dao->getLastContact( $userId );
            if( ($currentTime - $lastContact) >= $timeSpan ){
                $canPing = true;
            }
        }
        return $canPing;
    }
    
    public function isLoggedIn( $html ){
        $ptrn = '@LOG OUT</a>@';
        return preg_match($ptrn, $html);
    }
    
    public function submitComment( $id ){
        $message = $this->persona->getVolleyQuote();
        $params = array(
            'message' => $message,
            'messageid' => $id,
            't'=> 5069
        );
        print_r( $params );
        $response = $this->post( 'http://web.stagram.com/post_comment/', $params);
        $response = json_decode( $response );
        print_r( $response );
        if( $response ){
            $dao = new BIM_DAO_Mysql_Growth_Webstagram( BIM_Config::db() );
            list( $imageId, $userId ) = explode('_', $id, 2 );
            $dao->updateLastContact( $userId, time() );
            $dao->logSuccess($id, $message, $this->persona->instagram->name );
        }
    }
}
