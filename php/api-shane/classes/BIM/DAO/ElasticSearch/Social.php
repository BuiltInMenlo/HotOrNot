<?php 

class BIM_DAO_ElasticSearch_Social extends BIM_DAO_ElasticSearch {
    
    public function getFriends( $params ){
        $userId = isset( $params->id ) ? $params->id : 0;
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 100;
        
        $should = array(
            array(
            	"term" => array( "source" => $userId )
            ),
            array(
            	"term" => array( "target" => $userId )
            )
        );
        
        $query = array(
            "from" => $from,
            "size" => $size,
            "query" => array(
                "bool" => array(
                    "should" => $should,
                    "minimum_number_should_match" => 1
                )
            )
        );
        
        $urlSuffix = "social/friends/_search";
        
        return $this->call('POST', $urlSuffix, $query);
        
    }
    
    public static function makeFriendkey( $doc ){
        $key = array( $doc->source, $doc->target );
        sort( $key );
        return join('_', $key );
    }
    
    public function addFriend( $doc ){
        $added = false;
        $id = self::makeFriendkey($doc);
        $urlSuffix = "social/friends/$id/_create";
        $added = $this->call('PUT', $urlSuffix, $doc);
        
        $added = json_decode( $added );
        if( isset( $added->ok ) && $added->ok ){
            $added = true;
        } else {
            $added = false;
        }
        return $added;
    }
    
    /**
     * 
     * we receive a frinedships doc and make sure that the
     * there is not a record for this pair already
     * 
     * @param object $doc
     */
    public function friendshipExists( $doc ){
        $exists = true;
        if( !empty( $doc->source ) && !empty( $doc->target ) ){
            $id = self::makeFriendkey($doc);
            $urlSuffix = "social/friends/$id";
            $exists = $this->call('GET', $urlSuffix);
            $exists = json_decode( $exists );
            if( empty($exists->exists) ){
                $exists = false;
            }
        }
        return $exists;
    }
    
    public function acceptFriend( $doc ){
        $added = false;
        if( isset( $doc->source ) && $doc->source ){
            $update = array(
                'script' => "
                    if(target == ctx._source.target && ctx._source.state == 0){
                    	ctx._source.state = 1;
                    	ctx._source.accept_time = timestamp;
                    }
                    ;
                ",
                'params' => array(
                    'timestamp' => time(),
                    'target' => $doc->target,
                )
            );
            $id = self::makeFriendkey($doc);
            $urlSuffix = "social/friends/$id/_update";
            $added = $this->call('POST', $urlSuffix, $update);
            $added = json_decode( $added );
            if( isset( $added->ok ) && $added->ok ){
                $added = true;
            } else {
                $added = false;
            }
        }
        return $added;
    }
    
    public function removeFriend( $doc ){
        $removed = false;
        if( isset( $doc->source ) && $doc->source ){
            $id = self::makeFriendkey($doc);
            $urlSuffix = "social/friends/$id";
            $removed = $this->call('DELETE', $urlSuffix);
            $removed = json_decode( $removed );
            if( isset( $removed->ok ) && $removed->ok ){
                $removed = true;
            } else {
                $removed = false;
            }
        }
        return $removed;
    }
}