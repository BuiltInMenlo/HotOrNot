<?php
require_once 'vendor/autoload.php';

$persona = (object) array(
    'name' => 'shanehill00',
    'type' => 'volley',
    'instagram' => (object) array(
    	'email' => 'shanehill00@gmail.com',
    	'username' => 'shanehill00',
    	'password' => 'i8ngot6',
    ),
    'tumblr' => (object) array(
    	'email' => 'exty86@gmail.com',
    	'username' => 'exty86',
    	'password' => 'i8ngot6',
    	'userid' => 'exty86',
    	'blogName' => 'exty86.tumblr.com',
    )
);

// leyla - 37438644
//$user = (object) array( 'id' => 37438644 );

// shane - 37459491
//$user = (object) array( 'id' => 37459491 );

// http://fargobauxn.tumblr.com/
$persona = new BIM_Growth_Persona( $persona );
$routines = new BIM_Growth_Instagram_Routines( $persona );

// fed2208ec99f11e2af6f22000a1f9a09_7
//$media = (object) array( 'id' => 'fed2208ec99f11e2af6f22000a1f9a09_7' );

try{
    $link = 'http://getvolleyapp.com/ooh/ooh56';
    $routines->dropLinkInBio($link);
//    print_r( $routines->volleyUserPhotoComment() );
//    print_r( json_decode( $routines->comment( "nice one", $media ) ) );
} catch( Exception $e ){
    print_r( $e );
}

