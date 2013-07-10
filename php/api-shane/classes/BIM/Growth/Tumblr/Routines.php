<?php

class BIM_Growth_Tumblr_Routines extends BIM_Growth_Tumblr {
    protected $persona = null;
    protected $oauth = null;
    protected $oauth_data = null;
    protected $conf = null;
    
    public function __construct( $persona ){
        if( is_string( $persona )  ){
            $persona = new BIM_Growth_Persona( $persona );
        } 
        $this->persona = $persona;
        
        $this->conf = $c = BIM_Config::tumblr();
        $this->oauth = new Tumblr\API\Client($c->api->consumerKey, $c->api->consumerSecret);
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
        $formKey = $matches[1];
        
        $ptrn = '/name="oauth_token" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $oauthToken = $matches[1];
        
        $input = array(
            'form_key' => $formKey,
            'oauth_token' => $oauthToken,
            'allow' => ''
        );
        
        $response = $this->post("$authUrl?oauth_token=$oauthToken", $input );
        
        $this->oauth_data = $response = json_decode($response);
        $this->oauth->setToken( $response->oauth_token, $response->oauth_token_secret);
        
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
        $response = $this->get(  $urls->oauth->callback );
        
        $this->oauth_data = $response = json_decode($response);
        
        if( ! $response ){
            
            $ptrn = '/name="form_key" value="(.+?)"/';
            preg_match($ptrn, $response, $matches);
            if( !empty( $matches[1] ) ){
                $formKey = $matches[1];
                
                $ptrn = '/name="oauth_token" value="(.+?)"/';
                preg_match($ptrn, $response, $matches);
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
                $parts = parse_url($post->post_url);
                $blogUrl = $parts['scheme'].'://'.$parts['host'].'/';
                if( mt_rand(1, 100) <= 10 ){
                    $this->oauth->follow( $blogUrl );
                }
                $options = array('comment' => $comment );
                $success = $this->oauth->reblogPost( $this->persona->getTumblrBlogName(), $post->id, $post->reblog_key, $options ); 
                if( $success ){
                    $this->logSuccess( $post, $comment );
                    $this->updateLastContact( $blogUrl );
                }
                echo( "sleeping for $sleep secs\n" );
                sleep( $sleep );
            }
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
        $c = BIM_Config::tumblr();
        $ct = count( $c->harvestSelfies->tags );
        $idx = mt_rand(0, $ct - 1);
        return $c->harvestSelfies->tags[$idx];
    }
    
    public function getFollowedBlogs(){
        $blogs = array();
        $following = $this->oauth->getFollowedBlogs();
        while( count( $following ) ){
            foreach( $following->blogs as $blog ){
                $blogs[] = $blog;
            }
            $following = $this->oauth->getFollowedBlogs();
        }
        return $blogs;
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
            $this->login();
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
}
