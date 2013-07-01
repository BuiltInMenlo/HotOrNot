<?php
require_once 'vendor/autoload.php';

try{

    $job = (object) array(
    	'class' => 'BIM_Jobs_Webstagram',
    	'method' => 'instaInvite',
    	'data' => (object) array(
            'name' => 'shanehill00',
            'type' => 'volley',
            'instagram' => (object) array(
                'username' => 'shanehill00',
                'password' => 'i8ngot6',
                'name' => 'shanehill00',
            )
        )
    );
    $routines = new BIM_Growth_Webstagram_Routines( $job->data );
    $routines->instaInvite();

} catch( Exception $e ){
    print_r( $e );
}
