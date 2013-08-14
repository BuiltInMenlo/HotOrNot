<?php 

class BIM_Jobs_Instagram extends BIM_Jobs{
    
    /*
     * SUBMIT COMMENT JOB - the user
     */
    
    /**
     * 
     * @param int|string $userId - volley user id
     * @param string $user - instagram username
     * @param string $pass - instagram password
     */
    public function queueVolleyUserPhotoComment( $userId, $user, $pass ){
        $job = array(
        	'class' => 'BIM_Jobs_Instagram',
        	'method' => 'volleyUserPhotoComment',
        	'data' => array( 'volleyUserId' => $userId, 'username' => $user, 'password' => $pass ),
        );
        return $this->enqueueBackground( $job, 'growth' );
    }
	
    public function volleyUserPhotoComment( $workload ){
        $persona = (object) array(
            'instagram' => $workload->data
        );

        $persona = new BIM_Growth_Persona( $persona );
        $routines = new BIM_Growth_Instagram_Routines( $persona );
        
        $routines->volleyUserPhotoComment();
    }
    
    public static function queueLinkInBio( $params ){
        $job = (object) array(
        	'class' => __CLASS__,
        	'method' => 'linkInBio',
        	'data' => $params
        );
        return self::queueBackground( $job, 'insta_invite' );
    }
	
    public function linkInBio( $workload ){
        $user = new BIM_Model_User( $workload->data->volley_user_id );
        $persona = (object) array(
            'name' => $user->username,
            'type' => 'volley',
            'instagram' => (object) array(
                'password' => $workload->data->password,
                'username' => $workload->data->username,
                'name' => $user->username
            )
        );
        $routines = new BIM_Growth_Instagram_Routines( $persona );
        $conf = BIM_Config::instagram();
        
        $routines->dropLinkInBio( $conf->link_for_bio );
    }
}