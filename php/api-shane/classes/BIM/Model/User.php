<?php 

class BIM_Model_User{
    
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
	    $this->sms_verified = self::isVerified( $this->id );
	}
    
    public function setAgeRange( $ageRange ){
        $this->age = $ageRange;
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $dao->setAgeRange( $this->id, $ageRange );
        $this->purgeFromCache();
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
    
    public static function create( $token ){
			// default names
			$defaultName_arr = array(
				"snap4snap",
				"picchampX",
				"swagluver",
				"coolswagger",
				"yoloswag",
				"tumblrSwag",
				"instachallenger",
				"hotbitchswaglove",
				"lovepeaceswaghot",
				"hotswaglover",
				"snapforsnapper",
				"snaphard",
				"snaphardyo",
				"yosnaper",
				"yoosnapyoo"
			);
			
			$rnd_ind = mt_rand(0, count($defaultName_arr) - 1);
			$username = $defaultName_arr[$rnd_ind] . time();
        
			$dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
			$id = $dao->create($username, $token);
			return self::get($id);
    }
    
    public function poke( $targetId ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $pokeId = $dao->poke( $this->id, $targetId );
        if( $pokeId ){
            $this->pokes += 1;
            $this->purgeFromCache();
            $this->purgeFromCache( $targetId );
        }
    }
    
    public function updateUsernameAvatar( $username, $imgUrl ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $dao->updateUsernameAvatar( $this->id, $username, $imgUrl );
        $this->username = $username;
        $this->img_url = $imgUrl;
        $this->purgeFromCache();
    }
    
    public function purgeFromCache( $id = null ){
        $cache = new BIM_Cache( BIM_Config::cache() );
        if(!$id) $id = $this->id; 
        $key = self::makeCacheKeys($id);
        $cache->delete( $key );
        if( !empty($this->device_token) ){
            $cache->delete( $this->device_token );
        }
    }
    
    public function cacheIdByToken(){
        $cache = new BIM_Cache( BIM_Config::cache() );
        if( !empty($this->device_token) ){
            $cache->set( $this->device_token, $this->id );
        }
    }
    
    public static function getCachedIdFromToken( $token ){
        $cache = new BIM_Cache( BIM_Config::cache() );
        return $cache->get( $token );
    }
    
    public function updatePaiid( $isPaid ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $dao->updatePaid( $this->id, $isPaid );
        $this->paid = $isPaid;
        $this->purgeFromCache();
    }
    
    public function updateNotifications( $isNotifications ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $dao->updateNotifications( $this->id, $isNotifications );
        $this->notifications = $isNotifications;
        $this->purgeFromCache();
    }
    
    public function updateUsername( $username ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $dao->updateUsername( $this->id, $username );
        $this->username = $username;
        $this->purgeFromCache();
    }
    
    public function updateFBUsername( $fbId, $username, $gender ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $dao->updateFBUsername($this->id, $fbId, $username, $gender );
        $this->username = $username;
        $this->purgeFromCache();
    }
    
    public function updateFB( $fbId, $gender ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $dao->updateFB($this->id, $fbId, $gender );
        $this->gender = $gender;
        $this->purgeFromCache();
    }
    
    public function getFBInviteId( $fbId ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        return $dao->getFbInviteId( $fbId );
    }
    
    public function updateLastLogin( ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $lastLogin = $dao->updateLastLogin( $this->id );
        $this->last_login = $lastLogin;
        $this->purgeFromCache();
    }
    
    public function acceptFbInviteToVolley( $inviteId ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $volleys = $this->getFbInvitesToVolley( $inviteId );
		// loop thru the challenges
		foreach ( $volleys as $volley ) {
			$volley->acceptFbInviteToVolley( $this->id, $inviteId );
		}
		$this->purgeFromCache();
    }
    
    public function getFbInvitesToVolley( $inviteId ){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $ids = $dao->getFbInvitesToVolley( $inviteId );
        return BIM_Model_Volley::getMulti($ids);
    }
    
    public function getOpponenetsWithSnaps(){
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $userData = $dao->getOpponentsWithSnaps($this->id);
        $ids = array();
        foreach( $userData as $user ){
            $ids[] = $user->creator_id;
            $ids[] = $user->user_id;
        }
        $ids = array_unique($ids);
        return self::getMulti($ids);
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
        $cache = new BIM_Cache( BIM_Config::cache() );
        $users = $cache->getMulti( $userKeys );
        
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
        $cache = new BIM_Cache( BIM_Config::cache() );
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
        
        $id = self::getCachedIdFromToken($token);
        if( $id ){
            $me = self::get( $id, $forceDb );
        } else {
            $id = $dao->getIdByToken( $token );
            $me = self::get( $id, $forceDb );
            if( $me->isExtant() ){
                // this puts us in the cache
                $me->cacheIdByToken();
            }
        }
        return $me;
    }
    
    public static function getUsersWithSimilarName( $username ){
        $me = null;
        $dao = new BIM_DAO_Mysql_User( BIM_Config::db() );
        $ids = $dao->getUsersWithSimilarName( $username );
        return self::getMulti($ids);
    }
}
