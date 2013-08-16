<?php

class BIM_Controller_G extends BIM_Controller_Base {
    
    public function trackClick( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        if( isset( $input->click ) ){
            $parts = explode('/',$input->click );
            $ct = count($parts);
            if( $ct > 1 ){
                $params = array();
                
                $idx = $ct - 2;
                $params->network_id = $parts[$idx];
                
                $idx = $ct - 1;
                $params->persona_name = $parts[$idx];
            }
        }
        $growth = new BIM_App_G();
        return $growth->trackClick( $params );
    }
    
    public function smsInvites( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        $growth = new BIM_App_G();
        return $growth->smsInvites( $input );
    }

    public function emailInvites( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        $growth = new BIM_App_G();
        return $growth->emailInvites( $input );
    }
    
    public function volleyUserPhotoComment( ){
        $input = (object) ($_POST ? $_POST : $_GET);
        $growth = new BIM_App_G();
        return $growth->volleyUserPhotoComment( $input );
    }
}
