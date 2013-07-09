<?php
require_once 'vendor/autoload.php';

$usernames = array(
    'idabmack7',
);

foreach( $usernames as $username ){
    try{
        $routines = new BIM_Growth_Askfm_Routines( $username );
        $routines->handleLogin();
        print_r( $routines->doIdSearch(10) );
    } catch( Exception $e ){
        print_r( $e );
    }
}
