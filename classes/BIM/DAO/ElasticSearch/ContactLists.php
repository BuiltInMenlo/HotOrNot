<?php 

class BIM_DAO_ElasticSearch_ContactLists extends BIM_DAO_ElasticSearch {
    
    public function getPhoneLists_hashed( ){
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 200000;
        $query = array(
            "from" => $from,
            "size" => $size,
        );
        $urlSuffix = "contact_lists_2/phone/_search";
        return $this->call('POST', $urlSuffix, $query);
    }
    
    public function getEmailLists_hashed( ){
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 200000;
        $query = array(
            "from" => $from,
            "size" => $size,
        );
        $urlSuffix = "contact_lists_2/email/_search";
        return $this->call('POST', $urlSuffix, $query);
    }
    
    public function getPhoneLists( ){
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 200000;
        $query = array(
            "from" => $from,
            "size" => $size,
        );
        $urlSuffix = "contact_lists/phone/_search";
        return $this->call('POST', $urlSuffix, $query);
    }
    
    public function getEmailLists( ){
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 200000;
        $query = array(
            "from" => $from,
            "size" => $size,
        );
        $urlSuffix = "contact_lists/email/_search";
        return $this->call('POST', $urlSuffix, $query);
    }
    
    public function findFriends( $params ){
        $hashedNumber = isset( $params->hashed_number ) ? $params->hashed_number : '';
        $hashedList = isset( $params->hashed_list ) ? $params->hashed_list : array();
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 100;
        
        $should = array();
        
        // this portion sets up the search query for matching the
        // passed list to the current hashed-numbers for our volley users
        foreach( $hashedList as $hashedPhoneNumber ){
            $should[] = array(
                "term" => array( "hashed_number" => $hashedPhoneNumber )
            );
            $should[] = array(
                "term" => array( "hashed_list" => $hashedPhoneNumber )
            );
        }
        
        // this part will search the hashed_list field
        // using the users number that we got from twilio
        if( $hashedNumber ){
            $should[] = array(
                "term" => array( "hashed_list" => $hashedNumber )
            );
        }
        
        $query = array(
            "from" => $from,
            "size" => $size,
            "query" => array(
                "bool" => array(
                    "should" => $should,
                    "minimum_number_should_match" => 1
                )
            ),
            "partial_fields" => array(
                "_source" => array(
                    "exclude" => "hashed_list"
                )
            )
        );
        
        $urlSuffix = "contact_lists/phone/_search";
        
        return $this->call('POST', $urlSuffix, $query);
        
    }
    
    public function findFriendsEmail( $params ){
        $email = isset( $params->email ) ? $params->email : '';
        $emailList = isset( $params->email_list ) ? $params->email_list : array();
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 100;
        
        $should = array();
        
        // this portion sets up the search query for matching the
        // passed list to the current hashed-numbers for our volley users
        foreach( $emailList as $emailAddy ){
            $should[] = array(
                "term" => array( "email" => $emailAddy )
            );
        }
        
        // this part will search the email_list field
        // using the users number that we got from twilio
        if( $email ){
            $should[] = array(
                "term" => array( "email_list" => $email )
            );
        }
        
        $query = array(
            "from" => $from,
            "size" => $size,
            "query" => array(
                "bool" => array(
                    "should" => $should,
                    "minimum_number_should_match" => 1
                )
            ),
            "partial_fields" => array(
                "_source" => array(
                    "exclude" => "email_list"
                )
            )
        );
        
        $urlSuffix = "contact_lists/email/_search";
        
        //print_r( array( json_encode($query), $urlSuffix) ); exit;
        
        return $this->call('POST', $urlSuffix, $query);
        
    }
    
    public function addPhoneList( $doc ){
        $added = false;
        if( isset( $doc->id ) ){
            $hashed_list = isset( $doc->hashed_list ) && $doc->hashed_list ? $doc->hashed_list : array();
            if( ! isset( $doc->hashed_list ) || ! is_array($doc->hashed_list)  ){
                $doc->hashed_list = array();
            }
            $urlSuffix = "contact_lists/phone/$doc->id/_create";
            $added = $this->call('PUT', $urlSuffix, $doc);
            $added = json_decode( $added );
            if( isset( $added->ok ) && $added->ok ){
                $added = true;
            } else {
                $added = false;
            }
        }
        return $added;
    }
    
