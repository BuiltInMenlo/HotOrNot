<?php
require_once 'vendor/autoload.php';

$volley = BIM_Model_Volley::get( 37728 );
$user = BIM_Model_User::get(13240);
$challengerId = BIM_Model_User::get(13219);

// push tests below
BIM_Push::shoutoutPush($volley);