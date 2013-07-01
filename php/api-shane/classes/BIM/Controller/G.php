<?php

class BIM_Controller_G extends BIM_Controller_Base {
    
    public function init(){
        $this->growth = new BIM_App_G();
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
