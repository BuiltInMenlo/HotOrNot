<?php
require_once 'vendor/autoload.php';

$requestPath = isset( $_SERVER['REQUEST_URI'] ) ? $_SERVER['REQUEST_URI'] : '';
$ptrn = '@^.*?/boot_(\w+).*?$@';
if( preg_match($ptrn,$requestPath) ){
    $build = preg_replace($ptrn, '$1', $requestPath);
    echo BIM_App_Config::getBootConf( array('type' => $build ) );
}
