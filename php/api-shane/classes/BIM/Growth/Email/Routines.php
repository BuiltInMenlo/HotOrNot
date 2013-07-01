<?php

class BIM_Growth_Email_Routines extends BIM_Growth_Email{
    
    public function __construct( $persona ){
        $this->persona = $persona;
    }
    
    /*
    	'to_email' => 'shane@shanehill.com',
    	'to_name' => 'leyla',
    	'from_email' => 'test@shanehill.com',
    	'from_name' => 'Foogery',
    	'subject' => 'email test',
    	'html' => 'test',
     */
    
    public function emailInvites(){
        $addys = explode('|', $this->persona->email->addresses );
        
        $msgs = BIM_Config::inviteMsgs();
        
        $emailData = BIM_Config::growthEmailInvites();
        $emailData->text = !empty($msgs['email']) ? $msgs['email'] : '';
        
        foreach( $addys as $addy ){
            $emailData->to_email = $addy;
            $e = new BIM_Email_Swift();
            $e->sendEmail( $emailData );
        }
    }
}
