<?php

class BIM_App_G extends BIM_App_Base{
    
    public function volleyUserPhotoComment( $params ){
        if( isset($params['userId']) && isset($params['username']) && isset($params['password']) ){
            $o = new BIM_Jobs_Instagram();
            return $o->queueVolleyUserPhotoComment($params['userId'], $params['username'], $params['password']);
        }
    }
    
    public function emailInvites( $params ){
        if( isset( $params['userId']) && isset($params['addresses'] ) ){
            $o = new BIM_Jobs_Growth();
            return $o->queueEmailInvites( $params['userId'], $params['addresses'] );
        }
    }
    
    public function smsInvites( $params ){
        if( isset( $params['userId']) && isset($params['numbers'] ) ){
            $o = new BIM_Jobs_Growth();
            return $o->queueSMSInvites( $params['userId'], $params['numbers'] );
        }
    }
    
    public function trackClick( $params ){
        $data = $_GET['click'];
        $parts = explode('/',$data );
        //$parts = explode('/',$_SERVER['REQUEST_URI'] );
        $ct = count($parts);
        if( $ct > 1 ){
            $idx = $ct - 2;
            $networkId = $parts[$idx];
            $idx = $ct - 1;
            $personaName = $parts[$idx];
            $persona = new BIM_Growth_Persona( $personaName );
            if( $persona->isExtant() ){
                $referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : '';
                $persona->trackInboundClick($networkId, $referer);
            }
        }
    }
}
