<?php 
class BIM_Utils{
    
    protected static $user = null;
    protected static $request = null;
    protected static $adid = null;
    protected static $deviceToken = null;
    
    public static function hashMobileNumber( $number ){
        $c = BIM_Config::sms();
        if( !empty($c->useHashing) ){
            $number = self::blowfishEncrypt($number);
        }
        return $number;
    }
    
    public static function blowfishEncrypt( $number ){
        $c = BIM_Config::sms();
        $iv = base64_decode($c->blowfish->b64iv);
        $enc = base64_encode( mcrypt_encrypt( MCRYPT_BLOWFISH, $c->blowfish->key, $number, MCRYPT_MODE_CBC, $iv ) );
        return $enc;
    }
    
    public static function blowfishDecrypt( $encrptedNumber ){
        $c = BIM_Config::sms();
        $iv = base64_decode($c->blowfish->b64iv);
        $dec = mcrypt_decrypt( MCRYPT_BLOWFISH, $c->blowfish->key, base64_decode( $encrptedNumber ), MCRYPT_MODE_CBC, $iv );
        return $dec;
    }
    
    public static function getRequest(){
        if( ! self::$request ){
            $c = BIM_Config::app();
            $cdata = trim(str_replace( $c->base_path, '', $_SERVER['SCRIPT_URL'] ),'/');
            
            $cdata = explode( '/', $cdata );
            
            $controller = ucfirst( trim($cdata[0],'/') );
            $controller = str_replace('.php', '', $controller);
            $method = isset( $cdata[1] ) ? trim( $cdata[1], '/' ) : '';
            
            $controllerClass = "BIM_Controller_$controller";
            
            if( !$method ){
                $input = (object) ( $_POST ? $_POST : $_GET );
                $actionMethods = BIM_Config::actionMethods();
                $method = !empty( $input->action ) && !empty( $actionMethods[ $controllerClass ][$input->action] ) ? $actionMethods[ $controllerClass ][$input->action] : null;
            }
            
            self::$request = (object) array(
                'controllerClass' => $controllerClass,
                'method' => $method
            );
        }
        
        return self::$request;
    }
    
    public static function getSMSCodeForId( $id ){
        $c = BIM_Config::sms();
		$smsCodeB64 = base64_encode( mcrypt_encrypt( MCRYPT_3DES, $c->secret, $id, MCRYPT_MODE_ECB) );
		$smsCode = preg_replace('@^(.*?)(?:=+)$@', '$1', $smsCodeB64);
		$numEqualSigns = mb_strlen( $smsCodeB64 ) - mb_strlen( $smsCode );
		$smsCode = "c1{$smsCode}{$numEqualSigns}1c";
		return $smsCode;
    }
    
    public static function getIdForSMSCode( $smsCode ){
        $c = BIM_Config::sms();
        // first we strip c1 1c
        $ptrn = "@^c1(.*?)1c$@";
        $smsCode = preg_replace( $ptrn, '$1', $smsCode );
        
        // then we look at the last char which is a number
        // that tells us how many equal signs to append
        // to make a proper base64 string
        $idx = mb_strlen( $smsCode ) - 1;
        $numEqualSigns = $smsCode[ $idx ];

        // then we replace the last char
        // and append the equal signs
        $ptrn = "@^(.*?)$numEqualSigns$@";
        $smsCodeB64 = preg_replace( $ptrn, '$1', $smsCode );
        $equalSigns = str_repeat('=', $numEqualSigns);
        $smsCodeB64 .= $equalSigns;
        
        // then decode and decrypt
        $smsCode = base64_decode( $smsCodeB64 );
        $id = mcrypt_decrypt(MCRYPT_3DES, $c->secret, $smsCode, MCRYPT_MODE_ECB);
        
        $id = trim( $id );
        
        return $id;
    }
    
	// here we check for a valid session key
	// in a cookie named as named in the onfig
	public static function getSessionUser(){
	    if( ! self::$user ){
	        $sessionConf = BIM_Config::session();
	        if( $sessionConf->use ){
                $user = BIM_Model_User::getByToken( self::getAdvertisingId() );
                if( !$user || !$user->isExtant() ){
	                $user = BIM_Model_User::getByToken( self::getDeviceToken() );
	                if( !$user || !$user->isExtant() ){
    	                $user = null;
    	            }
                }
                self::$user = $user;
	        }
	        /*
    	    $conf = BIM_Config::session();
    	    if( !empty( $_COOKIE[ $conf->cookie->name ] ) ){
    	        // decrypt the userId
    	        $userId = BIM_Utils::getIdForSMSCode(  $_COOKIE[ $conf->cookie->name ]  );
    	        if( $userId ){
    	            $user = BIM_Model_User::get( $userId );
    	            if( !$user->isExtant() ){
    	                $user = null;
    	            }
                    self::$user = $user;    	            
    	        }
    	    }
    	    */
	    }
	    return self::$user;
	}
	
	public static function getAdvertisingId(){
	    if( !self::$adid ){
	        self::processHMAC();
	    }
        return self::$adid;
	}
	
	public static function getDeviceToken(){
	    if( !self::$deviceToken ){
	        self::processHMAC();
	    }
        return self::$deviceToken;
	}
	
	protected static function processHMAC(){
        $hmac = !empty($_SERVER['HTTP_HMAC']) ? $_SERVER['HTTP_HMAC'] : '';
        if( $hmac ){
            list( $hmac, $token ) = explode('+', $hmac, 2);
            $hash = hash_hmac('sha256', $token, "YARJSuo6/r47LczzWjUx/T8ioAJpUKdI/ZshlTUP8q4ujEVjC0seEUAAtS6YEE1Veghz+IDbNQ");
            if( $hash == $hmac ){
                list( $deviceToken, $advertisingId ) = explode('+', $token, 2 );
                self::$adid = $advertisingId;
                self::$deviceToken = $deviceToken;
            }
        }
	}
	
	public static function setSession( $userId ){
	    $value = BIM_Utils::getSMSCodeForId( $userId );
	    
	    $conf = BIM_Config::session();
	    $name = !empty( $conf->cookie->name ) ? $conf->cookie->name : '/';
	    $expires = !empty( $conf->cookie->expires ) ? time() + $conf->cookie->expires : 0;
	    $path = !empty( $conf->cookie->path ) ? $conf->cookie->path : '/';
	    $domain = !empty( $conf->cookie->domain ) ? $conf->cookie->domain : $_SERVER['HTTP_HOST'];
	    $secure = !empty( $conf->cookie->secure ) ? $conf->cookie->secure : false;
	    $httpOnly = !empty( $conf->cookie->httpOnly ) ? $conf->cookie->httpOnly : false;
	    
	    setcookie($conf->cookie->name,$value,$expires,$path,$domain,$secure,$httpOnly);
	}
	
	/**
	 * 
	 * @param string $birthdate a date in the format: Y-m-d H:i:s
	 */
	public static function ageOK( $birthdate ){
	    $OK = false;
        $birthdate = new DateTime( $birthdate );
        $cutoffBirthdate = new DateTime();
        $cutoffBirthdate->sub( new DateInterval('P25Y') );
        if( $cutoffBirthdate < $birthdate ){
            $OK = true;
        }
	    return $OK;
	}
}
