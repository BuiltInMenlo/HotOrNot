<?php 

class BIM_Model_Volley{
    
    public function __construct($volleyId, $userId = 0) {
        
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volley = $dao->get( $volleyId );
        if( $volley ){
            $creator = BIM_Model_User::get( $volley->creator_id );
            $creator = (object) array(
                'id' => $creator->id, 
                'fb_id' => $creator->fb_id,
                'username' => $creator->username,
                'avatar' => $creator->getAvatarUrl(),
                'img' => $volley->creator_img,
                'score' => 0
            );
            
            $challengers = array();
            foreach( $volley->challengers as $challenger ){
                $target = BIM_Model_User::get( $challenger->challenger_id );
                $joined = new DateTime( "@$challenger->joined" );
                $joined = $joined->format('Y-m-d H:i:s');
                $target = (object) array(
                    'id' => $target->id, 
                    'fb_id' => $target->fb_id,
                    'username' => $target->username,
                    'avatar' => $target->getAvatarUrl(),
                    'img' => $challenger->challenger_img,
                    'score' => 0,
                    'joined' => $joined,
                );
                
                $usersInChallenge = array( $creator, $target );
                $likes = $dao->getLikes($volleyId);
                foreach( $likes as $likeData ){
                    foreach( $usersInChallenge as $user ){
                        if( $user->id == $likeData->uid ){
                            $user->score = $likeData->count;
                            break;
                        }
                    }
                }
                $challengers[] = $target;            
            }
            
            $this->id = $volley->id; 
            $this->status = ($userId != 0 && $userId == $volley->challenger_id && $volley->status_id == "2") ? "0" : $volley->status_id; 
            $this->subject = $dao->getSubject($volley->subject_id); 
            $this->comments = $dao->commentCount( $volley->id ); 
            $this->has_viewed = $volley->hasPreviewed; 
            $this->started = $volley->started; 
            $this->added = $volley->added; 
            $this->updated = $volley->updated;
            $this->creator = $creator;
            // legacy versions of client do not support multiple challengers
            if( $this->isLegacy() ){
                $this->challenger = $challengers[0];
            } else{
                $this->challengers = $challengers;
            }
            $this->expires = $volley->expires;
            $this->is_private = $volley->is_private;
            $this->is_verify = $volley->is_verify;
        }
    }
    
    // returns true if the requesting client
    // is a legacy client
    public function isLegacy(){
        return (defined( 'IS_LEGACY' ) && IS_LEGACY );
    }
    
    /**
     * return the list of users
     * in the volley including the creator
     */
    public function getUsers(){
        $userIds = array();
        if( $this->isLegacy() ){
            $userIds[] = $this->challenger->id;
	} else {
            foreach( $this->challengers as $challenger ){
    	        $userIds[] = $challenger->id;
    	    }
	}
	$userIds[] = $this->creator->id;
	return $userIds;
    }
    
    public function comment( $userId, $text ){
        $comment = BIM_Model_Comments::create( $this->id, $userId, $text );
        $this->purgeFromCache();
    }
    
    public function getComments(){
        return BIM_Model_Comments::getForVolley( $this->id );
    }
    
    public function isExpired(){
        $expires = -1;
        if( !empty( $this->expires ) && $this->expires > -1 ){
            $expires = $this->expires - time();
            if( $expires < 0 ){
                $expires = 0;
            }
        }
        return ($expires == 0);
    }
    
    /**
     * 
     * returns true or false depending
     * if the passed user id can cast an approve vote
     * for the creator of this volley
     * 
     * This ONLY anly applies to a verification volley
     * 
     * if this IS NOT a verification volley then this 
     * function will always return true
     * 
     * @param int $userId
     */
    public function canApproveCreator( $userId ){
        $OK = true;
        if( !empty($this->is_verify) ){
            $OK = false;
            if( ! $this->isCreator($userId) && ! $this->hasApproved( $userId ) ){
                $OK = true;
            }
        }
        return $OK;
    }
    
    public function isCreator( $userId ){
        return ($this->creator->id == $userId );
    }
    
    public function hasApproved( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        return $dao->hasApproved( $this->id, $userId );
    }
    
    public static function create( $userId, $hashTag, $imgUrl, $targetIds, $isPrivate, $expires, $isVerify = false ) {
        $volleyId = null;
        $hashTagId = self::getHashTagId($userId, $hashTag);
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleyId = $dao->add( $userId, $targetIds, $hashTagId, $imgUrl, $isPrivate, $expires, $isVerify );
        return self::get( $volleyId );
    }
    
