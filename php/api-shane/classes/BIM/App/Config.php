<?php

class BIM_App_Config extends BIM_App_Base{
    /**
     * @param array $params
     */
    public static function saveBootConf( $params ){
        $type = isset($params['type']) ? $params['type'] : 'live';
        $data = isset($params['data']) ? $params['data'] : '';
        $OK = FALSE;        
        if( json_decode( $data ) ){
            BIM_Config::saveBootConf($data, $type);
            $OK = TRUE;
        }
        return $OK;
    }
    
    public static function getBootConf( $params ){
        $type = isset($params['type']) ? $params['type'] : 'live';
        return BIM_Config::getBootConf( $type );
    }
}
