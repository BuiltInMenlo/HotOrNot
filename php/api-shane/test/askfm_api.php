<?php
require_once 'vendor/autoload.php';

$usernames = array(
    'bouncyxoxo',
);

foreach( $usernames as $username ){
    try{
        $routines = new BIM_Growth_Askfm_Routines( $username );
        $routines->answerQuestions();
    } catch( Exception $e ){
        print_r( $e );
    }
}
