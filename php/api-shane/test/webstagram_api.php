<?php
require_once 'vendor/autoload.php';

try{
    $routines = new BIM_Growth_Webstagram_Routines( 'instachromeapp' );
    // $routines->login();
    $routines->browseTags();
    // print_r( $routines->volleyUserPhotoComment() );
    // print_r( json_decode( $routines->comment( "nice one", $media ) ) );
} catch( Exception $e ){
    print_r( $e );
}

