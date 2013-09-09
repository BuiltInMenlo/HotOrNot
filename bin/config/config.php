<?php
require_once 'vendor/autoload.php';

$conf = isset( $_SERVER['SCRIPT_NAME'] ) ? $_SERVER['SCRIPT_NAME'] : '';
$type = 'live';
if( preg_match( '/dev/', $conf ) ){
    $type = 'dev';
} else if( preg_match( '/122/', $conf ) ){
    $type = '122';
} else if( preg_match( '/123/', $conf ) ){
    $type = '123';
} else if( preg_match( '/124/', $conf ) ){
    $type = '124';
}
echo BIM_App_Config::getBootConf( array('type' => $type ) );