    public static function getVerifyVolley( $targetId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $id = $dao->getVerifyVolleyIdForUser( $targetId );
        return BIM_Model_Volley::get( $id );
    }
    
    public static function createVerifyVolley( $targetId, $returnFriends = false ){
	    $target = BIM_Model_User::get( $targetId );
	    
        $friends = BIM_App_Social::getFriends( (object) array('userID' => $targetId, 'from' => 0, 'size' => 50 ) );
        $friendIds = array_map(function($friend){return $friend->user->id;}, $friends);
        $totalFriends = count( $friendIds );
        $userIds = $friendIds;
        if( $totalFriends < 50 ){
            $usersNeeded = 50 - $totalFriends;
            $userIds = array_merge( $userIds, BIM_Model_User::getRandomIds( $usersNeeded, array( $targetId ) ) );
        }
        $returnVolley = BIM_Model_Volley::create($targetId, '#__verifyMe__', $target->getAvatarUrl(), $userIds, 'N', -1, true);
        if( $returnFriends ){
            $returnVolley = (object) array( 'volley' => $returnVolley, 'friendIds' => $friendIds );
        }
        return $returnVolley;
    }
    
    public static function getHashTagId( $userId, $hashTag = 'N/A' ) {
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $hashTagId = $dao->addHashTag($hashTag, $userId);
        if( !$hashTagId ){
            $hashTagId = $dao->getHashTagId($hashTag, $userId);
        }
        return $hashTagId;
    }
    
    // $userId, $imgUrl
    public function join( $userId, $imgUrl ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->join( $this->id, $userId, $imgUrl );
        $this->purgeFromCache();
    }
    
    public function updateStatus( $status ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->updateStatus( $this->id, $status );
        $this->purgeFromCache();
    }
    
    public function acceptFbInviteToVolley( $userId, $inviteId ){
        $this->updateStatus(2);
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->acceptFbInviteToVolley( $this->id, $userId, $inviteId );
        $this->purgeFromCache();
    }
    
    public function upVote( $targetId, $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->upVote( $this->id, $userId, $targetId  );
        $this->purgeFromCache();
    }
    
    public function purgeFromCache(){
        $key = self::makeCacheKeys($this->id);
        $cache = new BIM_Cache( BIM_Config::cache() );
        $cache->delete( $key );
    }
    
    public function accept( $userId, $imgUrl ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->accept( $this->id, $userId, $imgUrl );
        $this->purgeFromCache();
    }
    
    public function cancel(){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->cancel( $this->id );
        $this->purgeFromCache();
    }
    
    public function flag( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->flag( $this->id, $userId );
        $this->purgeFromCache();
    }
    
    public function setPreviewed( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->setPreviewed( $this->id );
        $this->purgeFromCache();
    }
    
    public function isExtant(){
        return !empty( $this->id );
    }
    
    public function isNotExtant(){
        return (!$this->isExtant());
    }
    
    public function hasChallenger( $userId ){
        $has = false;
        if( $this->isLegacy() ){
            $has = ( $this->challenger->id == $userId );
        } else {
            if( !empty( $this->challengers ) ){
                foreach( $this->challengers as $challenger ){
                    if( $challenger->id == $userId ){
                        $has = true;
                        break;
                    }
                }
            }
        }
        return $has;
    }
    
    public function hasUser( $userId ){
        $has = ($this->creator->id == $userId);
        if( !$has ){
            $has = $this->hasChallenger($userId);
        }
        return $has;
    }
    
    public static function getRandomAvailableByHashTag( $hashTag, $userId = null ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $v = $dao->getRandomAvailableByHashTag( $hashTag, $userId );
        if( $v ){
            $v = self::get( $v->id );
        }
        return $v;
    }
    
    public static function getAllForUser( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleyIds = $dao->getAllIdsForUser( $userId );
        return self::getMulti($volleyIds);
    }
    
    /** 
     * Helper function to build a list of opponents a user has played with
     * @param $user_id The ID of the user to get challenges (integer)
     * @return An array of user IDs (array)
    **/
    public static function getOpponents($user_id, $private = false) {
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getOpponents( $user_id, $private );
        // push opponent id
        $id_arr = array();
        foreach( $ids as $row ){
            $id_arr[] = ( $user_id == $row->creator_id ) ? $row->challenger_id : $row->creator_id;
        }
        $id_arr = array_unique($id_arr);
        return $id_arr;
    }
    
