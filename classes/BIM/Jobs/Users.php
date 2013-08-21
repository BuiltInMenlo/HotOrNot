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
        
        // @jason has added you as a friend
        $msg = "$user->username has added you as a friend";
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
    
    /**
     * 
     * @param int $userId - id odf the user that signed up
     */
    public static function queueVolleySignupVerificationPush( $userId ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'volleySignupVerificationPush',
        	'data' => (object) array('user_id' => $userId),
        );
        
        return self::queueBackground( $job, 'push' );
    }
    
    public function volleySignupVerificationPush( $workload ){
        
        $userIds = BIM_Model_User::getRandomIds( 50, array( $workload->data->user_id ) );
        $users = BIM_Model_User::getMulti($userIds);
        
        $deviceTokens = array();
        foreach( $users as $user ){
            if( $user->canPush() ){
                $deviceTokens[] = $user->device_token;
            }
        }
        
        $push = array(
            "device_tokens" => $deviceTokens, 
            "aps" =>  array(
                "alert" =>  "$user->username has joined Volley and needs to be checked out",
                "sound" =>  "push_01.caf"
            )
        );
        
        BIM_Push_UrbanAirship_Iphone::sendPush($push);
        
    }
}