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
        
        $target = new BIM_User( $volley->challenger_id );
        $target = (object) array(
            'id' => $target->id, 
            'fb_id' => $target->fb_id,
            'username' => $target->username,
            'avatar' => $target->getAvatarUrl(),
            'img' => $volley->challenger_img,
            'score' => 0
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
        $this->id = $volley->id; 
        $this->status = ($userId != 0 && $userId == $volley->challenger_id && $volley->status_id == "2") ? "0" : $volley->status_id; 
        $this->subject = $dao->getSubject($volley->subject_id); 
        $this->comments = $dao->commentCount( $volley->id ); 
        $this->has_viewed = $volley->hasPreviewed; 
        $this->started = $volley->started; 
        $this->added = $volley->added; 
        $this->updated = $volley->updated;
        $this->creator = $creator;
        $this->challenger = $target;
        $this->expires = $expires;
    }
    
    public static function create( $userId, $hashTag, $imgUrl, $targetId, $isPrivate, $expires ) {
        $volleyId = null;
        $hashTagId = self::getHashTagId($userId, $hashTag);
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleyId = $dao->add( $userId, $targetId, $hashTagId, $imgUrl, $isPrivate, $expires );
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
    
    public function accept( $imgUrl ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->accept( $this->id, $imgUrl );
    }
    
    public function cancel(){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->cancel( $this->id );
    }
    
    public function flag( $userId ){
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $dao->flag( $this->id, $userId );
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
}