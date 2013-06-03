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
}