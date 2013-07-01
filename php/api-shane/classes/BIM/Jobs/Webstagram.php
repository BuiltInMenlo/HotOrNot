<?php 

class BIM_Jobs_Webstagram extends BIM_Jobs{
    
    /*
     * SUBMIT COMMENT JOB - the user
     */
    
    /**
     * 
     * @param int|string $userId - volley user id
     * @param string $user - instagram username
     * @param string $pass - instagram password
     */
    public static function queueInstaInvite( $params ){
        $params->network = 'instagram';
        $job = (object) array(
        	'class' => 'BIM_Jobs_Webstagram',
        	'method' => 'instaInvite',
        	'data' => $params
        );
        return self::queueBackground( $job, 'insta_invite' );
    }
	
    public function instaInvite( $workload ){
        $routines = new BIM_Growth_Webstagram_Routines( $workload->data );
        $routines->instaInvite();
    }
}