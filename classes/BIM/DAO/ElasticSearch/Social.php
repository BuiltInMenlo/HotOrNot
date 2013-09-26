<?php 

class BIM_DAO_ElasticSearch_Social extends BIM_DAO_ElasticSearch {
    
    public function getFriendDocuments( ){
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 200000;
        $query = array(
            "from" => $from,
            "size" => $size,
        );
        $urlSuffix = "social/friends/_search";
        return $this->call('POST', $urlSuffix, $query);
    }
    
    public function deleteRelationships( $userId ){
        
        $should = array(
            array(
            	"term" => array( "source" => $userId )
            ),
            array(
            	"term" => array( "target" => $userId )
            )
        );
        
        $query = array(
            "bool" => array(
                "should" => $should,
                "minimum_number_should_match" => 1
            )
        );
        
        $urlSuffix = "social/friends/_query";
        
        return $this->call('DELETE', $urlSuffix, $query);
        
    }
    
    public function removeRelation( $doc ){
        $key = self::makeFriendkey($doc);
        $urlSuffix = "social/friends/$key";
        return $this->call('DELETE', $urlSuffix );
    }
    
    public function getFriends( $params ){
        $userId = isset( $params->id ) ? $params->id : 0;
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 256;
        
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
            ),
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
        if( !empty( $doc->source ) ){
            $update = array(
                'script' => "
                	ctx._source.state = 1;
                	ctx._source.accept_time = timestamp;
                ",
                'params' => array(
                    'timestamp' => time(),
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
    
    /**
     * if the state = 0 and the passed doc source == the relation source
     * we delete
     * 
     * if the state = 1
     * 		reltion.source = doc.target
     * 		relation.target = doc.source
     * 		state = 0 
     * 
     */
    public function removeFriend( $doc ){
        $removed = false;
        if( isset( $doc->source ) && $doc->source ){
            $relation = $this->getRelation($doc);
            if( $relation ){
                if( $relation->state == 0 && ($doc->source == $relation->source) ){
                    $id = self::makeFriendkey($doc);
                    $urlSuffix = "social/friends/$id";
                    $removed = $this->call('DELETE', $urlSuffix);
                    $removed = json_decode( $removed );
                    if( isset( $removed->ok ) && $removed->ok ){
                        $removed = true;
                    } else {
                        $removed = false;
                    }
                } else if( $relation->state == 1 ){
                    $params = array();
                    if( $doc->source == $relation->source_data->id ){
                        $params = array(
                            'source' => $relation->target_data,
                            'target' => $relation->source_data,
                        );                    
                    } else if( $doc->source == $relation->target_data->id ){
                        $params = array(
                        	'source' => $relation->source_data,
                            'target' => $relation->target_data,
                        );                    
                    }
                    if( $params ){
                        $update = array(
                            'script' => "
                            	ctx._source.state = 0;
                            	
                            	ctx._source.source = source.id;
                            	ctx._source.source_data = source;
                            	
                            	ctx._source.target = target.id;
                            	ctx._source.target_data = target;
                            ",
                            'params' => $params
                        );
                        $id = self::makeFriendkey($doc);
                        $urlSuffix = "social/friends/$id/_update";
                        $removed = $this->call('POST', $urlSuffix, $update);
                        $removed = json_decode($removed);
                        if( !empty( $removed->ok ) ){
                            $removed = true;
                        } else {
                            $removed = false;
                        }
                    }
                }
            }
        }
        return $removed;
    }
    
    public function getRelation( $doc ){
        $relation = null;
        if( isset( $doc->source ) && $doc->source ){
            $id = self::makeFriendkey($doc);
            $urlSuffix = "social/friends/$id";
            $relation = $this->call('GET', $urlSuffix);
            $relation = json_decode( $relation );
            if( isset( $relation->exists ) && $relation->exists ){
                $relation = $relation = $relation->_source;
            } else {
                $relation = null;
            }
        }
        return $relation;
    }
}