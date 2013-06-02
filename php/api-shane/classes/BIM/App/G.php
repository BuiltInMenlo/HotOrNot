<?php

class BIM_App_G extends BIM_App_Base{
    
    public function volleyUserPhotoComment( $params ){
        if( isset($params['userId']) && isset($params['username']) && isset($params['password']) ){
            $o = new BIM_Jobs_Instagram();
            return $o->queueVolleyUserPhotoComment($params['userId'], $params['username'], $params['password']);
        }
    }
    
}
