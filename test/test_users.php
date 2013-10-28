<?php
require_once 'vendor/autoload.php';

$user = BIM_Model_User::get( 13284 );
echo $user->ageOK();

//testTwilioCallback();

function testnotes(){

    $job = array(
    	'class' => 'BIM_Jobs_Users',
    	'method' => 'friendAcceptedNotification',
    	'data' => (object) array(
            'user_id' => 882,
            'friend_id' => 881,
        ),
    );
    
    $u = new BIM_Jobs_Users();
    $u->friendAcceptedNotification( (object) $job );
    
}

function testFindFriendsQ(){

    $job = array(
    	'class' => 'BIM_Jobs_Users',
    	'method' => 'findFriends',
    	'data' => (object) array(
            'hashed_number' => '+14152549391',
            'id' => 881
        ),
    );
    
    $u = new BIM_Jobs_Users();
    
    $u->findFriends( (object) $job );
    
}

function testFriendmatching(){
    /*
    $params = (object) array(
        'user_id' => 881,
        'hashed_number' => 'hash999',
        'hashed_list' => array('hash666','hash9','hash3','hash665'),
    );
    */
    
    $params = (object) array(
        'id' => 882,
        'hashed_number' => '+14152549393',
        'hashed_list' => array('hash666_7','hash9_7','+14152549391','hash665_7'),
    );
    
    $users = new BIM_App_Users();
    $friends = $users->matchFriends( $params );
    
    print_r( json_encode( $friends ) );
}

function testTwilioCallback(){
    $id = '881';
    
    print_r( $smsCode = BIM_Utils::getSMSCodeForId( $id ) );
    print_r("\n");
    print_r( BIM_Utils::getIdForSMSCode( $smsCode ) );
    print_r("\n");
    
    $params = array(
        'AccountSid' => 'ACb76dc4d9482a77306bc7170a47f2ea47',
        'Body' => "
    
     this is a message $smsCode",
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
        'From' => '+14152549391',
        'FromZip' => '94930',
    );
    
    $users = new BIM_App_Users();
    $users->linkMobileNumber( (object) $params );
}