    public function putPhoneList( $doc ){
        $added = false;
        if( isset( $doc->id ) ){
            if( empty( $doc->hashed_list ) || ! is_array($doc->hashed_list)  ){
                $doc->hashed_list = array();
            }
            $urlSuffix = "contact_lists_2/phone/$doc->id";
            $added = $this->call('PUT', $urlSuffix, $doc);
            $added = json_decode( $added );
            if( isset( $added->ok ) && $added->ok ){
                $added = true;
            } else {
                $added = false;
            }
        }
        return $added;
    }
    
    public function updatePhoneList( $params ){
        $hashedNumber = isset( $params->hashed_number ) ? $params->hashed_number : '';
        $hashedList = isset( $params->hashed_list ) ? $params->hashed_list : array();
        $userId = isset( $params->id ) ? $params->id : '';
        
        $update = array(
            'script' => "
            	var merged = new HashMap();
            	
            	if( ctx._source.containsKey('hashed_list') && ctx._source.hashed_list is ArrayList ){
            		foreach( number : ctx._source.hashed_list ){
            			merged.put( number, true );
            		}
            	}
            	
            	foreach( number : hashed_list ){
            		merged.put( number, true );
            	}
            	
            	ctx._source.hashed_list = new ArrayList( merged.keySet() );
            	
            	if( hashed_number != empty ){
            		ctx._source.hashed_number = hashed_number;
            	}
            	
            	;
            ",
            'params' => array(
                'hashed_list' => $hashedList,
                "hashed_number" => $hashedNumber,
            )
        );
        
        
        if( $hashedNumber ){
            $update['params']['hashed_number'] = $hashedNumber;
        }
        
        
        $urlSuffix = "contact_lists/phone/$userId/_update";
        
        $res = $this->call('POST', $urlSuffix, $update);
    }
    
    public function getPhoneList( $params ){
        $userId = isset( $params->id ) ? $params->id : '';
        $urlSuffix = "contact_lists/phone/$userId";
        return $this->call('GET', $urlSuffix);
    }
    
    public function addEmailList( $doc ){
        $added = false;
        if( isset( $doc->id ) ){
            $email_list = isset( $doc->email_list ) && $doc->email_list ? $doc->email_list : array();
            if( ! isset( $doc->email_list ) || ! is_array($doc->email_list)  ){
                $doc->email_list = array();
            }
            $urlSuffix = "contact_lists/email/$doc->id/_create";
            $added = $this->call('PUT', $urlSuffix, $doc);
            $added = json_decode( $added );
            if( isset( $added->ok ) && $added->ok ){
                $added = true;
            } else {
                $added = false;
            }
        }
        return $added;
    }
    
    public function updateEmailList( $params ){
        $hashedNumber = isset( $params->email ) ? $params->email : '';
        $hashedList = isset( $params->email_list ) ? $params->email_list : array();
        $userId = isset( $params->id ) ? $params->id : '';
        
        $update = array(
            'script' => "
            	var merged = new HashMap();
            	
            	if( ctx._source.containsKey('email_list') && ctx._source.email_list is ArrayList ){
            		foreach( number : ctx._source.email_list ){
            			merged.put( number, true );
            		}
            	}
            	
            	foreach( number : email_list ){
            		merged.put( number, true );
            	}
            	
            	ctx._source.email_list = new ArrayList( merged.keySet() );
            	
            	if( email != empty ){
            		ctx._source.email = email;
            	}
            	
            	;
            ",
            'params' => array(
                'email_list' => $hashedList,
                "email" => $hashedNumber,
            )
        );
        
        if( $hashedNumber ){
            $update['params']['email'] = $hashedNumber;
        }
        
        $urlSuffix = "contact_lists/email/$userId/_update";
        $res = $this->call('POST', $urlSuffix, $update);
    }
    
    public function getEmailList( $params ){
        $userId = isset( $params->id ) ? $params->id : '';
        $urlSuffix = "contact_lists/email/$userId";
        return $this->call('GET', $urlSuffix);
    }

}