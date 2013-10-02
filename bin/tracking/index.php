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

    $params['referer'] = !empty($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : '';
    $params['user_agent'] = !empty($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '';

    $params = (object) $params;    
    $app = new BIM_App_G();
    $app->trackClick($params);
    
    header('Location: http://letsvolley.com');

}

?>
