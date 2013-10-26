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
	        BIM_Push::matchPush( $list->id, $match->id );
	    }
    }

    public static function queueFirstRunComplete( $userId ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'firstRunComplete',
        	'data' => (object) array('user_id' => $userId ),
        );
        
        return self::queueBackground( $job, 'firstruncomplete' );
    }
    
    public function firstRunComplete( $workload ){
        $u = new BIM_App_Users();
        $u->firstRunComplete( $workload->data->user_id );
    }
    
    public static function queueFlagUser( $userId, $approves, $targetId ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'flagUser',
        	'input' => (object) array(
        					'userID' => $userId,
                            'approves' => $approves,
                            'targetID' => $targetId
                        ),
        );
        return self::queueBackground( $job, 'flaguser' );
    }
    
    public function flagUser( $workload ){
        $input = $workload->input;
        $users = new BIM_App_Users();
	    $users->flagUser( $input->userID, $input->approves, $input->targetID );
    }
    
    public static function queuePurgeUserVolleys( $userId ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'purgeUserVolleys',
        	'input' => (object) array(
        					'userID' => $userId,
                        ),
        );
        return self::queueBackground( $job, 'purgeuservolleys' );
    }
    
    public function purgeUserVolleys( $workload ){
        $user = BIM_Model_User::get( $workload->input->userID );
        $user->purgeVolleys();
    }
    
    /*
     * PROCESS PROFILE IMAGES
     */
    public static function queueProcessProfileImages( $userId ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'processProfileImages',
        	'data' => array( 'user_id' => $userId ),
        );
        return self::queueBackground( $job, 'process_profile_images' );
    }
	
    public function processProfileImages( $workload ){
        BIM_Model_User::processProfileImages( array( $workload->data->user_id ) );
    }
    
    /*
     * PROCESS IMAGE
     */
    public static function queueProcessImage( $imgUrl ){
        $job = array(
        	'class' => 'BIM_Jobs_Users',
        	'method' => 'processImage',
        	'data' => array( 'img_url' => $imgUrl ),
        );
        return self::queueBackground( $job, 'process_image' );
    }
	
    public function processImage( $workload ){
        BIM_Utils::processUserImage( $workload->data->img_url );
    }
}