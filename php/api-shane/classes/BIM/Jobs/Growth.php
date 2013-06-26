<?php 

class BIM_Jobs_Growth extends BIM_Jobs{
    
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
        
        return $this->enqueueBackground( $job, 'growth' );
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
        
        return $this->enqueueBackground( $job, 'growth' );
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
    
    public function queueMatchPush( $data ){
        $job = array(
        	'class' => 'BIM_Jobs_Growth',
        	'method' => 'matchPush',
        	'data' => (object) array( 
                'user_id' => $data->user_id,
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
        $user = new BIM_User( $workload->data->user_id );
        $msg = "Jason u getitng these?";
            BIM_Push_UrbanAirship_Iphone::send( $user->device_token, $msg );
        }
}