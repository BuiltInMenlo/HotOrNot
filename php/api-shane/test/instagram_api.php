<?php
require_once 'vendor/autoload.php';

try{
    $routines = new BIM_Growth_Instagram_Routines( 'exty86' );
    $routines->loginAndAuthorizeApp();
    // print_r( $routines->volleyUserPhotoComment() );
    // print_r( json_decode( $routines->comment( "nice one", $media ) ) );
} catch( Exception $e ){
    print_r( $e );
}

