<?php 

class BIM_Jobs_Growth extends BIM_Jobs{
    
    public static function queueCreateCampaign( $params ){
        $job = array(
        	'class' => 'BIM_Jobs_Growth',
        	'method' => 'createCampaign',
        	'data' => $params
        );
        
        return self::queueBackground( $job, 'createcampaign' );
    }
	
    public function createCampaign( $workload ){
        BIM_Growth::createCampaign($workload->data);
    }
    
    /**
     * 
     * @param int|string $userId - volley user id
     * @param array $addresses - list of email addresses, pipe delimited
     */
    public function queueEmailInvites( $userId, $addresses ){
        $job = array(
        	'class' => 'BIM_Jobs_Growth',
        	'method' => 'emailInvites',
        	'data' => array( 'userId' => $userId, 'addresses' => $addresses ),
        );
        
        return $this->enqueueBackground( $job, 'smsinvites' );
    }
	
    public function emailInvites( $workload ){
        $persona = (object) array(
            'email' => $workload->data
        );
        
        $persona = new BIM_Growth_Persona( $persona );
        $routines = new BIM_Growth_Email_Routines( $persona );
        
        $routines->emailInvites();
    }
    
    public function queueSMSInvites( $userId, $numbers ){
        $job = array(
        	'class' => 'BIM_Jobs_Growth',
        	'method' => 'smsInvites',
        	'data' => array( 
    		    'userId' => $userId, 
    		    'numbers' => $numbers,
    		    'inviteMsg' => "Thanks for signing up for Volley! (iOS app) You have been chosen to be apart of our test group. Sign up here: http://bit.ly/letsvolley"
            ),
        );
        
        return $this->enqueueBackground( $job, 'smsinvites' );
    }
	
    public function smsInvites( $workload ){
        $persona = (object) array(
            'sms' => $workload->data
        );
        
        $persona = new BIM_Growth_Persona( $persona );
        $routines = new BIM_Growth_SMS_Routines( $persona );
        
        $routines->smsInvites();
    }
    
    public function doRoutines( $workload ){
        $params = json_decode( $workload->params );
        $personaName = '';
        if( $params->personaName ){
            $personaName = $params->personaName;
        }
        $class = $params->class;
        if( isset( $params->routine ) && method_exists($class, $params->routine ) ){
            $routine = $params->routine;
            $r = new $class( $personaName );
            $r->$routine();
        } else {
            echo "problem when executing tumblr routines it appears the the routine does not exist or was not defined in the workload:\n\n".print_r($workload,1);
        }
    }
    
    public static function queueEmailVerifyPush( $params ){
        $job = array(
        	'class' => 'BIM_Jobs_Growth',
        	'method' => 'emailVerifyPush',
        	'data' => (object) array( 
                'user_id' => $params->user_id,
            ),
        );
        return self::queueBackground( $job, 'push' );
    }
    
    public function emailVerifyPush( $workload ){
        $user = new BIM_Model_User( $workload->data->user_id );
        $msg = "Volley on! Your Volley account has been verified!";
        BIM_Push_UrbanAirship_Iphone::send( $user->device_token, $msg );
    }
    
    public function queueMatchPush( $friend, $user ){
        $job = array(
        	'class' => 'BIM_Jobs_Growth',
        	'method' => 'matchPush',
        	'data' => (object) array( 
                'user_id' => $user->id,
                'friend_id' => $friend->id,
            ),
        );
        return $this->enqueueBackground( $job, 'match_push' );
    }
    
    /**
        $msg = "@$creator_obj->username has sent you a $private Volley!";
    	$this->sendPush('{"device_tokens": ["'. $challenger_obj->device_token .'"], "type":"1", "aps": {"alert": "'.$msg.'", "sound": "push_01.caf"}}');
    	
    	we get the users data
    	get the device token
    	send the push
    	
     */
    public function matchPush( $workload ){
        $user = new BIM_Model_User( $workload->data->user_id );
        $friend = new BIM_Model_User( $workload->data->friend_id );
        $msg = "Your friend $user->username joined Volley!";
        BIM_Push_UrbanAirship_Iphone::send( $friend->device_token, $msg );
    }
}