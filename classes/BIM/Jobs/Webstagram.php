<?php 

class BIM_Jobs_Webstagram extends BIM_Jobs{
    
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
    public static function queueInstaInvite( $params ){
        $job = (object) array(
        	'class' => 'BIM_Jobs_Webstagram',
        	'method' => 'instaInvite',
        	'data' => $params
        );
        return self::queueBackground( $job, 'insta_invite' );
    }
	
    public function instaInvite( $workload ){
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
        $routines = new BIM_Growth_Webstagram_Routines( $persona );
        $routines->instaInvite();
    }
}