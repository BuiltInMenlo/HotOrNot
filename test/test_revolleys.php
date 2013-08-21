<?php 
/*
print_r(
    json_encode(
        $push = array(
            "device_tokens" =>  array( '66595a3b5265b15305212c4e06d1a996bf3094df806c8345bf3c32e1f0277035' ), 
            "type" => "1", 
            "challenge" => 1345, 
            "aps" =>  array(
                "alert" =>  "@jason has created the volley #wow",
                "sound" =>  "push_01.caf"
            )
        )
    )
);
*/
require_once 'vendor/autoload.php';

//BIM_App_Challenges::processReVolleys();
BIM_App_Challenges::redistributeVolleys();