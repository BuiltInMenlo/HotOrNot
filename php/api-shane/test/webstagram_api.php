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
    'Ariannaxoxoluver'
);


foreach( $usernames as $username ){
    try{
        $routines = new BIM_Growth_Webstagram_Routines( $username );
        // $routines->login();
        $routines->browseTags();
        // print_r( $routines->volleyUserPhotoComment() );
        // print_r( json_decode( $routines->comment( "nice one", $media ) ) );
    } catch( Exception $e ){
        print_r( $e );
    }
}
