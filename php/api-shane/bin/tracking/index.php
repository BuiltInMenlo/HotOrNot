<?php
require_once 'vendor/autoload.php';

$parts = explode('/', $_SERVER['SCRIPT_URL'] );
$ct = count($parts);
if( $ct > 1 ){
    
    $params = array();
    
    $idx = $ct - 2;
    $params['network_id'] = $parts[$idx];
    
    $idx = $ct - 1;
    $params['persona_name'] = $parts[$idx];
    
    $app = new BIM_App_G();
    $app->trackClick($params);
    
    if( $params['network_id'] == 'a' ){
        header('Location: http://letsvolley.com');
    }

}

?>