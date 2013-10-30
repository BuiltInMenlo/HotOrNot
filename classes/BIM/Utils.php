<?php 
class BIM_Utils{
    
    protected static $user = null;
    protected static $request = null;
    protected static $adid = null;
    protected static $deviceToken = null;
    protected static $profile = array();
    
    public static function cancelTimedPushes( $userId, $volleyId ){
        $dao = new BIM_DAO_Mysql_Jobs( BIM_Config::db() );
        $dao->cancelTimedPushes( $userId, $volleyId );
    }
    
    public static function hashMobileNumber( $number ){
        $c = BIM_Config::sms();
        if( !empty($c->useHashing) ){
            $number = self::blowfishEncrypt($number);
        }
        return $number;
    }
    
    public static function hashList( &$list ){
        foreach( $list as &$value ){
            $value = self::blowfishEncrypt($value);
        }
    }
    
    public static function decryptList( &$list ){
        foreach( $list as &$value ){
            $value = self::blowfishDecrypt($value);
        }
    }
    
    public static function blowfishEncrypt( $number ){
        $c = BIM_Config::sms();
        $iv = base64_decode($c->blowfish->b64iv);
        $enc = base64_encode( mcrypt_encrypt( MCRYPT_BLOWFISH, $c->blowfish->key, $number, MCRYPT_MODE_CBC, $iv ) );
        return $enc;
    }
    
    public static function blowfishDecrypt( $encryptedNumber ){
        $c = BIM_Config::sms();
        $iv = base64_decode($c->blowfish->b64iv);
        $dec = mcrypt_decrypt( MCRYPT_BLOWFISH, $c->blowfish->key, base64_decode( $encryptedNumber ), MCRYPT_MODE_CBC, $iv );
        return $dec;
    }
    
