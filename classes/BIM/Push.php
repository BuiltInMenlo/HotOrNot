<?php 
class BIM_Push{
    
    public static function queuePush( $push ){
        $job = array(
        	'class' => 'BIM_Push',
        	'method' => 'sendQueuedPush',
        	'push' => $push
        );
        return BIM_Jobs::queueBackground( $job, 'push' );
    }
    
    public function sendQueuedPush( $workload ){
        BIM_Push_UrbanAirship_Iphone::sendPush( $workload->push );
    }
    
    public static function createTimedPush( $push, $time, $jobId = null ){
        $time = new DateTime("@$time");
        $time = $time->format('Y-m-d H:i:s');
        
        $job = (object) array(
            'nextRunTime' => $time,
            'class' => 'BIM_Push',
            'method' => 'sendTimedPush',
            'name' => 'push',
            'params' => $push,
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
        self::queuePush( $push );
    }
    
    public static function send( $ids, $msg ){
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
        self::queuePush($push); 
    }
    
    public static function shoutoutPush( $volley ){
        $user = BIM_Model_User::get($volley->creator->id);
        $msg = "Yo! Your Selfie got a shoutout from Team Volley!";
        if( $user->canPush() && !empty( $user->device_token ) ){
            $push = (object) array(
                'device_tokens' => $user->device_token,
                "aps" => array(
                    "alert" => $msg,
                    "sound" => "push_01.caf"
                )
            );
            self::queuePush($push); 
        }
    }
    
    public static function pushCreators( $volleys ){
        $creators = array();
        foreach ($volleys as $volley){
            $creators[] = $volley->creator->id;
        }
        $users = BIM_Model_User::getMulti($creators);
        $msg = "Your Selfie was promoted in Volley!";
        foreach( $users as $user ){
            if( $user->canPush() && !empty( $user->device_token ) ){
                $push = (object) array(
                    'device_tokens' => $user->device_token,
                    "aps" => array(
                        "alert" => $msg,
                        "sound" => "push_01.caf"
                    )
                );
                self::queuePush($push); 
            }
        }
    }
    
    public static function pokePush( $pokerId, $targetId ){
        $poker = BIM_Model_User::get($pokerId);
        $target = BIM_Model_User::get($targetId);
        $msg = "@$poker->username has poked you!";
		$push = array(
	    	"device_tokens" =>  array( $target->device_token ), 
	    	"type" => "2",
	    	"aps" =>  array(
	    		"alert" =>  $msg,
	    		"sound" =>  "push_01.caf"
	        )
	    );
        self::queuePush($push);
    }
    
	public static function sendFlaggedPush( $targetId ){

    	$target = BIM_Model_User::get( $targetId );
        if( $target->canPush() ){
            
            // Your Volley profile has been flagged
            
            $msg = "Your Volley profile has been flagged";
            if( $target->isSuspended() ){
                $msg = "Your Volley profile has been suspended";
            }
            $push = array(
                "device_tokens" =>  $target->device_token, 
                "type" => "3", 
                "aps" =>  array(
                    "alert" =>  $msg,
                    "sound" =>  "push_01.caf"
                )
            );
            
            self::queuePush($push);
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
            $push = array(
                "device_tokens" => $target->device_token,
                "type" => 2,
                "aps" =>  array(
                    "alert" => $msg,
                    "sound" => "push_01.caf"
                )
            );
            self::queuePush($push);
        }
	}
	
	/**
	 * 
	 * @param int $targetId usr bring flagged
	 * @param array[int] $userIds - list of users to push
	 */
	public static function sendFirstRunPush( $userIds, $targetId ){
	    
	    $userIds[] = $targetId;
        $users = BIM_Model_User::getMulti($userIds);
        $target = $users[ $targetId ];
        unset( $users[ $targetId ] );
        
        $deviceTokens = array();
        foreach( $users as $user ){
            if( $user->canPush() ){
                $deviceTokens[] = $user->device-token;
            }
        }
        
        if( $deviceTokens ){
            $msg = "A new user just joined Volley, can you verify them? @$target->username";
            $push = array(
                "device_tokens" => $deviceTokens, 
                "type" => "3", 
                "aps" =>  array(
                    "alert" =>  $msg,
                    "sound" =>  "push_01.caf"
                )
            );
            
            self::queuePush($push);
        }
	}
	
    public static function emailVerifyPush( $userId ){
        $user = new BIM_Model_User( $userId );
        $msg = "Volley on! Your Volley account has been verified!";
        self::send( $user->device_token, $msg );
    }
    
    public static function matchPush( $userId, $friendId ){
        $user = new BIM_Model_User( $userId );
        $friend = new BIM_Model_User( $friendId );
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
			$push = array(
		    	"device_tokens" =>  $deviceTokens, 
		    	"type" => "3", 
		    	"aps" =>  array(
		    		"alert" =>  $msg,
		    		"sound" =>  "push_01.caf"
		        )
		    );
    	    self::queuePush( $push );
		}
    }
    
