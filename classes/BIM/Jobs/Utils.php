<?php 

class BIM_Jobs_Utils extends BIM_Jobs{
    
    public static function queuePush( $push ){
        $job = array(
        	'class' => 'BIM_Jobs_Utils',
        	'method' => 'doPush',
        	'push' => $push
        );
        return self::queueBackground( $job, 'push' );
    }
    
    public function doPush( $workload ){
        //print_r( $workload );
        BIM_Push_UrbanAirship_Iphone::sendPush( $workload->push );
    }
}