<?php 
require_once 'vendor/autoload.php';

$msg = "another timed message";
$push = array(
	"device_tokens" =>  array( '66595a3b5265b15305212c4e06d1a996bf3094df806c8345bf3c32e1f0277035' ), 
	"type" => "3", 
	"aps" =>  array(
		"alert" =>  $msg,
		"sound" =>  "push_01.caf"
    )
);

$delay = mt_rand(30,120);
$pushTime = time() + $delay;

$j = new BIM_App_Challenges();
$j->createTimedPush($push, $pushTime);
