<?php 

class BIM_Jobs_Users extends BIM_Jobs{
    
    /**
     * 
     * @param int|string $userId - volley user id
     * @param array $addresses - list of email addresses, pipe delimited
     */
    public static function queueFindfFriends( $list ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'findFriends',
        	'data' => $list,
        );
        
        return self::queueBackground( $job, 'find_friends' );
    }
	
    public function findFriends( $workload ){
        // now we perform a search and send out push notification
        $list = $workload->data;
        $users = new BIM_App_Users;
        $matches = $users->findfriends($list);
        $j = new BIM_Jobs_Growth();
	    foreach( $matches as $match ){
	        $j->queueMatchPush( $match, $list );
	    }
    }
}