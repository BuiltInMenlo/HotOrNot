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
        $this->login();
        $this->browseSelfies();
    }
    
	/**
	 * oauth_token=6DB4hFn3rfhu72F6h6eGaANn6FYFSdfeIbOY74ic2wUH196GtT
	 * input type="hidden" name="form_key" value="!1231369675784|eYlf6FoNjc0vyXVkMWKKyenrNFU"
	 */
    public function login( ){
        
        $this->purgeCookies();
                
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
        
        //print_r( array( $response, "$authUrl?oauth_token=$oauthToken", $input, $loggedIn ) ); exit;
        
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
        $posts = $this->getSelfies(10);
        //$posts = $this->oauth->getBlogPosts('fargobauxn.tumblr.com');
        $sleep = 1;
        foreach( $posts as $post ){
            $parts = parse_url($post->post_url);
            $blogUrl = $parts['scheme'].'://'.$parts['host'].'/';
            if( !$this->isFollowing( $blogUrl ) ){
                $this->log( $post->post_url );
                echo( "sleeping for $sleep secs\n" );
                sleep( $sleep );
                /*$this->oauth->follow( $blogUrl );
                $comment = $this->persona->getVolleyQuote();
                $options = array('comment' => $comment );
                $this->oauth->reblogPost( $this->persona->tumblr->blogName, $post->id, $post->reblog_key, $options ); */
            }
        }
    }
    
    public function log( $data ){
        file_put_contents('/tmp/persona_log', print_r($data,1)."\n", FILE_APPEND);
    }
    
    public function getSelfies( $maxItems ){
        $c = BIM_Config::tumblr();
        $q = new Tumblr\API\Client($c->api->consumerKey, $c->api->consumerSecret);
        $allSelfies = array();
        $n = 0;
        $itemsRetrieved = 0;
        $options = array( 'limit' => $maxItems );
        foreach( $c->harvestSelfies->tags as $tag ){
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
            if( $itemsRetrieved >= $maxItems){
                break;
            }
        }
        return $allSelfies;
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
    
}
