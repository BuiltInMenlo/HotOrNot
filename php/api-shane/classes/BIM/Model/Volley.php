<?php 

class BIM_Model_Volley{
    
    public function create( $userId, $hashTag, $imgUrl, $targetId, $isPrivate, $expires ) {
        $volleyId = null;
        $hashTagId = $this->getHashTagId($userId, $hashTag);
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $volleyId = $dao->add( $userId, $targetId, $hashTagId, $imgUrl, $isPrivate, $expires );
        return $volleyId;
    }
    
    /**
    $user_arr = array(
        'id' => $user_id, 
        'fb_id' => "",
        'username' => "",
        'avatar' => "",
        'img' => "",
        'score' => 0
    );
     */
    
    public function get($volleyId, $userId = 0) {
        
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
        // compose object & return
        return (array(
            'id' => $volley->id, 
            'status' => ($userId != 0 && $userId == $volley->challenger_id && $volley->status_id == "2") ? "0" : $volley->status_id, 
            'subject' => $dao->getSubject($volley->subject_id), 
            'comments' => $dao->commentCount( $volley->id ), 
            'has_viewed' => $volley->hasPreviewed, 
            'started' => $volley->started, 
            'added' => $volley->added, 
            'updated' => $volley->updated,
            'creator' => $creator,
            'challenger' => $target,
            'expires' => $expires
        ));
    }
    
    public function getHashTagId( $userId, $hashTag = 'N/A' ) {
        $dao = new BIM_DAO_Mysql_Volleys( BIM_Config::db() );
        $hashTagId = $dao->addHashTag($hashTag, $userId);
        if( !$hashTagId ){
            $hashTagId = $dao->getHashTagId($hashTag, $userId);
        }
        return $hashTagId;
    }
}