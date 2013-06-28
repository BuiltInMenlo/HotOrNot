<?php

class BIM_App_Social extends BIM_App_Base{

    public static function addFriend( $params ){
        $added = false;
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
        );
        
        $added = $dao->addFriend( $relation );
        return $added;
    }
    
    public static function acceptFriend( $params ){
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
            'from' => isset($params->from) ? (int) $params->from : 0,
            'size' => isset($params->size) ? (int) $params->size : 100,
        );
        $friends = $dao->getFriends( $relation );
        $friends = json_decode($friends);
        if( isset( $friends->hits->hits ) && is_array( $friends->hits->hits ) ){
            foreach( $friends->hits->hits as $hit ){
                $friendList[] = $hit->_source;
            }
        }
        return $friendList;
    }
}