    /** 
     * Helper function to build a list of challenges between two users
     * @param $user_id The ID of the 1st user to get challenges (integer)
     * @param $opponent_id The ID of 2nd the user to get challenges (integer)
     * @param $last_date The timestamp to start at (integer)
     * @return An associative obj of challenge IDs paired w/ timestamp (array)
    **/
    public static function withOpponent($userId, $opponentId, $lastDate="9999-99-99 99:99:99", $private ) {
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleys = $dao->withOpponent($userId, $opponentId, $lastDate, $private);
        
        $volleyArr = array();
        foreach( $volleys as $volleyData ){
            $volleyArr[ $volleyData->id ] = $volleyData->updated;
        }
        return $volleyArr;
    }
    
    /** 
     * Gets all the public challenges for a user
     * @param $user_id The ID of the user (integer)
     * @return The list of challenges (array)
    **/
    public static function getVolleys($userId, $private = false ) {
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleyIds = $dao->getIds($userId, $private);
        return self::getMulti($volleyIds);
    }
    
    public static function makeCacheKeys( $ids ){
        if( $ids ){
            $return1 = false;
            if( !is_array( $ids ) ){
                $ids = array( $ids );
                $return1 = true;
            }
            foreach( $ids as &$id ){
                $id = "volley_$id";
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
        $volleyKeys = self::makeCacheKeys( $ids );
        $cache = new BIM_Cache( BIM_Config::cache() );
        $volleys = $cache->getMulti( $volleyKeys );
        // now we determine which things were not in memcache dn get those
        $retrievedKeys = array_keys( $volleys );
        $missedKeys = array_diff( $volleyKeys, $retrievedKeys );
        if( $missedKeys ){
            foreach( $missedKeys as $volleyKey ){
                list($prefix,$volleyId) = explode('_',$volleyKey);
                $volley = self::get( $volleyId, true );
                if( $volley->isExtant() ){
                    $volleys[ $volleyKey ] = $volley;
                }
            }
        }
        return array_values($volleys);        
    }
    
    public static function get( $volleyId, $forceDb = false ){
        $cacheKey = self::makeCacheKeys($volleyId);
        $volley = null;
        $cache = new BIM_Cache( BIM_Config::cache() );
        if( !$forceDb ){
            $volley = $cache->get( $cacheKey );
        }
        if( !$volley ){
            $volley = new self($volleyId);
            if( $volley->isExtant() ){
                $cache->set( $cacheKey, $volley );
            }
        }
        return $volley;
    }
    
    public static function getVolleysWithFriends( $userId ){
        $friends = BIM_App_Social::getFriends( (object) array('userID' => $userId ) );
        $friendIds = array_map(function($friend){return $friend->user->id;}, $friends);
        // we add our own id here so we will include our challenges as well, not just our friends
        $friendIds[] = $userId;
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getVolleysWithFriends($userId, $friendIds);
        return self::getMulti($ids);
    }
    
    public static function getTopHashTags( $subjectName ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        return $dao->getTopHashTags($subjectName);
    }
    
    public static function getTopVolleysByVotes( ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $ids = $dao->getTopVolleysByVotes();
        return self::getMulti($ids);
    }
    
    public static function autoVolley( $userId ){
		// starting users & snaps
        $snap_arr = array(
        	array(// @Team Volley #welcomeVolley
        		'user_id' => "2394", 
        		'subject_id' => "1367", 
        		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000000"),
        	
        	array(// @Team Volley #teamVolleyRules
        		'user_id' => "2394", 
        		'subject_id' => "1368", 
        		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000001"),
        		
        	array(// @Team Volley #teamVolley
        		'user_id' => "2394", 
        		'subject_id' => "1369", 
        		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000002"),
        		
        	array(// @Team Volley #teamVolleygirls
        		'user_id' => "2394", 
        		'subject_id' => "1370", 
        		'img_prefix' => "https://hotornot-challenges.s3.amazonaws.com/fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb_0000000003")
        );
        // choose random snap
        $snap = $snap_arr[ array_rand( $snap_arr ) ];
		$subjectId = $snap['subject_id'];
		$autoUserId = $snap['user_id'];
		$img = $snap['img_prefix'];

		$dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
		$hashTag = $dao->getSubject($subjectId);
		
		self::create($userId, $hashTag, $img, array( $userId ), 'N', -1);
    }
}
