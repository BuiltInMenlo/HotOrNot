<?php 

class BIM_DAO_ElasticSearch_ContactLists extends BIM_DAO_ElasticSearch {
    
    public function findFriends( $params ){
        $hashedNumber = isset( $params->hashed_number ) ? $params->hashed_number : '';
        $hashedList = isset( $params->hashed_list ) ? $params->hashed_list : '';
        $from = isset( $params->from ) ? $params->from : 0;
        $size = isset( $params->size ) ? $params->size : 100;
        
        $should = array();
        
        // this portion sets up the search query for matching the
        // passed list to the current hashed-numbers for our volley users
        foreach( $hashedList as $hashedPhoneNumber ){
            $should[] = array(
                "term" => array( "hashed_number" => $hashedPhoneNumber )
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
            )
        );
        
        $urlSuffix = "contact_lists/phone/_search";
        
        return $this->call('POST', $urlSuffix, $query);
    }
    
    public function addList( $doc ){
        if( isset( $params->user_id ) ){
            $urlSuffix = "contact_lists/phone/$params->user_id";
            $this->call('PUT', $urlSuffix, $doc);
        }
    }
    
    public function updateList( $params ){
        $hashed_number = isset( $params->hashed_number ) ? $params->hashed_number : '';
        $hashed_list = isset( $params->hashed_list ) ? $params->hashed_list : '';
        $userId = isset( $params->user_id ) ? $params->user_id : '';
        
        $update = array(
            'script' => "
            	_ctx.source.hashed_list = hashed_list;
            ",
            'params' => array(
                'hashed_list' => $hashed_list
            )
        );        
        $urlSuffix = "contact_lists/phone/$userId";
        $this->call('POST', $urlSuffix, $update);
    }
    
    public function getList( $params ){
        $userId = isset( $params->user_id ) ? $params->user_id : '';
        $urlSuffix = "contact_lists/phone/$userId";
        return $this->call('GET', $urlSuffix);
    }
    
}