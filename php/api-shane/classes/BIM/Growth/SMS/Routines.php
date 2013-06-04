<?php

class BIM_Growth_SMS_Routines extends BIM_Growth_SMS{
    
    public function __construct( $persona ){
        $this->persona = $persona;
    }
    
    public function smsInvites(){
        $numbers = explode('|', $this->persona->sms->numbers );
        foreach( $numbers as $number ){
            $this->sendSMSInvite( $number );
        }
    }
    
    public function sendSMSInvite( $number ){
        $client = $this->getTwilioClient();
        $conf = BIM_Config::twilio();
        
        $number = preg_replace('/\.\s\-\+/', '', $number);
        $number = "+$number";
     
        $msg = $this->getTxtMsg();
        $sms = $client->account->sms_messages->create( $conf->api->number, $number, $msg );
    }
    
    public function getTxtMsg(){
        return $this->persona->sms->inviteMsg;
    }
}
