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
        $input = $_POST ? $_POST : $_GET;
        return $this->growth->smsInvites( $input );
    }

    public function emailInvites( ){
        $input = $_POST ? $_POST : $_GET;
        return $this->growth->emailInvites( $input );
    }
    
    public function volleyUserPhotoComment( ){
        $input = $_POST ? $_POST : $_GET;
        return $this->growth->volleyUserPhotoComment( $input );
    }
}
