<?php
require_once 'vendor/autoload.php';

try{
    $routines = new BIM_Growth_Tumblr_Routines( 'exty86' );
    $routines->loginAndBrowseSelfies();
} catch( Exception $e ){
    print_r( $e );
}

//$o->followUser( $user );