<?php 

class BIM_Jobs_Users extends BIM_Jobs{
    
    /**
     * 
     * @param int|string $userId - volley user id
     * @param array $addresses - list of email addresses, pipe delimited
     */
    public static function queueFindFriends( $list ){
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
    
    public static function queueFriendNotification( $userId, $friendId ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'friendNotification',
        	'data' => (object) array('user_id' => $userId, 'friend_id' => $friendId ),
        );
        
        return self::queueBackground( $job, 'friend_notification' );
    }
    
    public function friendNotification( $workload ){
        // now we perform a search and send out push notification
        $user = BIM_App_Base::getUser( $workload->data->user_id );
        $friend = BIM_App_Base::getUser( $workload->data->friend_id );
        
        $msg = "$user->username sent you a friend request on Volley!";
        BIM_Push_UrbanAirship_Iphone::send( $friend->device_token, $msg );
        
    }
    
    public static function queueFriendAcceptedNotification( $userId, $friendId ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'friendAcceptedNotification',
        	'data' => (object) array('user_id' => $userId, 'friend_id' => $friendId ),
        );
        
        return self::queueBackground( $job, 'friend_notification' );
    }
    
    public function friendAcceptedNotification( $workload ){
        // now we perform a search and send out push notification
        $user = BIM_App_Base::getUser( $workload->data->user_id );
        $friend = BIM_App_Base::getUser( $workload->data->friend_id );
        
        $msg = "$user->username accepted your friend request on Volley!";
        BIM_Push_UrbanAirship_Iphone::send( $friend->device_token, $msg );
        
    }
}