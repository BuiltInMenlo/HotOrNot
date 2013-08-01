<?php 

class BIM_Growth_Tumblr extends BIM_Growth{
    /**
     * retrieve all selfies and put them 
     * in a db keyed by the objectId
     * 
     * we go int seconds into the past
     * we store the whole blob for use later
     * 
     * starting with now() we itearte until the timestamp 
     * of the last item of a fetch is smaller than the 
     * timestamp in the config or until we retrieve 0 selfies
     * 
     */
    public function harvestSelfies(){
        $c = BIM_Config::tumblr();
        $q = new Tumblr\API\Client($c->api->consumerKey, $c->api->consumerSecret);
        
        $maxItems = $c->harvestSelfies->maxItems;
        $n = 1;
        $itemsRetrieved = 0;
        foreach( $c->harvestSelfies->tags as $tag ){
            echo "gathering posts for tag '$tag'\n";
            $before = time();
            $minTime = $before - $c->harvestSelfies->secsInPast;
            
            $options = array( 'before' => $before );
            $selfies = $q->getTaggedPosts( $tag, $options );
            while( $selfies && ($before >= $minTime) && $itemsRetrieved <= $maxItems ){
                $itemsRetrieved += count( $selfies );
                echo "got $itemsRetrieved items in $n pages\n";            
                foreach( $selfies as $selfie ){
                    $this->saveSelfie($selfie);
                    if( $selfie->timestamp < $before ){
                        $before = $selfie->timestamp;
                    }
                }
                $n++;
                $options['before'] = $before;
                $selfies = $q->getTaggedPosts( $tag, $options );
            }
        }
    }
    
    public function saveSelfie( $selfie ){
        $db = new BIM_DAO_Mysql( BIM_Config::db() );
        
        $json = json_encode( $selfie );
        $timestamp = $selfie->timestamp;
        $params = array( $selfie->id, $timestamp, $json, $json, $timestamp );
        
        $sql = "
        	insert into tumblr_selfies 
        	(`id`,`time`,`data`) values(?,?,?) 
        	on duplicate key update `data` = ?, `time` = ?
        	";
        $db->prepareAndExecute( $sql, $params, true );
    }
}