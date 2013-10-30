<?php
require_once 'vendor/autoload.php';
$requestPath = isset( $_SERVER['REQUEST_URI'] ) ? $_SERVER['REQUEST_URI'] : '';
$build = 'live';
$ptrn = '@^.*?/boot_(\w+).*?$@';
if( preg_match($ptrn,$requestPath) ){
    $build = preg_replace($ptrn, '$1', $requestPath);
}
header('Cache-Control:no-store',false);
header('Cache-Control:no-cache',false);
header('Cache-Control:max-age=0',false);
header('Expires: Thu, 01 Dec 1994 16:00:00 GMT',false);
header('Pragma: no-cache',false);
echo BIM_App_Config::getBootConf( array('type' => $build ) );
