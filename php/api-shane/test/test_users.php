<?php
require_once 'vendor/autoload.php';

/*

$params = (object) array(
    'user_id' => 881,
    'hashed_number' => 'hash999',
    'hashed_list' => array('hash666','hash9','hash3','hash665'),
);

$params = (object) array(
    'user_id' => 882,
    // 'hashed_number' => 'hash666',
    'hashed_list' => array('hash666_7','hash9_7','hash999','hash665_7'),
);

$users = new BIM_App_Users();
$friends = $users->matchFriends( $params );

print_r( $friends );

*/

$params = array(
    'AccountSid' => 'ACb76dc4d9482a77306bc7170a47f2ea47',
    'Body' => 
    "
    Sign me up bitches
    
    c1251cc4c72b4ee8
    
    ",
    'ToZip' => '34109',
    'FromState' => 'CA',
    'ToCity' => 'NAPLES',
    'SmsSid' => 'SM0014f9ec1d891dfca69d2d3a7eee43d2',
    'ToState' => 'FL',
    'To' => '+12394313268',
    'ToCountry' => 'US',
    'FromCountry' => 'US',
    'SmsMessageSid' => 'SM0014f9ec1d891dfca69d2d3a7eee43d2',
    'ApiVersion' => '2010-04-01',
    'FromCity' => 'SAN FRANCISCO',
    'SmsStatus' => 'received',
    'From' => '+14152549392',
    'FromZip' => '94930',
);

$users = new BIM_App_Users();
$users->linkMobileNumber( (object) $params );

