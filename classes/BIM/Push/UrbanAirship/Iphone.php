<?php

class BIM_Push_UrbanAirship_Iphone{
    
    public static function sendPushBatch( $push ){
        $conf = BIM_Config::urbanAirship();
        $pushStr = json_encode($push);
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $conf->api->push_url);
        curl_setopt($ch, CURLOPT_USERPWD, $conf->api->pass_key );
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $pushStr);
        $res = curl_exec($ch);
        $err_no = curl_errno($ch);
        $err_msg = curl_error($ch);
        $header = curl_getinfo($ch);
        curl_close($ch);
    }
    
    public static function sendPush( $push ){
        $conf = BIM_Config::urbanAirship();
        if( !is_object($push->device_tokens) && !is_array($push->device_tokens) ){
            $push->device_tokens = array( $push->device_tokens );
        }
        $tokens = $push->device_tokens;
        foreach( $tokens as $token ){
            $push->device_tokens = array( $token );
            $pushStr = json_encode($push);
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $conf->api->push_url);
            curl_setopt($ch, CURLOPT_USERPWD, $conf->api->pass_key );
            curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $pushStr);
            $res = curl_exec($ch);
            $err_no = curl_errno($ch);
            $err_msg = curl_error($ch);
            $header = curl_getinfo($ch);
            curl_close($ch);
        }
    }
}