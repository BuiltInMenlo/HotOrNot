<?php
require_once 'vendor/autoload.php';

$persona = (object) array(
    'tumblr' => (object) array(
    	'email' => 'exty86@gmail.com',
    	'username' => 'exty86',
    	'password' => 'i8ngot6',
    	'userid' => 'exty86',
    	'blogName' => 'exty86.tumblr.com',
    )
);

$user = (object) array(
	'blogUrl' => 'http://fargobauxn.tumblr.com/',
);

// http://fargobauxn.tumblr.com/
$persona = new BIM_Growth_Persona( $persona );
$routines = new BIM_Growth_Tumblr_Routines( $persona );

try{
    $routines->login();
    $routines->browseSelfies();
} catch( Exception $e ){
    print_r( $e );
}

//$o->followUser( $user );