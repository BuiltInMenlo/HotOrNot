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
        //print_r( $authData );
        $this->persona->instagram->accessToken = $authData->access_token;
        
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
}
