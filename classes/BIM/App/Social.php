<?php

class BIM_App_Social extends BIM_App_Base{

    public static function addFriend( $params, $doNotification = true ){
        $added = false;
        $targets = explode('|',$params->target);
        foreach( $targets as $target ){
            $params->target = $target;
            $added = self::_addFriend($params);
            if( $added && $doNotification ){
                BIM_Push::friendNotification( $params->userID, $params->target );
            }
        }
        
        $targets[] = $params->userID;
        BIM_Model_User::purgeById($targets);
        
        return self::getFollowed($params);
    }
    
    protected static function _addFriend( $params ){
        $added = false;
        $targetUser = BIM_Model_User::get( $params->target );
        if( $targetUser->isExtant() ){
            $sourceUser = BIM_Model_User::get( $params->userID );
            $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
            $relation = (object) array(
                'source' => $params->userID,
                'target' => $params->target,
            );
            $doc = $dao->getRelation( $relation );
            if( isset( $doc->state ) && $doc->state == 0 && ( $params->userID != $doc->source ) ){
                $added = $dao->acceptFriend( $relation );
            } else if( !$doc ){
                $relation = self::createRelationDoc($params, $sourceUser, $targetUser);
                $added = $dao->addFriend( $relation );
            }
            
            $dao->flush();
        }
        return $added;
    }
    
    protected static function createRelationDoc( $params, $source, $target ){
        $time = time();
        $defaultState = 0;
        $acceptTime = -1;
        if( !empty( $params->auto ) ){
            $defaultState = 1;
            $acceptTime = $time;
        }
        
        $relation = (object) array(
            'source' => $params->userID,
            'target' => $params->target,
            'state' => $defaultState,
            'init_time' => $time,
            'accept_time' => $acceptTime,
            'source_data' => (object) array(
                'username' => $source->username,
                'id' => $source->id,
                'avatar_url' => $source->getAvatarUrl()
            ),
            'target_data' => (object) array(
                'username' => $target->username,
                'id' => $target->id,
                'avatar_url' => $target->getAvatarUrl()
            ),
        );
        
        return $relation;
    }
    
    public static function acceptFriend( $params ){
        $accepted = false;
        $sources = explode('|',$params->source);
        foreach( $sources as $source ){
            $params->source = $source;
            $accepted = self::_acceptFriend($params);
            if( $accepted ){
                BIM_Push::friendAcceptedNotification( $params->userID, $params->source );
            }
        }
        
        $sources[] = $params->userID;
        BIM_Model_User::purgeById($sources);
        
        return self::getFriends($params);
    }
    
    protected static function _acceptFriend( $params ){
        $accepted = false;
        $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
        
        $relation = (object) array(
            'target' => $params->userID,
            'source' => $params->source,
        );
        $doc = $dao->getRelation( $relation );
        if( $doc && $doc->state == 0 ){
            $accepted = $dao->acceptFriend( $relation );
            $dao->flush();
        }
        return $accepted;
    }
    
    public static function removeFriend( $params ){
        $removed = false;
        $targets = explode('|',$params->target);
        foreach( $targets as $target ){
            $params->target = $target;
            $removed = self::_removeFriend($params);
        }
        
        $targets[] = $params->userID;
        BIM_Model_User::purgeById($targets);
        
        return self::getFollowed($params);
    }
    
    protected static function _removeFriend( $params ){
        $removed = false;
        $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
        
        $relation = (object) array(
            'source' => $params->userID,
            'target' => $params->target,
        );
        $removed = $dao->removeFriend( $relation );
        $dao->flush();
        return $removed;
    }
    
    /**
     * 
     * @param stdClass $params
     * @param boolean $assoc - true to return an assoc array where the keys are the user ids
     * 
     */
    public static function getFriends( $params, $assoc = false ){
        $friendList = array();
        $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
        
        $relation = (object) array(
            'id' => $params->userID,
            'from' => !empty($params->from) ? (int) $params->from : 0,
            'size' => !empty($params->size) ? (int) $params->size : 100,
        );
        $friends = $dao->getFriends( $relation );
        $friends = json_decode($friends);
        
        if( !empty( $friends->hits->hits ) && is_array( $friends->hits->hits ) ){
            foreach( $friends->hits->hits as $hit ){
                if( $hit->_source->source_data->id == $params->userID ){
                    $hit->_source->user = $hit->_source->target_data;
                } else {
                    $hit->_source->user = $hit->_source->source_data;
                }
                unset( $hit->_source->source_data );
                unset( $hit->_source->target_data );
                if( $assoc ){
                    $friendList[$hit->_source->user->id] = $hit->_source;
                } else {
                    $friendList[] = $hit->_source;
                }
            }
        }
        return $friendList;
    }
    
    public static function getFollowed( $params, $assoc = false ){
        $friends = self::getFriends($params, $assoc );
        $followers = array();
        foreach( $friends as $key => $friend ){
            if( $friend->source == $params->userID
                || ( ($friend->target == $params->userID ) && $friend->state == 1 ) ){
                if( $assoc ){
                    $followers[ $key ] = $friend;
                } else {
                    $followers[] = $friend;
                }
            }
        }
        return $followers;
    }
    
    public static function getFollowers( $params, $assoc = false ){
        $friends = self::getFriends($params, $assoc);
        $followers = array();
        foreach( $friends as $key => $friend ){
            if( $friend->target == $params->userID
                || ( ($friend->source == $params->userID ) && $friend->state == 1 ) ){
                if( $assoc ){
                    $followers[ $key ] = $friend;
                } else {
                    $followers[] = $friend;
                }
            }
        }
        return $followers;
    }
}
