<?php
require_once 'vendor/autoload.php';

try{

    $data = (object) array(
        'data' => (object) array(
            'username' => 'shanehill00',
            'password' => 'i8ngot6',
            'volley_user_id' => 881,
        )
    );
    
    $j = new BIM_Jobs_Webstagram();
    
    $j->instaInvite($data);

} catch( Exception $e ){
    print_r( $e );
}
