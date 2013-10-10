<?php

class BIM_Growth_Tumblr_Routines extends BIM_Growth_Tumblr {
    protected $persona = null;
    protected $oauth = null;
    protected $oauth_data = null;
    protected $conf = null;
    protected $loggingIn = false;
    protected $proxyKey = false;
    
    public function __construct( $persona ){
        if( is_string( $persona )  ){
            $persona = new BIM_Growth_Persona( $persona );
        } 
        $this->persona = $persona;
        
        $this->conf = $c = BIM_Config::tumblr();
        
        $curlOpts = array();
        $proxy = $this->getProxy();
        if( $proxy ){
            $curlOpts = array(
                CURLOPT_PROXY => $proxy->host,
                CURLOPT_PROXYPORT => $proxy->port,
                CURLOPT_HTTPPROXYTUNNEL =>  0,
            );
            
            print_r( array( 'USING PROXY FOR GUZZLE', $curlOpts ) );
        }
        
        $this->oauth = new Tumblr\API\Client($c->api->consumerKey, $c->api->consumerSecret, null, null, $curlOpts );
        
    }

    public function getProxyKey(){
        if( !$this->proxyKey ){
            $this->proxyKey = uniqid();
        }
        return $this->proxyKey;
    }
    
    public function getProxy(){
        if( $this->loggingIn ){
            return BIM_Config::getProxy( $this->getProxyKey() );
        } else {
            return BIM_Config::getProxy();
        }
    }
    
    public function loginAndBrowseSelfies(){
        if( $this->handleLogin() ){
            $this->authorizeApp();
            $this->browseSelfies();
        }
    }
    
