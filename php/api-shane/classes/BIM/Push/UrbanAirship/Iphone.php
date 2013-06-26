<?php

class BIM_Push_UrbanAirship_Iphone{
    
    public static function send( $ids, $msg ){
        $conf = BIM_Config::urbanAirship();
        if( !is_array($ids) ){
            $ids = array( $ids );
        }
        $push = array(
            'device_tokens' => $ids,
            'type' =>  1,
            "aps" => array(
                "alert" => $msg,
                "sound" => "push_01.caf"
            )
        );
        
        print_r( array( $push, $conf ) );
        
        $push = json_encode($push);
        
		// curl urban airship's api
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $conf->api->push_url);
		curl_setopt($ch, CURLOPT_USERPWD, $conf->api->pass_key ); // live
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $push);
	 	$res = curl_exec($ch);
		$err_no = curl_errno($ch);
		$err_msg = curl_error($ch);
		$header = curl_getinfo($ch);
		curl_close($ch);
    }
    
}