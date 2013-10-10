<?php
require_once 'vendor/autoload.php';

$usernames = array(
    'getvolleyapp',
);


foreach( $usernames as $username ){
    try{
        $routines = new BIM_Growth_Webstagram_Routines( $username );
        $routines->handleLogin();
        $routines->like('561768380304082102_27241168');
	    $sleep = 1;
	    echo "updated user stats. sleeping for $sleep secs\n";
    } catch( Exception $e ){
        print_r( $e );
    }
}
