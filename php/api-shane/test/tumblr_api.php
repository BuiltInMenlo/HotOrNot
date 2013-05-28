<?php
require_once 'vendor/autoload.php';

$persona = (object) array(
    'tumblr' => (object) array(
    	'email' => 'exty86@gmail.com',
    	'username' => 'exty86',
    	'password' => 'i8ngot6',
    	'userid' => 'exty86',
    )
);

$user = (object) array(
	'blogUrl' => 'http://fargobauxn.tumblr.com/',
);

// http://fargobauxn.tumblr.com/
$p = new BIM_Growth_Persona( $persona );

$o = new BIM_Growth_Tumblr_Routines( $p );

$o->login();
$o->followUser( $user );