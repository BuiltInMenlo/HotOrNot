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
        $user = new BIM_Model_User( $this->persona->sms->userId );
        $msg = preg_replace('@\[\[USERNAME\]\]@', $user->username, $msg);
        $sms = $client->account->sms_messages->create( $conf->api->number, $number, $msg );
    }
    
    public function getTxtMsg(){
        $msgs = BIM_Config::inviteMsgs();
        return !empty($msgs['sms']) ? $msgs['sms'] : '';
    }
    
    // we take the list of phone numbers and
    // return all matches to numbers in our db
    public function matchNumbers( $numbers ){
        $dao = new BIM_DAO_Mysql_Growth( BIM_Config::db() );
        return $dao->matchNumbers( $numbers );
    }
    
}
