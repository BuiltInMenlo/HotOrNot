<?php

class BIM_Growth_Instagram_Routines extends BIM_Growth_Instagram{
    
    /**
csrfmiddlewaretoken	e52313fcc1d0119235ec8bea8aef6346
first_name	Chloe
email	app12@gmail.com
username	chloe1999xoxo
phone_number	
gender	2
biography	HMU on kik for a invite to Volley. Kik: PrettyLittleLiarSwag - ill follow back :) tap my link in my bio to trade pics!

http://getvolleyapp.com/b/b
external_url	http://www.letsvolley.com
     * 
     */
    
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
        // $this->purgeCookies();
        
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
        
        print_r( $this->persona );
        
    }
    
    public function authorizeApp( $authPageHtml ){
        $clientId = $this->instagramConf->api->client_id;
        $redirectUri = $this->instagramConf->api->redirect_url;
        
        $ptrn = '/<form.*?action="(.+?)"/';
        preg_match($ptrn, $authPageHtml, $matches);
        $formActionUrl = 'https://instagram.com'.$matches[1];
        
        $ptrn = '/name="csrfmiddlewaretoken" value="([^"]+?)"/';
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
    
    /**
     * 
     * first we check to see if we are logged in
     * if we are not then we login
     * and check once more
     * if we still are not logged in, we disable the user
     * 
     */
    public function handleLogin(){
        $loggedIn = true;
        $url = 'http://instagram.com/foo';
        $response = $this->get( $url );
        if( !$this->isLoggedIn($response) ){
            $name = $this->persona->name;
            echo "user $name not logged in to instagram!  logging in!\n";
            $this->login();
            $response = $this->get( $url );
            if( !$this->isLoggedIn($response) ){
                $msg = "something is wrong with logging in $name to instagram!  disabling the user!\n";
                echo $msg;
                $this->disablePersona( $msg );
                $loggedIn = false;
            }
        }
        return $loggedIn;
    }
    
    public function isLoggedIn( $html ){
        $ptrn = '@hl-en logged-in@';
        return preg_match($ptrn, $html);
    }
    
    public function login(){
        $loginUrl = 'https://instagram.com/accounts/login/';
        $response = $this->get( $loginUrl );
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
            "Referer: $loginUrl",
            'Origin: https://instagram.com',
        );

        $response = $this->post( $formActionUrl, $args, false, $headers );
        # print_r( array( $formActionUrl, $args, $response)  ); exit;
        
        return $response;
    }
    
    public function modRelationship( $userId, $params ){
        $params['access_token'] = $this->persona->instagram->accessToken;
        $iclient = new BIM_API_Instagram( $this->instagramConf->api );
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
        //$comment = $this->persona->getVolleyQuote();
        //$this->commentOnLatestPicForUsers( $following, $comment, $params );
    }
    
    public function commentOnFollowerPhotos(){
        $params = array( 'access_token' => $this->persona->instagram->accessToken );
        $api = $this->getInstagramApiClient();
        $followers = $api->getFollowers( $this->persona->instagram->user->id, $params );
        //file_put_contents( '/tmp/followers', print_r($followers,true), FILE_APPEND );
        //$comment = $this->persona->getVolleyQuote();
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
        $iclient = new BIM_API_Instagram( $this->instagramConf->api );
        $method = "/media/$media->id/comments";
        $response = $iclient->call( $method, $params, 'json', false, 'POST' );
        return $response;
    }
    
    public function getFollowing( $user ){
        $params = array( 'access_token' => $this->persona->instagram->accessToken );
        $iclient = new BIM_API_Instagram( $this->instagramConf->api );
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
    
    /**
csrfmiddlewaretoken	e52313fcc1d0119235ec8bea8aef6346
first_name	Chloe
email	app12@gmail.com
username	chloe1999xoxo
phone_number	
gender	2
biography	HMU on kik for a invite to Volley. Kik: PrettyLittleLiarSwag - ill follow back :) tap my link in my bio to trade pics!

http://getvolleyapp.com/b/b
external_url	http://www.letsvolley.com
     */
    public function dropLinkInBio( $link ){
        if( $this->handleLogin() ){
            $this->editProfile( (object) array( 'external_url' => $link ) );
        }
    }
    
    public function editProfile( $data ){
        $editUrl = 'https://instagram.com/accounts/edit/';
        $response = $this->get( $editUrl );
        $matches = array();
        
        $args = array();
        
        // get the middleware token
        $ptrn = '/name="csrfmiddlewaretoken" value="([^"]+?)"/';
        preg_match($ptrn, $response, $matches);
        $args['csrfmiddlewaretoken'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        //<span><input name="first_name" autocorrect="off" value="Shane Hill" maxlength="30" type="text" id="first_name" /></span>
        $ptrn = '/name="first_name".*?value="([^"]+?)"/';
        preg_match($ptrn, $response, $matches);
        $args['first_name'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        //<span><input type="email" name="email" value="shanehill00@gmail.com" id="email" /></span>
        $ptrn = '/name="email".*?value="([^"]+?)"/';
        preg_match($ptrn, $response, $matches);
        $args['email'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        //<span><input name="username" maxlength="30" autocapitalize="off" autocorrect="off" type="text" id="username" value="shanehill00" /></span>
        $ptrn = '/name="username" .*? value="([^"]+?)"/';
        preg_match($ptrn, $response, $matches);
        $args['username'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        //<span><input type="tel" name="phone_number" value="4152549391" id="phone_number" /></span>
        $ptrn = '/name="phone_number".*?value="([^"]+?)"/';
        preg_match($ptrn, $response, $matches);
        $args['phone_number'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        //<span><select name="gender" id="gender">
          //  <option value="3">--------</option>
          //  <option value="1" selected="selected">Male</option>
          //  <option value="2">Female</option>
        $ptrn = '/name="gender".*?value="([^"]+?)" selected="selected"/is';
        preg_match($ptrn, $response, $matches);
        $args['gender'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        //<textarea id="id_biography" rows="10" cols="40" name="biography">this is my bio
        // and some other stuff
        //other stuff</textarea>
        $ptrn = '@name="biography".*?>(.*?)</textarea>@is';
        preg_match($ptrn, $response, $matches);
        $args['biography'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        //<span><input name="external_url" autocorrect="off" value="http://getvolleyapp.com/b/boo" autocapitalize="off" type="url" id="external_url" /></span>
        $ptrn = '/name="external_url" .*? value="([^"]+?)"/';
        preg_match($ptrn, $response, $matches);
        $args['external_url'] = !empty( $matches[1] ) ? $matches[1] : '';
        
        foreach( $data as $name => $value ){
            $args[ $name ] = $value;
        }
        
        $headers = array(
            'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            "Referer: $editUrl",
            'Origin: https://instagram.com',
        );

        //print_r( array( $formActionUrl, $args, $headers  ) );
        $response = $this->post( $editUrl, $args, true, $headers );
        //print_r( $response );
    }
// MarquitaIvaLuc  cZWyJzZCjf
    public static function loadPersonas($filename){
        $fh = fopen($filename, 'rb');
        while( $line = fgets( $fh ) ){
            $values = explode( ':', $line );
            $username = trim( $values[0] );
            $password = trim( $values[1] );
            self::loadUser( $username, $password, 'instagram' );
            $sleep = 10;
            echo "loaded $username sleeping for $sleep seconds\n";
            sleep($sleep);
        }
    }
    
    /**
     * we add the persona
     * then we change the link in bio
     * then we add the gearman job, disabled 
     */
    public static function loadUser( $username, $password, $network ){
        $persona = new BIM_Growth_Persona( $username );
        $persona->username = $username;
        $persona->password = $password;
        $persona->network = $network;
        $persona = $persona->create();

        $r = new self( $persona );
        $r->setUseProxy( false );
        if( $r->handleLogin() ){
            $link = "http://taps.io/MTA5MDAz";
            $r->editProfile( (object) array( 'external_url' => $link ) );
            
            $hr1 = mt_rand(0, 23);
            $hr2 = $hr1 + 1;
        	$schedule = "* $hr1-$hr2 * * *";
        	
            $job = (object) array(
        	    'class' =>  'BIM_Jobs_Growth',
        	    'name' => 'webstagram',
        	    'method' => 'doRoutines',
        	    'disabled' => 1,
        	    'schedule' => $schedule,
                'params' => (object) array(
                    "personaName" => $persona->name, 
                    "routine" => "browseTags",
                    "class" => "BIM_Growth_Webstagram_Routines"
                ),
            );
            
            $j = new BIM_Jobs_Gearman( BIM_Config::gearman() );
            $j->createJbb($job);
        } else {
            file_put_contents('/tmp/websta_failed_users', $persona->instagram->username.",".$persona->instagram->password."\n", FILE_APPEND );
        }
    }
}
