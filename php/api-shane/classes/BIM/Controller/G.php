<?php

class BIM_Controller_G extends BIM_Controller_Base {
    
    public function init(){
        $this->growth = new BIM_App_G();
    }
    
    public function trackClick( ){
        if( isset( $this->input['click'] ) ){
            $parts = explode('/',$this->input['click'] );
            $ct = count($parts);
            if( $ct > 1 ){
                $idx = $ct - 2;
                $this->input['network_id'] = $parts[$idx];
                
                $idx = $ct - 1;
                $this->input['persona_name'] = $parts[$idx];
            }
        }
        return $this->growth->trackClick( $this->input );
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
