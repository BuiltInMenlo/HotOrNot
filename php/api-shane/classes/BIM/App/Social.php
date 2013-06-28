<?php

class BIM_App_Social extends BIM_App_Base{

    public static function addFriend( $params ){
        $added = false;
        $targets = explode('|',$params->target);
        foreach( $targets as $target ){
            $params->target = $target;
            $added = self::_addFriend($params);
            if( $added ){
                //self::sendFriendNotification( $params );
            }
        }
        return $added;
    }
    
    protected static function _addFriend( $params ){
        $added = false;
        $targetUser = self::getUser( $params->target );
        if( $targetUser ){
            $sourceUser = self::getUser( $params->userID );
            $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
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
                    'username' => $sourceUser->username,
                    'id' => $sourceUser->id,
                    'avatar_url' => $sourceUser->getAvatarUrl()
                ),
                'target_data' => (object) array(
                    'username' => $targetUser->username,
                    'id' => $targetUser->id,
                    'avatar_url' => $targetUser->getAvatarUrl()
                ),
                
            );
            
            $added = $dao->addFriend( $relation );
        }
        return $added;
    }
    

    protected static function getUser( $userId ){
        $user = new BIM_User( $userId );
        if ( !$user || ! $user->isExtant() ){
            $user = false;
        }
        return $user;
    }
    
    public static function acceptFriend( $params ){
        $accepted = false;
        $sources = explode('|',$params->source);
        foreach( $sources as $source ){
            $params->source = $source;
            $accepted = self::_acceptFriend($params);
        }
        return $accepted;
    }
    
    protected static function _acceptFriend( $params ){
        $accepted = false;
        $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
        
        $relation = (object) array(
            'target' => $params->userID,
            'source' => $params->source,
        );
        $accepted = $dao->acceptFriend( $relation );
        return $accepted;
    }
    
    public static function removeFriend( $params ){
        $removed = false;
        $targets = explode('|',$params->target);
        foreach( $targets as $target ){
            $params->target = $target;
            $removed = self::_removeFriend($params);
        }
        return $removed;
    }
    
    protected static function _removeFriend( $params ){
        $removed = false;
        $dao = new BIM_DAO_ElasticSearch_Social( BIM_Config::elasticSearch() );
        
        $relation = (object) array(
            'source' => $params->userID,
            'target' => $params->target,
        );
        $removed = $dao->removeFriend( $relation );
        return $removed;
    }
    
    public static function getFriends( $params ){
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
                $friendList[] = $hit->_source;
            }
        }
        return $friendList;
    }
}
