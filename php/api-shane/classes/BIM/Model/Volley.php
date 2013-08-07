<?php 

class BIM_Model_Volley{
    
    public function __construct($volleyId, $userId = 0) {
        
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volley = $dao->get( $volleyId );
        
        $expires = -1;
        if( !empty( $volley->expires ) && $volley->expires > -1 ){
            $expires = $volley->expires - time();
            if( $expires < 0 ){
                $expires = 0;
            }
        }
        
        $creator = new BIM_User( $volley->creator_id );
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
            $target = new BIM_User( $challenger->challenger_id );
            $joined = new DateTime( "@$challenger->joined" );
            $joined = $joined->format('Y-m-d H:i:s');
            $target = (object) array(
                'id' => $target->id, 
                'fb_id' => $target->fb_id,
                'username' => $target->username,
                'avatar' => $target->getAvatarUrl(),
                'img' => $challenger->challenger_img,
                'score' => 0,
                'joined' => $joined
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
        if( defined( 'IS_LEGACY' ) && IS_LEGACY ){
            $this->challenger = $challengers[0];
        } else{
            $this->challengers = $challengers;
        }
        $this->expires = $expires;
        $this->is_private = $volley->is_private;
    }
    
    public static function create( $userId, $hashTag, $imgUrl, $targetIds, $isPrivate, $expires ) {
        $volleyId = null;
        $hashTagId = self::getHashTagId($userId, $hashTag);
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleyId = $dao->add( $userId, $targetIds, $hashTagId, $imgUrl, $isPrivate, $expires );
        $volley = new self( $volleyId );
        return $volley;
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
    }
    
    public function accept( $userId, $imgUrl ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->accept( $this->id, $userId, $imgUrl );
    }
    
    public function cancel(){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->cancel( $this->id );
    }
    
    public function flag( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->flag( $this->id, $userId );
    }
    
    public function setPreviewed( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->setPreviewed( $this->id );
    }
    
    public static function getRandomAvailableByHashTag( $hashTag, $userId = null ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $v = $dao->getRandomAvailableByHashTag( $hashTag, $userId );
        if( $v ){
            $v = new self( $v->id );
        }
        return $v;
    }
    
    public static function getAllForUser( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleyIds = $dao->getAllIdsForUser( $userId );
        $volleys = array();
        foreach( $volleyIds as $volleyId ){
            $volleys[] = new BIM_Model_Volley($volleyId);
        }
        return $volleys;
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
        $volleyArr = array();
        foreach( $volleyIds as $volleyId ){
            $volleyArr[] = new self($volleyId->id);
        }
        return $volleyArr;
    }
}