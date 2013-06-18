<?php
require_once 'vendor/autoload.php';

$usernames = array(
    'exty86',
);

foreach( $usernames as $username ){
    try{
        $routines = new BIM_Growth_Askfm_Routines( $username );
        $routines->browseQuestions();
    } catch( Exception $e ){
        print_r( $e );
    }
}
