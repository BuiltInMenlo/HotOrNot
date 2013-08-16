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
    
    /**
Your friend @[[USERNAME]] has invited you to Volley! A fast and fun way to connect and trade pics.

hit [[USERNAME]] up @[[USERNAME]] http://getvolleyapp.com/e/e

Thanks! 
- Team Volley
www.letsvolley.com
     */
    
    public function emailInvites(){
        $addys = explode('|', $this->persona->email->addresses );
        
        $msgs = BIM_Config::inviteMsgs();
        
        $emailData = BIM_Config::growthEmailInvites();
        $emailData->text = !empty($msgs['email']) ? $msgs['email'] : '';
        
        $user = new BIM_Model_User( $this->persona->email->userId );
        $emailData->text = preg_replace('@\[\[USERNAME\]\]@', $user->username, $emailData->text);
        
        foreach( $addys as $addy ){
            $emailData->to_email = $addy;
            $e = new BIM_Email_Swift( BIM_Config::smtp() );
            $e->sendEmail( $emailData );
        }
    }
}
