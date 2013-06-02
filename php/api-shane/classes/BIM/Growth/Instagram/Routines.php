<?php

class BIM_Growth_Instagram_Routines extends BIM_Growth_Instagram{
    
    protected $persona = null;
    protected $oauth = null;
    protected $oauth_data = null;
    
    public function __construct( $persona ){
        $this->persona = $persona;
        
        $this->conf = BIM_Config::instagram();
        $clientId = $this->conf->api->client_id;
        $clientSecret = $this->conf->api->client_secret;
        
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
        unlink( $this->getCookieFileName() );
        
        $response = $this->login();
        $authData = json_decode( $response );
        if( !$authData ){
            // we are at the authorize page
            $response = $this->authorizeApp($response);
        }
        
        $authData = json_decode( $response );
        $authData->accessToken = $authData->access_token;
        unset( $authData->access_token ); // removing this as it is not camel case
        $authData->username = $this->persona->instagram->username;
        $authData->password = $this->persona->instagram->password;
        $this->persona->instagram = $authData;
        
    }
    
    public function authorizeApp( $authPageHtml ){
        $clientId = $this->conf->api->client_id;
        $redirectUri = $this->conf->api->redirect_url;
        
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
        
        $encRedirectUri = urlencode($redirectUri);

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
        
        $clientId = $this->conf->api->client_id;
        $redirectUri = $this->conf->api->redirect_url;
        $response = $this->get( $redirectUri );
        //print_r( $response ); exit;
           
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

        $response = $this->post( $formActionUrl, $args, false, $headers );
        # print_r( array( $formActionUrl, $args, $response)  ); exit;
        
        return $response;
    }
    
    public function modRelationship( $userId, $params ){
        $params['access_token'] = $this->persona->instagram->accessToken;
        $iclient = new BIM_API_Instagram( $this->conf->api );
        $method = "/users/$userId/relationship";
        //$response = $iclient->call( $method, $params, 'json', true, 'POST' );
        //print_r( $response ); exit;
        $response = $iclient->call( $method, $params, 'json', false, 'POST' );
        return $response;
    }
    
    public function unfollow( $user ){
        $params = array(
            'action' => 'unfollow',
        );
        return $this->modRelationship( $user->id, $params );
    }
    
    public function follow( $user ){
        $params = array(
            'action' => 'follow',
        );
        return $this->modRelationship( $user->id, $params );
    }
    
    /**
     * 
     * retrieve the persona object's followers and followees
     * foreach user retrieve the latest photo and send a comment
     * 
     */
    public function volleyUserPhotoComment(){
        $this->loginAndAuthorizeApp();
        $this->commentOnFollowerPhotos();
        $this->commentOnFollowingPhotos();
    }
    
    public function commentOnFollowingPhotos(){
        $params = array( 'access_token' => $this->persona->instagram->accessToken );
        $api = $this->getInstagramApiClient();
        $following = $api->getFollowing( $this->persona->instagram->user->id, $params );
        //file_put_contents( '/tmp/following', print_r($following,true), FILE_APPEND );
        //$comment = "nice pic";
        //$this->commentOnLatestPicForUsers( $following, $comment, $params );
    }
    
    public function commentOnFollowerPhotos(){
        $params = array( 'access_token' => $this->persona->instagram->accessToken );
        $api = $this->getInstagramApiClient();
        $followers = $api->getFollowers( $this->persona->instagram->user->id, $params );
        //file_put_contents( '/tmp/followers', print_r($followers,true), FILE_APPEND );
        //$comment = "nice pic";
        //$this->commentOnLatestPicForUsers( $followers, $comment, $params );
    }

    protected function commentOnLatestPicForUsers( $users, $comment, $params ){
        $api = $this->getInstagramApiClient();
        foreach( $users as $user ){
            $api->commentOnLatestPic( $user, $comment, $params );
        }
    }
    
    public function comment( $comment, $media ){
        $params = array( 'access_token' => $this->persona->instagram->accessToken, 'text' => $comment );
        $iclient = new BIM_API_Instagram( $this->conf->api );
        $method = "/media/$media->id/comments";
        $response = $iclient->call( $method, $params, 'json', false, 'POST' );
        return $response;
    }
    
    public function getFollowing( $user ){
        $params = array( 'access_token' => $this->persona->instagram->accessToken );
        $iclient = new BIM_API_Instagram( $this->conf->api );
        $method = "/users/$user->id/follows";
        $response = $iclient->call( $method );
        return $response;
    }
    
    /**
     * retrieve all selfies and put them 
     * in a db keyed by the objectId
     * 
     * we go int seconds into the past
     * we store the whole blob for use later
     * 
     * starting with now() we itearte until the timestamp 
     * of the last item of a fetch is smaller than the 
     * timestamp in the config or until we retrieve 0 selfies
     * 
     */
    public function harvestSelfies(){
        $c = BIM_Config::tumblr();
        $q = new Instagram\API\Client($c->api->consumerKey, $c->api->consumerSecret);
        
        $maxItems = $c->harvestSelfies->maxItems;
        $n = 1;
        $itemsRetrieved = 0;
        foreach( $c->harvestSelfies->tags as $tag ){
            echo "gathering posts for tag '$tag'\n";
            $before = time();
            $minTime = $before - $c->harvestSelfies->secsInPast;
            
            $options = array( 'before' => $before );
            $selfies = $q->getTaggedPosts( $tag, $options );
            while( $selfies && ($before >= $minTime) && $itemsRetrieved <= $maxItems ){
                $itemsRetrieved += count( $selfies );
                echo "got $itemsRetrieved items in $n pages\n";            
                foreach( $selfies as $selfie ){
                    $this->saveSelfie($selfie);
                    if( $selfie->timestamp < $before ){
                        $before = $selfie->timestamp;
                    }
                }
                $n++;
                $options['before'] = $before;
                $selfies = $q->getTaggedPosts( $tag, $options );
            }
        }
    }
    
    public function saveSelfie( $selfie ){
        $db = new BIM_DAO_Mysql( BIM_Config::db() );
        
        $json = json_encode( $selfie );
        $timestamp = $selfie->timestamp;
        $params = array( $selfie->id, $timestamp, $json, $json, $timestamp );
        
        $sql = "
        	insert into tumblr_selfies 
        	(`id`,`time`,`data`) values(?,?,?) 
        	on duplicate key update `data` = ?, `time` = ?
        	";
        $db->prepareAndExecute( $sql, $params, true );
    }
}
