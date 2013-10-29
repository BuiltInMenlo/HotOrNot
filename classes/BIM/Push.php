<?php 
class BIM_Push{
    
    public static function queuePush( $push ){
        $job = array(
        	'class' => 'BIM_Push',
        	'method' => 'sendQueuedPush',
        	'push' => $push
        );
        //BIM_Push_UrbanAirship_Iphone::sendPush( $push );
        return BIM_Jobs::queueBackground( $job, 'push' );
    }
    
    public function sendQueuedPush( $workload ){
        BIM_Push_UrbanAirship_Iphone::sendPush( $workload->push );
    }
    
    public static function createTimedPush( $time, $jobId = null, $tokens, $msg, $pushType = null, $volleyId = null, $userId = null ){
        $time = new DateTime("@$time");
        $time = $time->format('Y-m-d H:i:s');
        
        $params = (object) array(
            'tokens' => $tokens, 
            'msg' => $msg, 
            'type' =>  $pushType, 
            'volley_id' => $volleyId,
            'user_id' =>  $userId
        );
        
        $job = (object) array(
            'nextRunTime' => $time,
            'class' => 'BIM_Push',
            'method' => 'sendTimedPush',
            'name' => 'push',
            'params' => $params,
            'is_temp' => true,
        );
        
        if( !empty( $jobId ) ){
            // create an id that we can use to remove and cancel the job later
            $job->id = $jobId;
        }
        
        $j = new BIM_Jobs_Gearman();
        $j->createJbb($job);
    }
    
    public function sendTimedPush( $workload ){
        $push = json_decode($workload->params);
        $tokens = $push->tokens ? $push->tokens : array();
        $msg = $push->msg ? $push->msg : '';
        $type = !is_null( $push->type ) ? $push->type : null;
        $volleyId = !is_null( $push->volley_id ) ? $push->volley_id : null;
        $userId = !is_null( $push->user_id ) ? $push->user_id : null;
        BIM_Push::send( $tokens, $msg, $type, $volleyId, $userId );
    }
    
    public static function send( $ids, $msg, $type = null, $volleyId = null, $userId = null ){
        if( !is_array($ids) ){
            $ids = array( $ids );
        }
        $push = (object) array(
            'device_tokens' => $ids,
            "aps" => array(
                "alert" => $msg,
                "sound" => "push_01.caf"
            )
        );
        
        if( $userId !== null ){
            $push->user = $userId;
        }
        
        if( $volleyId !== null ){
            $push->challenge = $volleyId;
        }
        
        if( $type !== null ){
            $push->type = $type;
        }
        
        self::queuePush($push); 
    }
    
    public static function shoutoutPush( $volley ){
        $user = BIM_Model_User::get($volley->creator->id);
        $msg = "Yo! Your Selfie got a shoutout from Team Volley!";
        if( $user->canPush() && !empty( $user->device_token ) ){
            self::send($user->device_token, $msg ); 
        }
    }
    
    public static function pushCreators( $volleys ){
        if( !is_array($volleys)){
            $volleys = array( $volleys );
        }
        $creators = array();
        foreach ($volleys as $volley){
            $creators[] = $volley->creator->id;
        }
        $users = BIM_Model_User::getMulti($creators);
        $msg = "Your Volley had made it to the top of the Explore section! Tap or swipe to view.";
        foreach( $users as $user ){
            if( $user->canPush() && !empty( $user->device_token ) ){
                self::send($user->device_token, $msg ); 
            }
        }
    }
    
    public static function pokePush( $pokerId, $targetId ){
        $poker = BIM_Model_User::get($pokerId);
        $target = BIM_Model_User::get($targetId);
        $msg = "@$poker->username has poked you!";
        $type = 2;
        self::send($target->device_token, $msg, $type ); 
    }
    
	public static function sendFlaggedPush( $targetId ){
    	$target = BIM_Model_User::get( $targetId );
        if( $target->canPush() ){
            $msg = "Your Volley profile has been flagged";
            if( $target->isSuspended() ){
                $msg = "Your Volley profile has been suspended";
            }
            $type = 3;
            self::send($target->device_token, $msg, $type ); 
        }
	}
	
	public static function sendApprovePush( $targetId ){
    	$target = BIM_Model_User::get( $targetId );
        if( $target->canPush() ){
            if( $target->isApproved() ){
                $msg = "Awesome! You have been Volley Verified! Would you like to share Volley with your friends?";
            } else {
                $msg = "Your Volley profile has been verified by another Volley user! Would you like to share Volley with your friends?";
            }
            $type = 2;
            self::send($target->device_token, $msg, $type ); 
        }
	}
	
	/**
	 * 
	 * @param int $targetId usr bring flagged
	 * @param array[int] $userIds - list of users to push
	 */
	public static function sendFirstRunPush( $userIds, $targetId ){
	    
	    $userIds[] = $targetId;
        $users = BIM_Model_User::getMulti($userIds, true);
        $target = $users[ $targetId ];
        unset( $users[ $targetId ] );
        
        $deviceTokens = array();
        foreach( $users as $user ){
            if( $user->canPush() ){
                $deviceTokens[] = $user->device_token;
            }
        }
        
        if( $deviceTokens ){
            $msg = "A new user just joined Volley, can you verify them? @$target->username";
            $type = 3;
            self::send($deviceTokens, $msg, $type ); 
        }
	}
	
    public static function emailVerifyPush( $userId ){
        $user = BIM_Model_User::get( $userId );
        $msg = "Volley on! Your Volley account has been verified!";
        self::send( $user->device_token, $msg );
    }
    
