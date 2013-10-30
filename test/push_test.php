<?php
require_once 'vendor/autoload.php';

$volley = BIM_Model_Volley::get( 37845 );
$user = BIM_Model_User::get( 13306 );
$challenger = BIM_Model_User::get( 13219 );

/*
$workload = (object) array(
    'params' => '{"tokens":"'.$challenger->device_token.'","msg":"@yy has subscribed to your Volleys!","type":null,"volley_id":null,"user_id":null}'
);
$p = new BIM_Push();
$p->sendTimedPush($workload);
*/

// push tests below
//BIM_Push::shoutoutPush($volley);
//BIM_Push::pushCreators($volley);
//BIM_Push::pokePush($user->id,$challenger->id);
//BIM_Push::commentPush($challenger->id, $volley->id);
//BIM_Push::doVolleyAcceptNotification($volley->id, $challenger->id);
//BIM_Push::emailVerifyPush($user->id);
//BIM_Push::friendAcceptedNotification($user->id, $challenger->id);
//BIM_Push::friendNotification($challenger->id, $user->id);
//BIM_Push::introPush($user->id, $challenger->id, time() );
//BIM_Push::likePush($user->id, $challenger->id, $volley->id);
//BIM_Push::matchPush($user->id, $challenger->id);
//BIM_Push::reVolleyPush($volley->id, $challenger->id);
//BIM_Push::selfieReminder($user->id);
//BIM_Push::sendApprovePush($user->id);
//BIM_Push::sendFirstRunPush(array($user->id), $challenger->id);
//BIM_Push::sendFlaggedPush($user->id);
//BIM_Push::sendVolleyNotifications($volley->id);
// -- this one is dangerous as fuck -- BIM_Push::volleySignupVerificationPush($user->id);