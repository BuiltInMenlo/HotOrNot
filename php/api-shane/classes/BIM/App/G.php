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
}