    public static function likePush( $likerId, $targetId, $volleyId ){
	    $volley = BIM_Model_Volley::get($volleyId);
		$liker = BIM_Model_User::get( $likerId );
		$target = BIM_Model_User::get( $targetId );
		// @jason liked your Volley #WhatsUp"
		$msg = "@$liker->username liked your Volley $volley->subject";
		if( $volley->subject == '#__verifyMe__' ){
		    $msg = "Your profile selfie has been liked by @$liker->username";
		}
		$push = array(
	    	"device_tokens" =>  $target->device_token, 
	    	"type" => "1",
		    "challenge" => $volleyId, 
	    	"aps" =>  array(
	    		"alert" =>  $msg,
	    		"sound" =>  "push_01.caf"
	        )
	    );
	    self::queuePush( $push );
    }
    
    public static function doVolleyAcceptNotification( $volleyId, $targetId ){
        $targetUser = BIM_Model_User::get($targetId);
        $volleyObject = BIM_Model_Volley::get($volleyId);
        $msg = "@$targetUser->username has joined the Volley $volleyObject->subject";
        
        $push = array(
            "type" => "6",
            "challenge" => $volleyObject->id,
            "aps" =>  array(
                "alert" =>  $msg,
                "sound" =>  "push_01.caf"
            )
        );
        
        $time = time() + 86400;
        $time = $time - ( $time % 86400 );
        $secondPushTime = $time + (3600 * 17);
        $thirdPushTime = $secondPushTime + (3600 * 9);
        
        $users = BIM_Model_User::getMulti( $volleyObject->getUsers() );
        foreach( $users as $user ){
            if( $user->canPush() && ($targetUser->id != $user->id) ){
                $push["device_tokens"] =  array( $user->device_token );
                self::queuePush( $push );
                
                //$jobId = join( '_', array('v', $user->id, $volleyObject->id, uniqid(true) ) );
                //self::createTimedPush($push, $secondPushTime, $jobId );
                
                //$jobId = join( '_', array('v', $user->id, $volleyObject->id, uniqid(true) ) );
                //self::createTimedPush($push, $thirdPushTime,  $jobId );
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
                $push = array(
                    "device_tokens" =>  array( $target->device_token ), 
                    "type" => "1",
                    "challenge" => $volleyId,
                    "aps" =>  array(
                        "alert" =>  $msg,
                        "sound" =>  "push_01.caf"
                    )
                );
                self::queuePush( $push );
            }
        }
    }
    
    public static function reVolleyPush( $volleyId, $challengerId ){
        $challenger = BIM_Model_User::get($challengerId);
        // send push if allowed
        if ($challenger->notifications == "Y"){
            $volley = BIM_Model_Volley::get($volleyId);
            $creator = BIM_Model_User::get($volley->creator->id);
            
            $private = $volley->is_private == 'Y' ? ' private' : '';
            $msg = "@$creator->username has sent you a$private Volley. $volley->subject";
             
            $push = array(
                //"device_tokens" =>  array( '66595a3b5265b15305212c4e06d1a996bf3094df806c8345bf3c32e1f0277035' ), 
                "device_tokens" =>  array( $challenger->device_token ), 
                "type" => "1", 
                "challenge" => $volley->id, 
                "aps" =>  array(
                    "alert" =>  $msg,
                    "sound" =>  "push_01.caf"
                )
            );
            self::queuePush( $push );
        }
    }
    
    public static function friendNotification( $userId, $friendId ){
        // now we perform a search and send out push notification
        $user = BIM_Model_User::get( $userId );
        $friend = BIM_Model_User::get( $friendId );
        
        $msg = "@$user->username has subscribed to your Volley updates!";
        $push = array(
            "device_tokens" => $friend->device_token,
            "type" => 3,
            "user" => $user->id, 
            "aps" =>  array(
                "alert" => $msg,
                "sound" => "push_01.caf"
            )
        );
        self::queuePush($push);
    }
    
    public static function friendAcceptedNotification( $userId, $friendId ){
        // now we perform a search and send out push notification
        $user = BIM_Model_User::get( $userId, true );
        $friend = BIM_Model_User::get( $friendId, true );
        
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
        
        $push = array(
            "device_tokens" => $deviceTokens, 
            "aps" =>  array(
                "alert" =>  "$user->username has joined Volley and needs to be checked out",
                "sound" =>  "push_01.caf"
            )
        );
        
        self::queuePush($push);
    }
    
    public static function introPush( $userId, $targetId, $pushTime ){
        $user = BIM_Model_User::get($userId);
        $target = BIM_Model_User::get($targetId);
        $msg = "@$user->username has subscribed to your Volleys!";
        $push = array(
            "device_tokens" =>  array( $target->device_token ),
            "aps" =>  array(
                "alert" =>  $msg,
                "sound" =>  "push_01.caf"
            )
        );
        self::createTimedPush($push, $pushTime);
    }
    
    public static function selfieReminder( $userId ){
        $user = BIM_Model_User::get($userId);
        $msg = "Volley reminder! Please update your selfie to get verfied. No adults allowed!";
        $push = array(
            "device_tokens" => $user->device_token,
            "aps" =>  array(
                "alert" => $msg,
                "sound" => "push_01.caf"
            )
        );
        self::queuePush($push);
    }
}