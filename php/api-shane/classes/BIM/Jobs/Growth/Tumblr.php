<?php 

class BIM_Jobs_Growth_Tumblr extends BIM_Jobs_Growth{
    public function doRoutines( $workload ){
        $params = json_decode( $workload->params );
        $personaName = '';
        if( $params->personaName ){
            $personaName = $params->personaName;
        }
        $method = $params->method;
        $r = new BIM_Growth_Tumblr_Routines( $personaName );
        $r->$method();
    }    
}