<?php
require_once 'vendor/autoload.php';

$usernames = array(
    'jennyBartenxoxo',
    'Becky1999xoxo',
    'kelly1998xoxo',
    'idabmack7',
    'Michellexoxox1999',
    'Maria1999xoxo',
    'kellycalirules',
    'SophiaSwagXoxo',
    'Chloe1999xoxo',
);


foreach( $usernames as $username ){
    try{
        $routines = new BIM_Growth_Webstagram_Routines( $username );
        $routines->updateUserStats();
	    $sleep = 1;
	    echo "updated user stats. sleeping for $sleep secs\n";
    } catch( Exception $e ){
        print_r( $e );
    }
}
