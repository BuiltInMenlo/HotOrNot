<?php
require_once 'vendor/autoload.php';

/*
$params = (object) array(
    'user_id' => 881,
    'hashed_number' => 'hash999',
    'hashed_list' => array('hash666','hash9','hash3','hash665'),
);
*/
$params = (object) array(
    'user_id' => 882,
    // 'hashed_number' => 'hash666',
    'hashed_list' => array('hash666_7','hash9_7','hash999','hash665_7'),
);

$users = new BIM_App_Users();
$friends = $users->matchFriends( $params );

print_r( $friends );
