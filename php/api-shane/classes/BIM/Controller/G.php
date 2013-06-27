<?php

class BIM_Controller_G extends BIM_Controller_Base {
    
    public function init(){
        $this->growth = new BIM_App_G();
    }
    
    public function handleReq(){
        
        // action was specified
        $input = isset($_POST['action']) ? $_POST: null;
        if( !$input ){
        	$input = isset($_GET['action']) ? $_GET : null;
        }
        $this->input = $input;
        if ( $input['action'] ) {
        	switch ( $input['action'] ) {
        		// get list of challenges by votes
        		case "1":
        			return $this->smsInvites();
        		
        		// get challenges for a subject
        		case "2":
    				return $this->emailInvites();
        			
        		// get specific challenge				
        		case "3":
    				return $this->trackClick();
        			
        		// get a list of challenges by date
        		case "4":
        		    return $this->volleyUserPhotoComment();
        	}
        }
    }
    
    public function trackClick( ){
        if( isset( $_GET['click'] ) ){
            $parts = explode('/',$_GET['click'] );
            $ct = count($parts);
            if( $ct > 1 ){
                $params = array();
                
                $idx = $ct - 2;
                $params['network_id'] = $parts[$idx];
                
                $idx = $ct - 1;
                $params['persona_name'] = $parts[$idx];
            }
        }
        return $this->growth->trackClick( $params );
    }
    
    public function smsInvites( ){
        return $this->growth->smsInvites( $this->input );
    }

    public function emailInvites( ){
        return $this->growth->emailInvites( $this->input );
    }
    
    public function volleyUserPhotoComment( ){
        return $this->growth->volleyUserPhotoComment( $this->input );
    }
}