    public static function getRequest(){
        if( ! self::$request ){
            $c = BIM_Config::app();
            $cdata = trim(preg_replace( "@$c->base_path@", '', $_SERVER['SCRIPT_URL'] ),'/');
            
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
	public static function getSessionUser( $checkDeviceToken = false ){
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
	    }
	    if( $checkDeviceToken && self::$user ){
	        if( self::$user->device_token != self::$deviceToken ){
	            self::$user->setDeviceToken( self::$deviceToken );
	        }
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
	public static function ageOK( $userBirthdate ){
	    $OK = false;
        $userBirthdate = new DateTime( $userBirthdate );
        
        $youngBirthdate = new DateTime();
        $youngBirthdate->sub( new DateInterval('P14Y') );
        
        $oldBirthdate = new DateTime();
        $oldBirthdate->sub( new DateInterval('P20Y') );
        
        if( ( $userBirthdate < $youngBirthdate ) && ( $userBirthdate > $oldBirthdate ) ){
            // if the users birthdate comes 
            // BEFORE our youngest acceptable age
            // AND
            // if the users birthdate comes 
            // AFTER our oldest acceptable age
            $OK = true;
        }
        
        return $OK;
	}
	
	public static function isProfiling(){
	    return (defined( 'PROFILING' ) && PROFILING);
	}
	
	public static function startProfiling(){
        $profilingKey = 'PROFILING';
        if( !empty( $_GET['__profile__'] ) ){
            self::$profile['start_time'] = microtime(true);
            define($profilingKey,TRUE);
        } else {
            define($profilingKey,FALSE);
        }
	}
	
	public static function endProfiling(){
        if( BIM_Utils::isProfiling() ){
            $totalTime = microtime(true) - self::$profile['start_time'];
            file_put_contents('/tmp/req_profile', $totalTime );
            file_put_contents('/tmp/sql_profile', print_r(BIM_DAO_Mysql::$profile ,1) );
            file_put_contents('/tmp/es_profile', print_r(BIM_DAO_ElasticSearch::$profile ,1) );
            file_put_contents('/tmp/cache_profile', print_r(BIM_Cache::$profile ,1) );
        }
	}
	
    public static function putImage( $image, $name ){
            if( is_string($image) ){
                $image = new Imagick( $image );
            }
            $conf = BIM_Config::aws();
            S3::setAuth($conf->access_key, $conf->secret_key);
            S3::putObjectString($image->getImageBlob(), 'hotornot-challenges', $name, S3::ACL_PUBLIC_READ, array(), 'image/jpeg' );
	}            
	
    public static function processImage( $imgPrefix, $bucket = 'hotornot-challenges' ){
        $image = self::getImage($imgPrefix);
        if( $image ){
            $conf = BIM_Config::aws();
            S3::setAuth($conf->access_key, $conf->secret_key);
            $convertedImages = BIM_Utils::finalizeImages($image);
            $parts = parse_url( $imgPrefix );
            $path = trim($parts['path'] , '/');
            foreach( $convertedImages as $suffix => $image ){
                $name = "{$path}{$suffix}.jpg";
                S3::putObjectString($image->getImageBlob(), $bucket, $name, S3::ACL_PUBLIC_READ, array(), 'image/jpeg' );
            }
        }
        return (bool) $image;
    }
    
    public static function processUserImage( $imgPrefix, $bucket = 'hotornot-avatars' ){
        $imgPrefix = preg_replace('@Large_640x1136\.jpg@', '', $imgPrefix);
        $image = self::getImage($imgPrefix);
        if( $image ){
            $conf = BIM_Config::aws();
            S3::setAuth($conf->access_key, $conf->secret_key);
            $convertedImages = BIM_Utils::finalizeImages($image);
            $parts = parse_url( $imgPrefix );
            $path = trim($parts['path'] , '/');
            foreach( $convertedImages as $suffix => $image ){
                $name = "{$path}{$suffix}.jpg";
                S3::putObjectString($image->getImageBlob(), $bucket, $name, S3::ACL_PUBLIC_READ, array(), 'image/jpeg' );
            }
        }
    }
    
    public static function getImage( $imgPrefix ){
        $image = null;
        $imgUrl = "{$imgPrefix}Large_640x1136.jpg";
        try{
            $image = new Imagick( $imgUrl );
        } catch ( Exception $e ){
            $msg = $e->getMessage()." - $imgUrl";
            error_log( $msg );
            $image = null;
        }
        return $image;
    }
    
    public static function finalizeImages( $image ){
        $convertedImages = array();
        
        self::resize($image, 320, 568);
        self::cropY($image, 320, 320);
        $mediumImage = clone $image;
        $convertedImages['Medium_320x320'] = $mediumImage;
        
        self::resize($image, 160, 160);
        $smallImage = clone $image;
        $convertedImages['Small_160x160'] = $smallImage;
        
        return $convertedImages;
    }
    
    public static function resize( $image, $width, $height ){
        $image->setImagePage(0,0,0,0);
        $image->setImageResolution( $width, $height );
        $image->resizeImage($width, $height,imagick::FILTER_LANCZOS,0);
    }
    
    public static function cropX( $image, $width, $height ){
        $x = (int) ($image->getImageWidth() - $width)/2;
        $image->setImagePage(0,0,0,0);
        $image->setImageResolution($width,$height);
        $image->cropImage($width, $height, $x, 0);
    }
    
    public static function cropY( $image, $width, $height ){
        $y = (int) ($image->getImageHeight() - $height)/2;
        $image->setImagePage(0,0,0,0);
        $image->setImageResolution($width,$height);
        $image->cropImage($width, $height, 0, $y);
    }
    
    public static function isCelebrity( $id ){
        $isCeleb = false;
        $c = BIM_Config::app();
        if( !empty( $c->celebrities ) && in_array( $id, $c->celebrities ) ){
            $isCeleb = true;
        }
        return (int) $isCeleb;
    }
    
    public static function makeCacheKeys( $prefix, $ids ){
        if( $ids ){
            $return1 = false;
            if( !is_array( $ids ) ){
                $ids = array( $ids );
                $return1 = true;
            }
            if( defined('RELEASE_ID_KEY_PREFIX') ){
                $prefix = RELEASE_ID_KEY_PREFIX."_$prefix";
            }
            foreach( $ids as &$id ){
                $id = "{$prefix}_{$id}";
            }
            if( $return1 ){
                $ids = $ids[0];
            }
        }
        return $ids;
    }
}
