<?php 

class BIM_User{
    
    public function __construct( $params = null ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        
        if( !is_object($params) ){
            $params = $dao->getData( $params );
        }
        
        if( $params ){
            foreach( $params as $prop => $value ){
                if( preg_match('@password@', $prop) ) {
                    continue;
                }
                $this->$prop = $value;
            }
        }
        
		// get total votes
        $votes = $dao->getTotalVotes( $this->id );
        $pokes = $dao->getTotalPokes( $this->id );
        $pics = $dao->getTotalChallenges( $this->id );		
		
		// find the avatar image
		$avatar_url = $this->getAvatarUrl();
		
		// assing some additional properties
		$this->name = $this->username; 
		$this->token = $this->device_token; 
	    $this->avatar_url = $avatar_url;
		$this->votes = $votes; 
		$this->pokes = $pokes; 
		$this->pics = $pics;
		$this->meta = '';
	    $this->sms_code = BIM_Utils::getSMSCodeForId( $this->id );
	    $this->friends = BIM_App_Social::getFriends( (object) array( 'userID' => $this->id ) );
	    $this->sms_verified = BIM_User::isVerified( $this->id );
	}
    
    public static function isVerified( $userId ){
        $dao = new BIM_DAO_ElasticSearch_ContactLists( BIM_Config::elasticSearch() );
        $res = $dao->getPhoneList( (object) array('id' => $userId ) );
        $res = json_decode($res);
        $verified = (!empty( $res->_source->hashed_number ) && $res->_source->hashed_number );
        return $verified;
    }
    
    public function isExtant(){
        return ( isset( $this->id ) && $this->id ); 
    }
    
    public function getAvatarUrl() {
        
        // no custom url
        if ($this->img_url == "") {
            
            // has fb login
            if ($this->fb_id != "")
                return ("https://graph.facebook.com/". $this->fb_id ."/picture?type=square");
            
            // has nothing, default
            else
                return ("https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png");
        }
        
        // use custom
        return ($this->img_url);
    }
    
    public static function makeCacheKeys( $ids ){
        if( $ids ){
            $return1 = false;
            if( !is_array( $ids ) ){
                $ids = array( $ids );
                $return1 = true;
            }
            foreach( $ids as &$id ){
                $id = "user_$id";
            }
            if( $return1 ){
                $ids = $ids[0];
            }
        }
        return $ids;
    }
    
    /** 
     * 
     * do a multifetch to memcache
     * if there are any missing objects
     * get them from the db, one a t a time
     * 
    **/
    public static function getMulti( $ids ) {
        $userKeys = self::makeCacheKeys( $ids );
        $cache = new BIM_Cache_Memcache( BIM_Config::memcached() );
        $users = $cache->getMulti( $ids );
        
        // now we determine which things were not in memcache dn get those
        $retrievedKeys = array_keys( $users );
        $missedKeys = array_diff( $userKeys, $retrievedKeys );
        if( $missedKeys ){
            foreach( $missedKeys as $userKey ){
                list($prefix,$userId) = explode('_',$userKey);
                $user = self::get( $userId, true );
                if( $user->isExtant() ){
                    $users[ $user->id ] = $user;
                }
            }
        }
        return array_values( $users );        
    }
        
    public static function get( $id, $forceDb = false ){
        $cacheKey = self::makeCacheKeys($id);
        $user = null;
        $cache = new BIM_Cache_Memcache( BIM_Config::memcached() );
        if( !$forceDb ){
            $user = $cache->get( $cacheKey );
        }
        if( !$user ){
            $user = new self($id);
            if( $user->isExtant() ){
                $cache->set( $cacheKey, $user );
            }
        }
        return $user;
    }
    
    public static function getByUsername( $name, $forceDb = false ){
        $me = null;
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $id = $dao->getIdByUsername( $name );
        if( $id ){
            $me = self::get( $id , $forceDb );
        }
        return $me;
    }
    
    public static function getByToken( $token, $forceDb = false ){
        $me = null;
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $id = $dao->getIdByToken( $token );
        if( $id ){
            $me = self::get( $id, $forceDb );
        }
        return $me;
    }
}
