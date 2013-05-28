<?php

class BIM_Growth_Instagram_Routines extends BIM_Growth_Instagram{
    
    protected $persona = null;
    protected $oauth = null;
    protected $oauth_data = null;
    
    public function __construct( $persona ){
        $this->persona = $persona;
        
        $conskey = 'TXB9fZ1LMYthFd8ZPTjV0qRKesFsKo6GIDPG3deOTmtAxxSO6L';
        $conssec = 'oPos1EyfSnNDgfo7KLmH0I4PhMUNhHCGHLQZA2VJw4dEwUfzuh';
        $this->oauth = new OAuth($conskey,$conssec);
        $this->oauth->enableDebug();
    }
    
	/**
	 * oauth_token=6DB4hFn3rfhu72F6h6eGaANn6FYFSdfeIbOY74ic2wUH196GtT
	 * input type="hidden" name="form_key" value="!1231369675784|eYlf6FoNjc0vyXVkMWKKyenrNFU"
	 */
    public function login( ){
        
        $loggedIn = false;
        
        // first we attempt to access our oauth script
        // and we get the oauth_token and the form_key from the response
        $response = $this->get( 'http://54.243.163.24/instagram_oauth.php' );
        
        $ptrn = '/name="form_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $formKey = $matches[1];
        
        $ptrn = '/oauth_token=(.+?)\b/';
        preg_match($ptrn, $response, $matches);
        $oauthToken = $matches[1];
        
        $ptrn = '/type="hidden" name="recaptcha_public_key" value="(.+?)"/';
        preg_match($ptrn, $response, $matches);
        $recapPubKey = $matches[1];
        
        $redirect_to = "http://www.instagram.com/oauth/authorize?oauth_token=$oauthToken";
        
        $input = array(
            'user[email]' => $this->persona->instagram->email,
            'user[password]' =>  $this->persona->instagram->password,
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
                
        $response = $this->post('https://www.instagram.com/login', $input, true);
        
        if( isset( $response['headers']['Set-Cookie'] ) && preg_match('/logged_in=1/', $response['headers']['Set-Cookie'] ) ){
            $loggedIn = true;
        }
        
        $input = array(
            'form_key' => $formKey,
            'oauth_token' => $oauthToken,
            'allow' => ''
        );
        
        $response = $this->post("http://www.instagram.com/oauth/authorize?oauth_token=$oauthToken", $input);
        
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
        
        $response = $this->post("http://www.instagram.com/oauth/authorize?oauth_token=$oauthToken", $input );
        
        $this->oauth_data = $response = json_decode($response);
        $this->oauth->setToken( $response->oauth_token, $response->oauth_token_secret);
        
        
    }
    
    public function followUser( $user ){
        //$url = "http://api.instagram.com/v2/blog/exty86.instagram.com/post";
        //$params = array('type'=>'text', 'body'=>'This is a test post');
        $url = "http://api.instagram.com/v2/user/follow";
        
        $params = array( 'url' => $user->blogUrl );
        
        //Post text 'This is a test post' to user's Instagram
        $this->oauth->fetch($url, $params, OAUTH_HTTP_METHOD_POST);
        
        //Print out Instagram's response
        $json = json_decode($this->oauth->getLastResponse());
        print_r($json);
    }
}
