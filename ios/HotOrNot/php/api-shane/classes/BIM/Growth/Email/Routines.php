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
        foreach( $addys as $addy ){
            
            $emailData = BIM_Config::growthEmailInvites();
            $emailData->text = $this->getInviteMsg();
            $emailData->to_email = $addy;
            
            $e = new BIM_Email_Swift();
            $e->sendEmail( $emailData );
        }
    }
    
    public function getInviteMsg(){
        return "hmu on volley sexy boy";
    }
    
}
