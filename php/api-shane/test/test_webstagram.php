<?php
require_once 'vendor/autoload.php';

try{

    $data = (object) array(
        'data' => (object) array(
            'username' => 'becky1999xoxo',
            'password' => 'teamvolleypassword',
            'volley_user_id' => 2456,
        )
    );
    
    $j = new BIM_Jobs_Webstagram();
    
    $j->instaInvite($data);

} catch( Exception $e ){
    print_r( $e );
}
