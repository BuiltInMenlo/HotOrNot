<?php
require_once 'vendor/autoload.php';

$volley = BIM_Model_Volley::get( 25690 );
$creator = BIM_Model_User::get( 881 );
$targetUser = BIM_Model_User::get( 882 );

$a = new BIM_App_Challenges(); 
$a->doAcceptNotification($volley, $creator, $targetUser);

/**
foreach ( array(881) as $id ){
    $workload = (object) array(
        'data' => (object) array(
            'user_id' => $id
        )
    );
    
    $j = new BIM_Jobs_Growth();
    
    $j->emailVerifyPush($workload);
}
**/