	/**
	 * oauth_token=6DB4hFn3rfhu72F6h6eGaANn6FYFSdfeIbOY74ic2wUH196GtT
	 * input type="hidden" name="form_key" value="!1231369675784|eYlf6FoNjc0vyXVkMWKKyenrNFU"
	 */
    public function login( ){
        
        $this->loggingIn = true;
        
        // $this->purgeCookies();
                
        $loggedIn = false;
        
        $urls = $this->conf->urls;
        $callbackUrl = $urls->oauth->callback;
        $loginUrl = $urls->login;
        $authUrl = $urls->oauth->authorize;
        $accUrl = $urls->oauth->access_token;
        
        // first we attempt to access our oauth script
        // and we get the oauth_token and the form_key from the response
        $response = $this->get( $callbackUrl );
        
        $ptrn = '/name="form_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $formKey = $matches[1];
        
        $ptrn = '/oauth_token=(.+?)\b/';
        preg_match($ptrn, $response, $matches);
        $oauthToken = $matches[1];
        
        $ptrn = '/type="hidden" name="recaptcha_public_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $recapPubKey = $matches[1];
        
        $redirect_to = "$authUrl?oauth_token=$oauthToken";
        
        $input = array(
            'user[email]' => $this->persona->tumblr->email,
            'user[password]' => $this->persona->tumblr->password,
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
        
        $response = $this->post( $loginUrl, $input, true);
        
        if( isset( $response['headers']['Set-Cookie'] ) && preg_match('/logged_in=1/', $response['headers']['Set-Cookie'] ) ){
            $loggedIn = true;
        }
        
        $input = array(
            'form_key' => $formKey,
            'oauth_token' => $oauthToken,
            'allow' => ''
        );
        
        $response = $this->post("$authUrl?oauth_token=$oauthToken", $input);

        $ptrn = '/name="form_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $formKey = !empty($matches[1]) ? $matches[1] : '';
        
        $ptrn = '/name="oauth_token" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $oauthToken = !empty($matches[1]) ? $matches[1] : '';
        
        $input = array(
            'form_key' => $formKey,
            'oauth_token' => $oauthToken,
            'allow' => ''
        );
        if( $oauthToken ){
            $response = $this->post("$authUrl?oauth_token=$oauthToken", $input );
            
            $this->oauth_data = $response = json_decode($response);
            $this->oauth->setToken( $response->oauth_token, $response->oauth_token_secret);
        }
        
        $this->loggingIn = false;
        
    }
    
    public function authorizeApp( ){
        $this->doAuthorizeApp();
        if( empty( $this->oauth_data ) ){
            $this->purgeCookies();
            if( $this->handleLogin() ){
                $this->doAuthorizeApp();
            } else {
                $this->sendWarningEmail("cannot authorize app for tumblr for ".$this->persona->username);
            }
        }
    }
    
    protected function doAuthorizeApp( ){
        
        $urls = $this->conf->urls;
        
        // first we attempt to access our oauth script
        // and we get the oauth_token and the form_key from the response
        $responseData = $this->get(  $urls->oauth->callback );
        
        $this->oauth_data = $response = json_decode($responseData);
        
        if( ! $response ){
            
            $ptrn = '/name="form_key" value="(.+?)"/';
            preg_match($ptrn, $responseData, $matches);
            if( !empty( $matches[1] ) ){
                $formKey = $matches[1];
                
                $ptrn = '/name="oauth_token" value="(.+?)"/';
                preg_match($ptrn, $responseData, $matches);
                $oauthToken = $matches[1];
                
                $input = array(
                    'form_key' => $formKey,
                    'oauth_token' => $oauthToken,
                    'allow' => ''
                );
                
                $authUrl = $urls->oauth->authorize;
                $response = $this->post("$authUrl?oauth_token=$oauthToken", $input );
                
                $this->oauth_data = $response = json_decode($response);
            }
        }
        if( $response ){
            $this->oauth->setToken( $response->oauth_token, $response->oauth_token_secret);
        }
    }
    
    public function followUser( $user ){
        //Post text 'This is a test post' to user's Tumblr
        return $this->oauth->follow( $user->blogUrl );
    }

    /**
     * we get 10 selfies
     * then for each selfie
     * we follow the user
     * reblog the post
     * leave a comment
     */
    public function browseSelfies(){
        $posts = $this->getSelfies(1);
        //$posts = $this->oauth->getBlogPosts('fargobauxn.tumblr.com');
        $sleep = 1;
        foreach( $posts as $post ){
            $parts = parse_url($post->post_url);
            $blogUrl = $parts['scheme'].'://'.$parts['host'].'/';
            if( $this->canPing( $blogUrl ) ){
                $comment = $this->persona->getVolleyQuote( 'tumblr' );
                if( mt_rand(1, 100) <= 30 ){
                    $this->oauth->follow( $blogUrl );
                    $this->oauth->like( $post->id, $post->reblog_key );
                }
                $options = array('comment' => $comment );
                $this->reblog($blogUrl, $post, $options);
                echo( "sleeping for $sleep secs\n" );
                sleep( $sleep );
            }
        }
    }
    
    public function reblog( $blogUrl, $post, $options ){
        echo "reblogging $post->post_url\n";
        $success = $this->oauth->reblogPost( $this->persona->getTumblrBlogName(), $post->id, $post->reblog_key, $options ); 
        if( $success ){
            $this->logSuccess( $post, $options['comment'] );
            $this->updateLastContact( $blogUrl );
        }
    }
    
    public function canPing( $blogUrl ){
        // $canPing = ( !$this->isFollowing( $blogUrl ) ) && $this->canContact( $blogUrl );
        $canPing = $this->canContact( $blogUrl );
        return $canPing;
    }
    
    public function canContact( $blogUrl ){
        echo "checking $blogUrl for last contact\n";
        $canContact = false;
        $timeSpan = 86000 * 7;
        $dao = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
        $lastContact = $dao->getLastContact($blogUrl);
        $time = time();
        if( $lastContact == 0 || ($time - $lastContact) >= $timeSpan ){
            $canContact = true;
        }
        return $canContact;
    }
    
    public function updateLastContact( $blogUrl ){
        $dao = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
        $dao->updateLastContact($blogUrl, time() );
    }
    
    public function logSuccess( $post, $comment ){
        $dao = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
        $dao->logSuccess( $post, $comment, 'tumblr', $this->persona->tumblr->name );
    }
    
    public function logError( $post,$comment ){
        // print_r( array($post, $comment)  );
        $delim = '::bim_delim::';
        $line = join( $delim, array( time(), $post->post_url, $post->type, $post->date, $comment ) );
        $line .="\n";
        file_put_contents('/tmp/persona_log_errors', $line, FILE_APPEND);
    }
    
    public function getSelfies( $maxItems ){
        $c = BIM_Config::tumblr();
        $q = new Tumblr\API\Client($c->api->consumerKey, $c->api->consumerSecret);
        $allSelfies = array();
        $n = 0;
        $itemsRetrieved = 0;
        $options = array( 'limit' => $maxItems );
        $tag = $this->getRandomTag( );
        $n++;
        $selfies = $q->getTaggedPosts( $tag, $options );
        $itemsRetrieved += count( $selfies );
        echo "got $itemsRetrieved items in $n pages\n";
        foreach( $selfies as $selfie ){
            $allSelfies[] = $selfie;
        }
        while( $selfies && $itemsRetrieved < $maxItems ){
            $n++;
            $selfies = $q->getTaggedPosts( $tag, $options );
            $itemsRetrieved += count( $selfies );
            echo "got $itemsRetrieved items in $n pages\n";
            foreach( $selfies->posts as $selfie ){
                $allSelfies[] = $selfie;                    
            }
        }
        return $allSelfies;
    }
    
    public function getRandomTag(){
        $tags = $this->persona->getTags('tumblr');
        return array_rand( $tags );
    }
    
    public function isFollowing( $blogUrl ){
        $following = false;
        $blogs = $this->oauth->getFollowedBlogs();
        foreach( $blogs->blogs as $blog ){
            if( $blog->url == $blogUrl ){
                $following = true;
                break;
            }
        }
        return $following;
    }
    
    public function getUserInfo(){
        return $this->oauth->getUserInfo();
    }
    
    /**
     *  update the users stats that we use to guage the effectiveness of our auto outreach
     *  
     *  we get the following for tumblr
     *  
     *  	total followers  getBlogFollowers
     *      total following getFollowedBlogs()
     *  	total likes getBlogLikes()
     *  	
     */
    public function updateUserStats(){
        if( $this->handleLogin() ){
            $this->authorizeApp();
            $blogName = $this->persona->tumblr->blogName;
            $followers = $this->oauth->getBlogFollowers( $blogName );
            $following = $this->oauth->getFollowedBlogs( );
            $likes = $this->oauth->getBlogLikes( $blogName );
            
            $userStats = (object) array(
                'followers' => $followers->total_users,
                'following' => $following->total_blogs,
                'likes' => $likes->liked_count,
                'network' => 'tumblr',
                'name' => $this->persona->name,
            );
            
            print_r( $userStats );
            
            $dao = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
            $dao->updateUserStats( $userStats );
        }
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
        $url = 'http://tumblr.com';
        $response = $this->get( $url );
        if( !$this->isLoggedIn($response) ){
            $name = $this->persona->name;
            echo "user $name not logged in to tumblr!  logging in!\n";
            if( $this->needTOS( $response ) ){
                $this->acceptTOS($response);
            }
            $this->login();
            $response = $this->get( $url );
            if( $this->needTOS( $response ) ){
                $this->acceptTOS($response);
            }
            $response = $this->get( $url );
            if( !$this->isLoggedIn($response) ){
                $msg = "something is wrong with logging in $name to tumblr!  disabling the user!\n";
                echo $msg;
                $this->disablePersona( $msg );
                $loggedIn = false;
            }
        }
        return $loggedIn;
    }
    
    public function needTOS( $response ){
        return preg_match('@updated our Terms of Service@',$response );
    }
    
    /*
		http://www.tumblr.com/svc/policy/accept
		
		form_key:nJHu0eei2DMVIRIIgZsU9wSsE
		
        {
            "meta": {
                "status": 200,
                "msg": "OK"
            },
            "response": {
                "message": "OK"
            }
        }
     */
    public function acceptTOS( $response ){
        echo "accepting TOS\n";
        
        $ptrn = '/name="form_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $formKey = $matches[1];
        
        $url = 'http://www.tumblr.com/svc/policy/accept';
        
        $input = array(
            'form_key' => $formKey,
        );
        
        $response = json_decode( $this->post( $url, $input ) );
        
        if( $response ){
            print_r( $response );
        }
    }
    
    public function isLoggedIn( $html ){
        $ptrn = '@log in@i';
        return !preg_match($ptrn, $html);
    }
    
    public static function callback(){
        
        $conf = BIM_Config::tumblr();
        //Tumblr API urls
        $reqUrl = $conf->urls->oauth->request_token;
        $authUrl = $conf->urls->oauth->authorize;
        $accUrl = $conf->urls->oauth->access_token;
        $callbackUrl = $conf->urls->oauth->callback;
        
        //Your Application key and secret, found here: http://www.tumblr.com/oauth/apps
        $conskey = $conf->api->consumerKey;
        $conssec = $conf->api->consumerSecret;
         
        //Enable session.  We will store token information here later
        session_start();
         
        // state will determine the point in the authorization request our user is in
        // In state=1 the next request should include an oauth_token.
        // If it doesn't go back to 0
        if(!isset($_GET['oauth_token']) && (!isset( $_SESSION['state'] ) || $_SESSION['state']==1) ) $_SESSION['state'] = 0;
        try {
         
          //create a new Oauth request.  By default this uses the HTTP AUTHORIZATION headers and HMACSHA1 signature required by Tumblr.  More information is in the PHP docs
          $oauth = new OAuth($conskey,$conssec);
          $oauth->enableDebug();
         
          //If this is a new request, request a new token with callback and direct user to Tumblrs allow/deny page
          if(!isset($_GET['oauth_token']) && !$_SESSION['state']) {
            $request_token_info = $oauth->getRequestToken($reqUrl, $callbackUrl);
            $_SESSION['oauth_token_secret'] = $request_token_info['oauth_token_secret'];
            $_SESSION['state'] = 1;
            header('Location: '.$authUrl.'?oauth_token='.$request_token_info['oauth_token']);
            exit;
         
          //If this is a callback from Tumblr's allow/deny page, request the auth token and auth token secret codes and save them in session
          } else if($_SESSION['state']==1) {
            $oauth->setToken($_GET['oauth_token'],$_SESSION['oauth_token_secret']);
            $access_token_info = $oauth->getAccessToken($accUrl);
            $_SESSION['state'] = 2;
            $_SESSION['oauth_token'] = $access_token_info['oauth_token'];
            $_SESSION['oauth_token_secret'] = $access_token_info['oauth_token_secret'];
            
            echo json_encode( $access_token_info );
            exit;
          } 
        } catch(OAuthException $E) {
          print_r($E);
        }
        echo json_encode( $_SESSION );
        exit;
    }
    
	/**
	 * we receive the username and password of the tumblr user
	 * login as the user
	 * get a list of their friends
	 * then for each friend we get the latest photo
	 * and drop a volley comment
	 */
    public function invite(){
        if($this->handleLogin()){
            $this->authorizeApp();
            $this->postText();
            $blogs = $this->getFollowedBlogs( 100 );
            foreach( $blogs as $blog ){
                if( $blog->name != 'staff' && $this->canPing( $blog->url) ){
                    $this->commentOnLatestPost( $blog );
                }
            }
        }
    }
    
    public function postText( $msg = '' ){
        $msg = trim( $msg );
        if( !$msg ){
            $msg = $this->persona->getVolleyQuote();
        }
        $options = array(
            'type' => 'text',
            'body' => $msg
        );
        
        $this->oauth->createPost( $this->persona->getTumblrBlogName(), $options );
        
    }
    
    public function postLink( $link ){
        
        $options = array(
            'type' => 'link',
            'url' => $link,
        );
        
        $this->oauth->createPost( $this->persona->getTumblrBlogName(), $options );
        
    }
    
    public function commentOnLatestPost( $blog ){
        $parts = parse_url($blog->url);
        $posts = $this->oauth->getBlogPosts( $parts['host'] );
        if( $posts->posts ){
            $post = $posts->posts[0];
            $options = array('comment' => "HMU on Volley!" );
            $this->reblog($blog->url, $post, $options);
            $sleep = 10;
            echo "reblogged $blog->url - sleeping for $sleep seconds\n";
            sleep( $sleep );
        }
    }
    
    
    public function getFollowedBlogs( $max = 1 ){
        $followeeTotal = 0;
        $followedBlogs = array();
        
        $options = array(
            'offset' => $followeeTotal,
            'limit' => $max < 20 ? $max : 20
        );
        $blogs = $this->oauth->getFollowedBlogs($options);
        while( $followeeTotal < $max && $blogs->blogs ){
            array_splice($followedBlogs, count( $followedBlogs ), 0, $blogs->blogs );
            $options['offset'] = $followeeTotal += $blogs->total_blogs;
            $blogs = $this->oauth->getFollowedBlogs( $options );
        }
        return $followedBlogs;
    }

    public static function checkPersonas($filename){
        $fh = fopen($filename, 'rb');
        while( $line = fgets( $fh ) ){
            $values = explode( ',', $line );
            $username = trim( $values[0] );
            $password = trim( $values[1] );
            self::checkPersona($username, $password);
            $sleep = 10;
            echo "loaded $username sleeping for $sleep seconds\n";
            sleep($sleep);
        }
    }
    
    public static function checkPersona( $username, $password ){
        
        $persona->tumblr = (object) array(
            'email' => $username,
        	'username' => $username,
            'password' => $password
        );
        $persona->name = $username;
        $persona->type = 'auth';
        
        $persona = new BIM_Growth_Persona( $persona );
        $r = new self( $persona );
        
        if( !$r->handleLogin() ){
            echo "invalid account: $username,$password\n";
        } else {
            echo "valid account: $username,$password\n";
        }
    }
        
    public static function loadPersonas($filename){
        $fh = fopen($filename, 'rb');
        while( $line = fgets( $fh ) ){
            $values = explode( ',', $line );
            $username = trim( $values[0] );
            $password = trim( $values[1] );
            self::loadUser( $username, $password, 'tumblr' );
            $sleep = 10;
            echo "loaded $username sleeping for $sleep seconds\n";
            sleep($sleep);
        }
    }
    
    /**
     * we add the persona
     * then we change the link in bio
     * then we add the gearman job, disabled 
     * 
{"personaName":"beresalexis", "routine":"loginAndBrowseSelfies","class":"BIM_Growth_Tumblr_Routines"}
     * 
     */
    public static function loadUser( $username, $password, $network ){
        $persona = new BIM_Growth_Persona( $username );
        
        $persona->email = $username;
        $persona->username = $username;
        $persona->password = $password;
        $persona->network = $network;
        
        $persona = $persona->create();
        
        $r = new self( $persona );
        
        if( $r->handleLogin() ){
            $blogName = $r->getUserInfo();
            
            $blogName = $blogName->user->blogs[0]->name.'.tumblr.com';
            $update = (object) array( 'extra' => (object) array( "blogName" => $blogName ) );
            
            $persona->update('tumblr', $update);
            
            $hr1 = mt_rand(0, 23);
        	$schedule = "* $hr1 * * *";
            
        	$job = (object) array(
        	    'class' =>  'BIM_Jobs_Growth',
        	    'name' => 'growth',
        	    'method' => 'doRoutines',
        	    'disabled' => 1,
        	    'schedule' => $schedule,
                'params' => array(
                    "personaName" => "$persona->name", 
                    "routine" => "loginAndBrowseSelfies",
                    "class" => "BIM_Growth_Tumblr_Routines"
                ),
            );
            
            print_r( $job );
            
            $j = new BIM_Jobs_Gearman( BIM_Config::gearman() );
            $j->createJbb($job);
            
            /**
            
            $hr = mt_rand(0, 23);
            $job = (object) array(
        	    'class' =>  'BIM_Jobs_Growth',
        	    'name' => 'update_user_stats',
        	    'method' => 'doRoutines',
        	    'disabled' => 1,
        	    'schedule' => "0 $hr * * *",
                'params' => array(
                    "personaName" => "$persona->name", 
                    "routine" => "updateUserStats",
                    "class" => "BIM_Growth_Tumblr_Routines"
                ),
            );
            $j->createJbb($job);
            */
        }
    }
    
    public static function getRichKids(){
        $g = new BIM_Growth();
        $richKidLink = 'http://richkidsofinstagram.tumblr.com/page/73';
        $dao = new BIM_DAO_Mysql( BIM_Config::db() );
        
        while( $richKidLink ){
            $response = $g->get( $richKidLink );
            
            $ptrn = '@<div class="postbody photo">.*?(http://instagram.com/p/[^/<>]+?/)" target="_blank">([^/]+?)</a>@is';
            $matches = array();
            preg_match_all($ptrn,$response,$matches);
            if( isset($matches[1]) ){
                foreach( $matches[1] as $index => $link ){
                    $name =  $matches[2][$index];
                    $sql = "insert ignore into growth.rkoi (link,name) values (?,?)";
                    $params = array( $link, $name );
                    $dao->prepareAndExecute($sql,$params);
                }
            }
            
            // now we get the next link
            $ptrn = '@<a href="(.+?)" class="next"><span class="next">Next page</span></a>@';
            preg_match($ptrn, $response, $matches);
            $richKidLink = null;
            if( isset( $matches[1] ) ){
                $richKidLink = "http://richkidsofinstagram.tumblr.com".$matches[1];
            }
            
            if( $richKidLink ){
                sleep(2);
                echo "getting $richKidLink\n";
            }
        }
    }
}