    public static function matchPush( $userId, $friendId ){
        $user = BIM_Model_User::get( $userId );
        $friend = BIM_Model_User::get( $friendId );
        $msg = "Your friend $user->username joined Volley!";
        self::send( $friend->device_token, $msg );
    }
    
    public static function commentPush( $userId, $volleyId ){
        $volley = BIM_Model_Volley::get($volleyId);
        $commenter = BIM_Model_User::get($userId);
        $creator = BIM_Model_User::get( $volley->creator->id );

        $userIds = $volley->getUsers();
	    $users = BIM_Model_User::getMulti( $userIds );
	    
	    $deviceTokens = array();
	    foreach( $users as $user ){
	        $deviceTokens[] = $user->device_token;
	    }
        
		// send push if creator allows it
		if ($creator->notifications == "Y" && $creator->id != $userId){
            $msg = "$commenter->username has commented on your $volley->subject snap!";
		    $type = 3;
            self::send($creator->device_token, $msg, $type ); 
		}
    }
    
    public static function likePush( $likerId, $targetId, $volleyId ){
	    $volley = BIM_Model_Volley::get($volleyId);
		$liker = BIM_Model_User::get( $likerId );
		$target = BIM_Model_User::get( $targetId );
		$msg = "@$liker->username liked your Volley $volley->subject";
		if( $volley->subject == '#__verifyMe__' ){
		    $msg = "Your profile selfie has been liked by @$liker->username";
		}
	    $type = 1;
        self::send($target->device_token, $msg, $type ); 
    }
    
    public static function doVolleyAcceptNotification( $volleyId, $targetId ){
        $targetUser = BIM_Model_User::get($targetId);
        $volleyObject = BIM_Model_Volley::get($volleyId);
        
        $time = time() + 86400;
        $time = $time - ( $time % 86400 );
        $secondPushTime = $time + (3600 * 17);
        $thirdPushTime = $secondPushTime + (3600 * 9);
        
        $msg = "@$targetUser->username has joined the Volley $volleyObject->subject";
        $pushType = 6;
        
        $users = BIM_Model_User::getMulti( $volleyObject->getUsers() );
        foreach( $users as $user ){
            if( $user->canPush() && ($targetUser->id != $user->id) ){
                self::send( $user->device_token, $msg, $pushType, $volleyObject->id );
                
                //$jobId = join( '_', array('v', $user->id, $volleyObject->id, uniqid(true) ) );
                //self::createTimedPush( $secondPushTime, $jobId, $user->device_token, $msg, $pushType, $volleyObject->id );
                
                //$jobId = join( '_', array('v', $user->id, $volleyObject->id, uniqid(true) ) );
                //self::createTimedPush( $thirdPushTime, $jobId, $user->device_token, $msg, $pushType, $volleyObject->id );
            }
        }
    }
    
    public static function sendVolleyNotifications( $volleyId ){
        $volley = BIM_Model_Volley::get( $volleyId );
        $creator = BIM_Model_User::get($volley->creator->id);
        $targetIds = $volley->getUsers();
        $targets = BIM_Model_User::getMulti($targetIds);
        foreach( $targets as $target ){
            if ( $target->isExtant() && $target->notifications == "Y"){
                $msg = "@$creator->username has just created the Volley $volley->subject";
                $type = 1;
                self::send($target->device_token, $msg, $type, $volleyId ); 
            }
        }
    }
    
    public static function reVolleyPush( $volleyId, $challengerId ){
        $challenger = BIM_Model_User::get($challengerId);
        // send push if allowed
        if ( $challenger->canPush() ){
            $volley = BIM_Model_Volley::get($volleyId);
            $creator = BIM_Model_User::get($volley->creator->id);
            $private = $volley->is_private == 'Y' ? ' private' : '';
            $msg = "@$creator->username has sent you a$private Volley. $volley->subject";
            $type = 1;
            self::send($challenger->device_token, $msg, $type, $volley->id ); 
        }
    }
    
    public static function friendNotification( $userId, $friendId ){
        $user = BIM_Model_User::get( $userId );
        $friend = BIM_Model_User::get( $friendId );
        $msg = "@$user->username has subscribed to your Volley updates!";
        $type = 3;
        self::send($friend->device_token, $msg, $type, null, $user->id ); 
    }
    
    public static function friendAcceptedNotification( $userId, $friendId ){
        $user = BIM_Model_User::get( $userId );
        $friend = BIM_Model_User::get( $friendId );
        $msg = "$user->username accepted your friend request on Volley!";
        self::send( $friend->device_token, $msg );
    }
    
    public static function volleySignupVerificationPush( $userId ){
        $userIds = BIM_Model_User::getRandomIds( 50, array( $userId ) );
        $users = BIM_Model_User::getMulti($userIds);
        $deviceTokens = array();
        foreach( $users as $user ){
            if( $user->canPush() ){
                $deviceTokens[] = $user->device_token;
            }
        }
        $msg = "$user->username has joined Volley and needs to be checked out";
        self::send($deviceTokens, $msg);
    }
    
    public static function introPush( $userId, $targetId, $pushTime ){
        $user = BIM_Model_User::get($userId);
        $target = BIM_Model_User::get($targetId);
        $msg = "@$user->username has subscribed to your Volleys!";
        self::createTimedPush( $pushTime, null, $target->device_token, $msg, null );
    }
    
    public static function selfieReminder( $userId ){
        $user = BIM_Model_User::get($userId);
        $msg = "Volley reminder! Please update your selfie to get verfied. No adults allowed!";
        self::send($user->device_token, $msg);
    }
}