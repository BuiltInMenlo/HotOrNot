<?php 

class BIM_Growth_Tumblr{
    /**
     * retrieve all selfies and put them in a db keyed by the objectId
     * we go int seconds into the past
     * we store the whole blob for use later
     * 
     * starting with now() we itearte until the timestamp of the last item of a fetch is smaller than the timestamp in the config
     * 
     */
    public function harvestSelfies(){
        $c = BIM_Config::tumblr();
        $q = new Tumblr\API\Client($c->api->consumerKey, $c->api->consumerSecret);
        
        $before = time();
        $options = array( 'before' => $before );
        $minTime = $before - $c->harvestSelfies->secsInPast;
        $maxItems = $c->harvestSelfies->maxItems;
        $n = 1;
        $itemsRetrieved = 0;
        
        while( ($before >= $minTime) && $itemsRetrieved <= $maxItems ){
            $selfies = $q->getTaggedPosts('selfie', $options);
            $itemsRetrieved += count( $selfies );
            
            foreach( $selfies as $selfie ){
                $this->saveSelfie($selfie);
                // pass to a save selfie method
                if( $selfie->timestamp < $before ){
                    $before = $selfie->timestamp;
                }
            }
            $n++;
            $options['before'] = $before;
        }
    }
    
    public function saveSelfie( $selfie ){
        $sql = "insert into tumblr_selfies (id,data) values(?,?) on duplicate key update data = ?";
        $db = new BIM_DAO_Mysql( BIM_Config::db() );
        $json = json_encode( $selfie );
        $params = array( $selfie->id, $json, $json );
        $db->prepareAndExecute( $sql, $params, true );
    }
}