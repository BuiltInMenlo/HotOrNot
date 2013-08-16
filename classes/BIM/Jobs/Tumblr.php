<?php 

class BIM_Jobs_Tumblr extends BIM_Jobs{
    
    /*
     * SUBMIT COMMENT JOB - the user
     */
    
    /**
     * 
		(object) array(
            'name' => 'shanehill00',
            'type' => 'volley',
            'instagram' => (object) array(
                'username' => 'shanehill00',
                'password' => 'i8ngot6',
                'name' => 'shanehill00',
            )
        )
     * 
     * @param int|string $userId - volley user id
     * @param string $user - instagram username
     * @param string $pass - instagram password
     */
    public static function queueInvite( $params ){
        $job = (object) array(
        	'class' => 'BIM_Jobs_Tumblr',
        	'method' => 'invite',
        	'data' => $params
        );
        return self::queueBackground( $job, 'tumblr_invite' );
    }
	
    public function invite( $workload ){
        $user = new BIM_Model_User( $workload->data->volley_user_id );
        $persona = (object) array(
            'name' => $workload->data->username,
            'type' => 'volley',
            'instagram' => (object) array(
                'password' => $workload->data->password,
                'username' => $workload->data->username,
                'name' => $user->username
            )
        );
        $routines = new BIM_Growth_Tumblr_Routines( $persona );
        $routines->invite();
    }
}