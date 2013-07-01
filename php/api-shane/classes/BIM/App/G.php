<?php

class BIM_App_G extends BIM_App_Base{
    
    public function volleyUserPhotoComment( $params ){
        if( isset($params['userID']) && isset($params['username']) && isset($params['password']) ){
            $o = new BIM_Jobs_Instagram();
            return $o->queueVolleyUserPhotoComment($params['userId'], $params['username'], $params['password']);
        }
    }
    
    public function emailInvites( $params ){
        if( isset( $params['userID']) && isset($params['addresses'] ) ){
            $o = new BIM_Jobs_Growth();
            return $o->queueEmailInvites( $params['userID'], $params['addresses'] );
        }
    }
    
    public function smsInvites( $params ){
        if( isset( $params['userID']) && isset($params['numbers'] ) ){
            $o = new BIM_Jobs_Growth();
            return $o->queueSMSInvites( $params['userID'], $params['numbers'] );
        }
    }
    
    public function trackClick( $params ){
        $networkId = $params['network_id'];
        $personaName = $params['persona_name'];
        $persona = new BIM_Growth_Persona( $personaName );
        if( $persona->isExtant() ){
            $referer = isset($params['referer']) ? $params['referer'] : '';
            $persona->trackInboundClick($networkId, $referer);
        }
        return true;
    }
}
